import 'dart:math' as math;
import 'package:solar_planner/core/geo.dart';
import 'package:sqlite3/sqlite3.dart' as s3;

void main(List<String> args) {
  final path = args.isNotEmpty ? args[0] : r'C:\Users\sebas\OneDrive\share\SolarPlanner\solarplanner.db';
  final db = s3.sqlite3.open(path, mode: s3.OpenMode.readOnly);
  for (final r in db.select('SELECT id, name, azimuth_deg FROM roofs WHERE project_id = 2').toList()) {
    final poly = Pt.decode(db.select('SELECT polygon FROM roofs WHERE id = ?', [r['id']]).single['polygon']);
    // long edge 0->1 screen angle:
    final dx = poly[1].x - poly[0].x, dy = poly[1].y - poly[0].y;
    final ang = math.atan2(dy, dx) * 180 / math.pi;
    print('roof ${r['id']} "${r['name']}" az=${r['azimuth_deg']}  long-edge screen angle = ${ang.toStringAsFixed(2)}°');
    print('   corners: ${poly.map((p) => '(${p.x.toStringAsFixed(2)},${p.y.toStringAsFixed(2)})').join(' ')}');
  }
  db.dispose();
}
