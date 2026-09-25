// One-off: rotate the roofs (and their placed modules) of project
// "Kummersberg Garage" so that the stored polygon matches azimuth_deg.
//
// Geometry conventions (see editor_controller.dart addRoof/autoFillRoof):
//   world x = east, y = south (screen). The ridge direction in screen coords
//   is (cos az, sin az), i.e. the long edge's atan2-angle in screen space
//   equals the compass azimuth (mod 180). A heading change by delta is a
//   plain rigid rotation by delta around the roof centroid; module rotations
//   (panelRotDeg == azimuth for auto-filled panels) shift by the same delta.
import 'dart:math' as math;

import 'package:solar_planner/core/geo.dart';
import 'package:sqlite3/sqlite3.dart' as s3;

void main(List<String> args) {
  if (args.isEmpty) {
    print('usage: dart run tool/rotate_roofs.dart <dbPath> [--dry-run]');
    return;
  }
  final path = args[0];
  final dryRun = args.contains('--dry-run');

  final db = s3.sqlite3.open(path);
  try {
    for (final r in db.select(
        'SELECT id, name, azimuth_deg FROM roofs WHERE project_id = 2').toList()) {
      _rotateRoof(db, r['id'] as int, r['name'] as String,
          (r['azimuth_deg'] as num).toDouble(), dryRun: dryRun);
    }
    print(dryRun ? 'DRY RUN — nothing written' : 'DONE');
  } finally {
    db.dispose();
  }
}

void _rotateRoof(s3.Database db, int roofId, String name, double newAz,
    {required bool dryRun}) {
  final poly = Pt.decode(
      db.select('SELECT polygon FROM roofs WHERE id = ?', [roofId]).single['polygon']);

  // Centroid.
  final cx = poly.map((p) => p.x).reduce((a, b) => a + b) / poly.length;
  final cy = poly.map((p) => p.y).reduce((a, b) => a + b) / poly.length;

  // Ridge = the longer of edge (0->1) and (1->2).
  double len(int a, int b) => math.sqrt(
      math.pow(poly[a].x - poly[b].x, 2) + math.pow(poly[a].y - poly[b].y, 2));
  final use01 = len(0, 1) >= len(1, 2);
  double ridgeAngleDeg() {
    final a = use01 ? poly[0] : poly[1];
    final b = use01 ? poly[1] : poly[2];
    return math.atan2(b.y - a.y, b.x - a.x) * 180 / math.pi; // (-180, 180]
  }

  double wrap90(double a) {
    var d = (a % 360 + 540) % 360 - 180; // (-180, 180]
    if (d > 90) d -= 360;
    return d; // smallest rotation, [-180+eps..90] -> effectively (-90, 90]
  }

  final oldRidge = ridgeAngleDeg();
  final delta = wrap90(newAz - oldRidge);
  print('roof $roofId "$name": ridge ${oldRidge.toStringAsFixed(1)}° -> az '
      '${newAz.toStringAsFixed(1)}° (delta ${delta.toStringAsFixed(1)}°, '
      'centroid (${cx.toStringAsFixed(3)}, ${cy.toStringAsFixed(3)}))');
  if (delta.abs() < 0.01) return;

  final d = delta * math.pi / 180;
  final cosD = math.cos(d), sinD = math.sin(d);

  // Rotate polygon around centroid.
  final newPts = poly.map((p) {
    final vx = p.x - cx, vy = p.y - cy;
    return Pt(cx + vx * cosD - vy * sinD, cy + vx * sinD + vy * cosD);
  }).toList();

  // Sanity: new ridge angle must equal newAz (mod 180).
  final check = use01 ? math.atan2(newPts[1].y - newPts[0].y,
          newPts[1].x - newPts[0].x)
      : math.atan2(newPts[2].y - newPts[1].y, newPts[2].x - newPts[1].x);
  final checkDeg = check * 180 / math.pi;
  if (wrap90(checkDeg - newAz).abs() > 0.5) {
    throw StateError('ridge check failed: $checkDeg vs $newAz');
  }

  // Rotate placed modules around the same centroid; shift their rotation.
  final mods = db.select(
          'SELECT id, x, y, rotation_deg FROM placed_modules WHERE roof_id = ?', [roofId])
      .toList();
  for (final m in mods) {
    final x = (m['x'] as num).toDouble(), y = (m['y'] as num).toDouble();
    final vx = x - cx, vy = y - cy;
    final nx = cx + vx * cosD - vy * sinD;
    final ny = cy + vx * sinD + vy * cosD;
    var nrot = ((m['rotation_deg'] as num).toDouble() + delta) % 360;
    if (nrot < 0) nrot += 360;
    if (!dryRun) {
      db.execute('UPDATE placed_modules SET x = ?, y = ?, rotation_deg = ? '
          'WHERE id = ?', [nx, ny, nrot, m['id']]);
    }
  }

  if (!dryRun) {
    db.execute('UPDATE roofs SET polygon = ? WHERE id = ?', [Pt.encode(newPts), roofId]);
  }
  print('roof $roofId: ridge after = ${checkDeg.toStringAsFixed(2)}°, '
      '${mods.length} modules rotated');
}
