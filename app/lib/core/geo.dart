import 'dart:convert';
import 'dart:math' as math;

/// A 2D point in plan-view coordinates (meters, y = north).
class Pt {
  final double x;
  final double y;
  const Pt(this.x, this.y);

  Pt translate(double dx, double dy) => Pt(x + dx, y + dy);

  double distanceTo(Pt other) =>
      math.sqrt((x - other.x) * (x - other.x) + (y - other.y) * (y - other.y));

  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is Pt && other.x == x && other.y == y);

  @override
  int get hashCode => Object.hash(x, y);

  static List<Pt> decode(String json) {
    final list = jsonDecode(json) as List;
    return list
        .map((e) => Pt(((e as List)[0] as num).toDouble(), (e[1] as num).toDouble()))
        .toList();
  }

  static String encode(List<Pt> points) {
    return jsonEncode(points.map((p) => [p.x, p.y]).toList());
  }
}

/// Ray-casting point-in-polygon test.
bool pointInPolygon(Pt p, List<Pt> polygon) {
  if (polygon.length < 3) return false;
  var inside = false;
  for (var i = 0, j = polygon.length - 1; i < polygon.length; j = i++) {
    final a = polygon[i];
    final b = polygon[j];
    if (((a.y > p.y) != (b.y > p.y)) &&
        (p.x < (b.x - a.x) * (p.y - a.y) / (b.y - a.y) + a.x)) {
      inside = !inside;
    }
  }
  return inside;
}

/// Signed area via the shoelace formula (absolute value returned).
double polygonArea(List<Pt> polygon) {
  if (polygon.length < 3) return 0;
  var sum = 0.0;
  for (var i = 0; i < polygon.length; i++) {
    final a = polygon[i];
    final b = polygon[(i + 1) % polygon.length];
    sum += a.x * b.y - b.x * a.y;
  }
  return sum.abs() / 2;
}

/// Area-weighted centroid.
Pt polygonCentroid(List<Pt> polygon) {
  if (polygon.isEmpty) return const Pt(0, 0);
  if (polygon.length < 3) {
    var cx = 0.0, cy = 0.0;
    for (final p in polygon) {
      cx += p.x;
      cy += p.y;
    }
    return Pt(cx / polygon.length, cy / polygon.length);
  }
  var cx = 0.0, cy = 0.0, a = 0.0;
  for (var i = 0; i < polygon.length; i++) {
    final p1 = polygon[i];
    final p2 = polygon[(i + 1) % polygon.length];
    final cross = p1.x * p2.y - p2.x * p1.y;
    a += cross;
    cx += (p1.x + p2.x) * cross;
    cy += (p1.y + p2.y) * cross;
  }
  a /= 2;
  if (a.abs() < 1e-9) return polygon.first;
  return Pt(cx / (6 * a), cy / (6 * a));
}

/// Bounding box of a polygon.
class BBox {
  final double minX, minY, maxX, maxY;
  const BBox(this.minX, this.minY, this.maxX, this.maxY);

  double get width => maxX - minX;
  double get height => maxY - minY;
  Pt get center => Pt((minX + maxX) / 2, (minY + maxY) / 2);

  static BBox of(List<Pt> points) {
    var minX = double.infinity,
        minY = double.infinity,
        maxX = -double.infinity,
        maxY = -double.infinity;
    for (final p in points) {
      minX = math.min(minX, p.x);
      minY = math.min(minY, p.y);
      maxX = math.max(maxX, p.x);
      maxY = math.max(maxY, p.y);
    }
    if (minX > maxX) {
      return const BBox(0, 0, 0, 0);
    }
    return BBox(minX, minY, maxX, maxY);
  }
}
