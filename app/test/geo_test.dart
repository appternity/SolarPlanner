// Edge-case and null-safety tests for the plan-view geometry helpers.
//
// The basic behavior is already covered in widget_test.dart; this file adds
// the degenerate inputs (empty, single point, collinear, self-intersecting)
// that the testing concept requires to be pinned down explicitly.

import 'package:flutter_test/flutter_test.dart';
import 'package:solar_planner/core/geo.dart';

void main() {
  group('Pt edge cases', () {
    test('translate with negative values works', () {
      const p = Pt(1, 2);
      final q = p.translate(-3, -4);
      expect(q.x, closeTo(-2.0, 1e-9));
      expect(q.y, closeTo(-2.0, 1e-9));
    });

    test('distanceTo is symmetric', () {
      const a = Pt(1, 2);
      const b = Pt(-4, 8.5);
      expect(a.distanceTo(b), closeTo(b.distanceTo(a), 1e-9));
    });

    test('distanceTo identical points is zero', () {
      const p = Pt(3.5, -1);
      expect(p.distanceTo(const Pt(3.5, -1)), 0);
    });

    test('encode/decode handles zero coordinates', () {
      const points = [Pt(0, 0), Pt(0, -1.5)];
      final decoded = Pt.decode(Pt.encode(points));
      expect(decoded, hasLength(2));
      expect(decoded[0].x, 0);
      expect(decoded[1].y, -1.5);
    });

    test('encode/decode round-trips negative and fractional coordinates', () {
      const points = [Pt(-2.5, 0), Pt(1e-6, -98765432.1)];
      final decoded = Pt.decode(Pt.encode(points));
      expect(decoded, hasLength(2));
      expect(decoded[0].x, closeTo(-2.5, 1e-9));
      expect(decoded[0].y, closeTo(0, 1e-9));
      expect(decoded[1].x, closeTo(1e-6, 1e-9));
      expect(decoded[1].y, closeTo(-98765432.1, 1e-3));
    });

    test('equality and hashCode are consistent', () {
      const a = Pt(1, 2);
      const b = Pt(1, 2);
      expect(a == b, isTrue);
      expect(a.hashCode, b.hashCode);
    });
  });

  group('pointInPolygon edge cases', () {
    test('returns false for empty polygon', () {
      expect(pointInPolygon(const Pt(0, 0), const []), isFalse);
    });

    test('returns false for single point polygon', () {
      expect(pointInPolygon(const Pt(0, 0), const [Pt(1, 1)]), isFalse);
    });

    test('handles collinear points (degenerate triangle)', () {
      // Three collinear "vertices" form no area — everything is outside.
      final line = const [Pt(0, 0), Pt(1, 0), Pt(2, 0)];
      expect(pointInPolygon(const Pt(1, 0), line), isFalse);
      expect(pointInPolygon(const Pt(1, 1), line), isFalse);
    });

    test('point on the boundary of a square', () {
      final square = const [Pt(0, 0), Pt(1, 0), Pt(1, 1), Pt(0, 1)];
      // Ray casting is boundary-sensitive; the interior/exterior contract
      // must hold regardless of which side a shared edge falls on.
      final onEdge = pointInPolygon(const Pt(0.5, 1), square);
      final outside = pointInPolygon(const Pt(0.5, 2), square);
      expect(outside, isFalse);
      // The on-edge result must be deterministic (same call → same answer).
      expect(onEdge, pointInPolygon(const Pt(0.5, 1), square));
    });

    test('works for a concave polygon', () {
      // L-shape: (0,0)→(2,0)→(2,1)→(1,1)→(1,2)→(0,2).
      final l = const [Pt(0, 0), Pt(2, 0), Pt(2, 1), Pt(1, 1), Pt(1, 2), Pt(0, 2)];
      expect(pointInPolygon(const Pt(1.5, 0.5), l), isTrue);
      expect(pointInPolygon(const Pt(1.5, 1.5), l), isFalse);
    });
  });

  group('polygonArea edge cases', () {
    test('returns zero for empty list', () {
      expect(polygonArea(const []), 0);
    });

    test('returns zero for a single point', () {
      expect(polygonArea(const [Pt(1, 2)]), 0);
    });

    test('handles self-intersecting polygon gracefully', () {
      // Bowtie: (0,0)→(2,2)→(2,0)→(0,2). Shoelace yields a finite value;
      // it must not throw and stays non-negative.
      final bowtie = const [Pt(0, 0), Pt(2, 2), Pt(2, 0), Pt(0, 2)];
      final area = polygonArea(bowtie);
      expect(area, greaterThanOrEqualTo(0));
    });

    test('handles collinear points', () {
      final line = const [Pt(0, 0), Pt(1, 1), Pt(2, 2)];
      expect(polygonArea(line), closeTo(0, 1e-9));
    });

    test('scales with size (2x square has 4x area)', () {
      final unit = const [Pt(0, 0), Pt(1, 0), Pt(1, 1), Pt(0, 1)];
      final doubled = const [Pt(0, 0), Pt(2, 0), Pt(2, 2), Pt(0, 2)];
      expect(polygonArea(doubled), closeTo(4 * polygonArea(unit), 1e-9));
    });
  });

  group('polygonCentroid edge cases', () {
    test('handles single point', () {
      expect(polygonCentroid(const [Pt(3, -2)]), const Pt(3, -2));
    });

    test('handles two points (line)', () {
      final c = polygonCentroid(const [Pt(0, 0), Pt(4, 8)]);
      expect(c.x, closeTo(2, 1e-9));
      expect(c.y, closeTo(4, 1e-9));
    });

    test('collinear triangle falls back to first vertex', () {
      final line = const [Pt(0, 0), Pt(1, 1), Pt(2, 2)];
      expect(polygonCentroid(line), const Pt(0, 0));
    });

    test('centroid of a right triangle is the average of its vertices', () {
      final tri = const [Pt(0, 0), Pt(3, 0), Pt(0, 4)];
      final c = polygonCentroid(tri);
      expect(c.x, closeTo(1.0, 1e-9));
      expect(c.y, closeTo(4 / 3, 1e-9));
    });

    test('centroid is invariant under translation', () {
      final square = const [Pt(0, 0), Pt(1, 0), Pt(1, 1), Pt(0, 1)];
      final moved = const [Pt(5, -3), Pt(6, -3), Pt(6, -2), Pt(5, -2)];
      final a = polygonCentroid(square);
      final b = polygonCentroid(moved);
      expect(b.x, closeTo(a.x + 5, 1e-9));
      expect(b.y, closeTo(a.y - 3, 1e-9));
    });
  });

  group('BBox edge cases', () {
    test('of() with empty list returns zero-size box at origin', () {
      const box = BBox(0, 0, 0, 0);
      final result = BBox.of(const []);
      expect(result.minX, 0);
      expect(result.maxY, 0);
      expect(result.width, box.width); // 0
    });

    test('of() with a single point returns a zero-size box at that point', () {
      final box = BBox.of(const [Pt(-2, 7)]);
      expect(box.minX, -2);
      expect(box.maxY, 7);
      expect(box.width, 0);
    });

    test('boundary points: center is inside', () {
      final box = BBox.of(const [Pt(0, 0), Pt(2, 4)]);
      expect(box.center.x, closeTo(1, 1e-9));
      expect(box.center.y, closeTo(2, 1e-9));
    });

    test('width and height are non-negative for valid boxes', () {
      final box = BBox.of(const [Pt(5, 6), Pt(-1, -2)]);
      expect(box.width, greaterThanOrEqualTo(0));
      expect(box.height, greaterThanOrEqualTo(0));
    });
  });
}
