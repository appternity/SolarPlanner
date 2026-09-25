/// Hard-coded PV yield efficiency table for Germany.
///
/// Source: Mertens, Konrad: Photovoltaik – Lehrbuch zu Grundlagen, Technologie
/// und Praxis, 5. Aufl., München, Carl Hanser Verlag, 2020, S. 58
/// (see `data/effizienz/pv-module_ausrichtung_vs_neigung.png`).
///
/// Rows: roof orientation as deviation from due south in 10° steps,
///   0° = facing south (S), 90° = east or west, 180° = facing north.
/// Columns: roof pitch (Neigung) in 10° steps, 0° … 90°.
/// Values: annual yield in % of a south-facing, optimally tilted reference.
class EfficiencyTable {
  const EfficiencyTable._();

  /// _percent[deviationFromSouth / 10][pitchDeg / 10]
  static const List<List<int>> _percent = [
    // 0° (S)
    [87, 93, 97, 100, 100, 98, 94, 89, 81, 72],
    // 10°
    [87, 93, 97, 99, 99, 98, 94, 88, 81, 72],
    // 20°
    [87, 93, 96, 98, 98, 97, 93, 87, 80, 71],
    // 30°
    [87, 92, 95, 97, 97, 95, 91, 86, 79, 70],
    // 40°
    [87, 92, 93, 95, 95, 93, 89, 83, 77, 69],
    // 50°
    [87, 91, 91, 93, 92, 90, 86, 81, 74, 67],
    // 60°
    [87, 90, 90, 90, 89, 86, 83, 78, 71, 64],
    // 70°
    [87, 89, 88, 87, 86, 83, 79, 74, 68, 62],
    // 80°
    [87, 88, 86, 84, 82, 79, 75, 70, 65, 58],
    // 90° (O/W)
    [87, 86, 83, 81, 78, 74, 70, 66, 60, 55],
    // 100°
    [87, 85, 81, 77, 74, 70, 66, 61, 56, 51],
    // 110°
    [87, 84, 79, 74, 70, 65, 61, 57, 52, 47],
    // 120°
    [87, 83, 76, 71, 66, 61, 56, 52, 48, 44],
    // 130°
    [87, 81, 74, 68, 62, 57, 52, 48, 44, 40],
    // 140°
    [87, 81, 73, 65, 58, 53, 48, 44, 40, 37],
    // 150°
    [87, 80, 71, 63, 56, 49, 45, 41, 38, 34],
    // 160°
    [87, 79, 70, 62, 54, 47, 42, 38, 35, 32],
    // 170°
    [87, 79, 70, 61, 53, 46, 40, 36, 33, 31],
    // 180° (N)
    [87, 79, 69, 61, 53, 45, 39, 36, 33, 30],
  ];

  /// Annual yield in % for a roof with [azimuthDeg] (° clockwise from north,
  /// i.e. the direction it faces) and [pitchDeg] (Neigung). Both are rounded
  /// to the nearest table step; out-of-range values are clamped.
  static double efficiencyPercent({
    required double azimuthDeg,
    required double pitchDeg,
  }) {
    // Deviation from due south (180°), wrapped to [0, 180].
    var dev = (azimuthDeg - 180).abs() % 360;
    if (dev > 180) dev = 360 - dev;

    final row = (dev / 10).round().clamp(0, _percent.length - 1);
    final col = pitchDeg.clamp(0, 90) / 10;
    final c = col.round().clamp(0, _percent[0].length - 1);
    return _percent[row][c].toDouble();
  }
}
