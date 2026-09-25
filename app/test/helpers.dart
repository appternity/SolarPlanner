import 'package:drift/drift.dart';
import 'package:solar_planner/db/database.dart';

/// Creates a [Roof] with sensible defaults for tests.
Roof makeRoof({
  int id = 1,
  int projectId = 1,
  String name = 'Testdach',
  double lengthM = 10.0,
  double widthM = 5.0,
  double pitchDeg = 30.0,
  double azimuthDeg = 180.0,
  String type = 'pitched',
}) {
  // Simple rectangle polygon: length x width.
  final poly = '[[0,0],[$lengthM,0],[$lengthM,$widthM],[0,$widthM]]';
  return Roof(
    id: id,
    projectId: projectId,
    name: name,
    polygon: poly,
    lengthM: lengthM,
    widthM: widthM,
    pitchDeg: pitchDeg,
    azimuthDeg: azimuthDeg,
    type: type,
    rafterStraight: true,
    hasCounterBatten: false,
    tileMaterial: 'clay',
    hasSpareTiles: false,
    hasInsulation: false,
  );
}

/// Creates a [RoofsCompanion] for inserting into the DB in tests.
RoofsCompanion makeRoofCompanion({
  required int projectId,
  String name = 'Testdach',
  double lengthM = 10.0,
  double widthM = 5.0,
  double pitchDeg = 30.0,
  double azimuthDeg = 180.0,
  String type = 'pitched',
}) {
  final poly = '[[0,0],[$lengthM,0],[$lengthM,$widthM],[0,$widthM]]';
  return RoofsCompanion.insert(
    projectId: projectId,
    name: name,
    polygon: poly,
    lengthM: lengthM,
    widthM: widthM,
    pitchDeg: Value(pitchDeg),
    azimuthDeg: Value(azimuthDeg),
    type: Value(type),
  );
}
