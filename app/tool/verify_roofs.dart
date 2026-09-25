// One-off: verify placed modules of a roof are fully inside its polygon.
import 'dart:math' as math;

import 'package:solar_planner/core/geo.dart';
import 'package:sqlite3/sqlite3.dart' as s3;

void main(List<String> args) {
  final path = args.isNotEmpty ? args[0] : r'C:\Users\sebas\Documents\solarplanner.db';
  final db = s3.sqlite3.open(path, mode: s3.OpenMode.readOnly);
  try {
    final roofs = db.select(
        'SELECT id, name FROM roofs WHERE project_id = 2').toList();
    for (final r in roofs) {
      final poly = Pt.decode(
          db.select('SELECT polygon FROM roofs WHERE id = ?', [r['id']]).single['polygon']);
      final mods = db.select(
              'SELECT pm.id, pm.x, pm.y, pm.rotation_deg, sm.width_mm, sm.height_mm '
              'FROM placed_modules pm JOIN solar_modules sm ON sm.id = pm.module_id '
              'WHERE pm.roof_id = ?', [r['id']])
          .toList();
      var bad = 0;
      for (final m in mods) {
        final cx = (m['x'] as num).toDouble(), cy = (m['y'] as num).toDouble();
        final w = ((m['width_mm'] ?? 0) as num).toDouble() / 2000; // mm -> m, half
        final h = ((m['height_mm'] ?? 0) as num).toDouble() / 2000;
        final rad = (m['rotation_deg'] as num).toDouble() * math.pi / 180;
        final cosR = math.cos(rad), sinR = math.sin(rad);
        for (final lx in [-w, w]) {
          for (final ly in [-h, h]) {
            final px = cx + lx * cosR - ly * sinR;
            final py = cy + lx * sinR + ly * cosR;
            if (!pointInPolygon(Pt(px, py), poly)) bad++;
          }
        }
      }
      print('roof ${r['id']} "${r['name']}": ${mods.length} modules, '
          '${bad == 0 ? "all corners inside polygon OK" : "$bad CORNERS OUTSIDE"}');
    }
  } finally {
    db.dispose();
  }
}
