// Unit tests for the plan-view geometry helpers.
//
// These avoid platform channels (no database / file system) so they run
// fast and deterministically on every platform.

import 'package:flutter_test/flutter_test.dart';
import 'package:solar_planner/core/geo.dart';

void main() {
  group('Pt', () {
    test('translate offsets both coordinates', () {
      const p = Pt(1, 2);
      final q = p.translate(3, 4);
      expect(q, const Pt(4, 6));
    });

    test('distanceTo computes euclidean distance', () {
      expect(const Pt(0, 0).distanceTo(const Pt(3, 4)), closeTo(5, 1e-9));
    });

    test('encode/decode round-trips a list of points', () {
      const points = [Pt(0, 0), Pt(1.5, -2.25), Pt(3, 4)];
      final decoded = Pt.decode(Pt.encode(points));
      expect(decoded, points);
    });
  });

  group('pointInPolygon', () {
    // A unit square from (0,0) to (1,1).
    final square = const [Pt(0, 0), Pt(1, 0), Pt(1, 1), Pt(0, 1)];

    test('detects interior points', () {
      expect(pointInPolygon(const Pt(0.5, 0.5), square), isTrue);
    });

    test('rejects exterior points', () {
      expect(pointInPolygon(const Pt(2, 2), square), isFalse);
      expect(pointInPolygon(const Pt(-1, 0.5), square), isFalse);
    });

    test('requires at least three points', () {
      expect(pointInPolygon(const Pt(0.5, 0.5), const [Pt(0, 0), Pt(1, 1)]),
          isFalse);
    });
  });

  group('polygonArea', () {
    test('computes the area of a unit square', () {
      final square = const [Pt(0, 0), Pt(1, 0), Pt(1, 1), Pt(0, 1)];
      expect(polygonArea(square), closeTo(1, 1e-9));
    });

    test('is independent of winding direction', () {
      final cw = const [Pt(0, 0), Pt(0, 1), Pt(1, 1), Pt(1, 0)];
      final ccw = const [Pt(0, 0), Pt(1, 0), Pt(1, 1), Pt(0, 1)];
      expect(polygonArea(cw), closeTo(polygonArea(ccw), 1e-9));
    });

    test('returns zero for degenerate polygons', () {
      expect(polygonArea(const [Pt(0, 0), Pt(1, 1)]), 0);
    });
  });

  group('polygonCentroid', () {
    test('centroid of a unit square is its center', () {
      final square = const [Pt(0, 0), Pt(1, 0), Pt(1, 1), Pt(0, 1)];
      final c = polygonCentroid(square);
      expect(c.x, closeTo(0.5, 1e-9));
      expect(c.y, closeTo(0.5, 1e-9));
    });

    test('empty polygon yields the origin', () {
      expect(polygonCentroid(const []), const Pt(0, 0));
    });
  });

  group('BBox', () {
    test('of() computes the bounding box', () {
      final box = BBox.of(const [Pt(0, 0), Pt(2, 3), Pt(-1, 5)]);
      expect(box.minX, -1);
      expect(box.minY, 0);
      expect(box.maxX, 2);
      expect(box.maxY, 5);
      expect(box.width, 3);
      expect(box.height, 5);
    });

    test('center is the midpoint', () {
      final box = BBox.of(const [Pt(0, 0), Pt(2, 4)]);
      expect(box.center, const Pt(1, 2));
    });
  });
}
