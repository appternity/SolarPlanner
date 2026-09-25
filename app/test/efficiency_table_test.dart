import 'package:flutter_test/flutter_test.dart';

import 'package:solar_planner/core/efficiency_table.dart';

void main() {
  group('EfficiencyTable', () {
    test('spot-checked values match the published table (Mertens, S. 58)', () {
      // South-facing roofs: best yield at ~30-40° pitch.
      expect(EfficiencyTable.efficiencyPercent(azimuthDeg: 180, pitchDeg: 35),
          100); // rounds to row 0, col 4 (35° -> nearest step)
      expect(
          EfficiencyTable.efficiencyPercent(azimuthDeg: 180, pitchDeg: 30),
          100); // row 0, col 3
      expect(EfficiencyTable.efficiencyPercent(azimuthDeg: 180, pitchDeg: 0),
          87); // row 0, col 0

      // East/west (90° deviation) at flat pitch.
      expect(EfficiencyTable.efficiencyPercent(azimuthDeg: 90, pitchDeg: 10),
          86); // row 9 (O/W), col 1

      // North-facing roof degrades strongly with pitch.
      expect(EfficiencyTable.efficiencyPercent(azimuthDeg: 0, pitchDeg: 90),
          30); // row 18 (N), col 9

      // Azimuth wraps: 270° is also a 90° deviation from south.
      expect(EfficiencyTable.efficiencyPercent(azimuthDeg: 270, pitchDeg: 10),
          86);

      // Slight deviation rounds to the nearest row.
      expect(EfficiencyTable.efficiencyPercent(azimuthDeg: 175, pitchDeg: 30),
          99); // row 1 (5° -> rounds to 10), col 3
    });

    test('out-of-range values are clamped', () {
      expect(EfficiencyTable.efficiencyPercent(azimuthDeg: 180, pitchDeg: -5),
          87); // clamped to col 0
      expect(EfficiencyTable.efficiencyPercent(azimuthDeg: 180, pitchDeg: 95),
          72); // clamped to col 9
      expect(EfficiencyTable.efficiencyPercent(azimuthDeg: -180, pitchDeg: 30),
          100); // -180° ≡ 180°, i.e. due south (row 0), col 3
    });

    test('south-facing roof always beats north-facing at same pitch', () {
      for (var p = 0; p <= 90; p += 10) {
        final s = EfficiencyTable.efficiencyPercent(azimuthDeg: 180, pitchDeg: p.toDouble());
        final n = EfficiencyTable.efficiencyPercent(azimuthDeg: 0, pitchDeg: p.toDouble());
        expect(s >= n, isTrue, reason: 'pitch $p°');
      }
    });
  });
}
