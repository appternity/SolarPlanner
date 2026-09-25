/// Electrical planning calculations shared by the seed, migrations and the
/// editor (VDE-AR-N 4105 / DIN VDE 0100).
library;

/// Rated AC output current in A: the datasheet value [iOutA], or derived as
/// P/(U·cosφ) with cos φ = 1 when it is null.
double inverterOutputCurrentA({
  required double powerKw,
  required int acPhases,
  double? iOutA,
}) {
  final u = acPhases == 1 ? 230.0 : 400.0;
  return iOutA ?? (powerKw * 1000) / u;
}

/// Next standard MCB rating (A) that covers [currentA]: IEC 60898 series.
double recommendedMcbA(double currentA) {
  for (final f in const [10.0, 16.0, 20.0, 25.0, 32.0, 40.0, 50.0, 63.0]) {
    if (currentA <= f) return f;
  }
  return 63.0;
}

/// Recommended MCB (LS-Schalter) rating in A for an inverter's AC output
/// connection, derived from its datasheet values.
int mcbRatingForInverter({
  required double powerKw,
  required int acPhases,
  double? iOutA,
}) =>
    recommendedMcbA(
            inverterOutputCurrentA(
                powerKw: powerKw, acPhases: acPhases, iOutA: iOutA))
        .round();
