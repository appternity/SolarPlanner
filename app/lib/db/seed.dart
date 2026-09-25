import 'package:drift/drift.dart';

import 'database.dart';
import 'electrical.dart' show mcbRatingForInverter;

/// Seeds the inventory with real products from the datasheets in
/// `data/datenblatt/` (values read from the manufacturer PDFs).
///
/// Only runs when the database is completely empty (first start).
Future<void> seedIfEmpty(AppDatabase db) async {
  final projectCount = await db.select(db.projects).get();
  if (projectCount.isNotEmpty) return;

  final now = DateTime.now().millisecondsSinceEpoch;

  // ------------------------------------------------------------------
  // Modules
  // ------------------------------------------------------------------
  await db.into(db.solarModules).insert(SolarModulesCompanion.insert(
    name: 'Tiger Neo 54HL4R-V 460',
    manufacturer: const Value('JinkoSolar'),
    pMaxW: 460,
    vmp: const Value(33.60),
    imp: const Value(13.69),
    voc: 40.17,
    isc: 14.14,
    vocTempCoeff: const Value(-0.25),
    widthMm: 1762,
    heightMm: 1134,
    thicknessMm: const Value(30),
    weightKg: const Value(21.0),
    frameClass: const Value('II'), // datasheet: Protection Class II
  ));

  // JinkoSolar Tiger Neo 54HL4R-(V) – N-type TOPCon mono-facial, 108 cells,
  // Protection Class II (double insulated → no frame earthing needed).
  // Values from the Tiger Neo datasheet (2024). Range products use their max
  // Pmax and top-of-range electrical values.
  await db.into(db.solarModules).insert(SolarModulesCompanion.insert(
    name: 'Tiger Neo 54HL4R-V 435-440W',
    manufacturer: const Value('JinkoSolar'),
    pMaxW: 440,
    vmp: const Value(32.81),
    imp: const Value(13.41),
    voc: 39.38,
    isc: 13.86,
    vocTempCoeff: const Value(-0.25),
    widthMm: 1762,
    heightMm: 1134,
    thicknessMm: const Value(30),
    weightKg: const Value(21.0),
    frameClass: const Value('II'), // datasheet: Protection Class II
  ));

  await db.into(db.solarModules).insert(SolarModulesCompanion.insert(
    name: 'Tiger Neo 54HL4R-V 445-450W',
    manufacturer: const Value('JinkoSolar'),
    pMaxW: 450,
    vmp: const Value(33.21),
    imp: const Value(13.55),
    voc: 39.78,
    isc: 14.00,
    vocTempCoeff: const Value(-0.25),
    widthMm: 1762,
    heightMm: 1134,
    thicknessMm: const Value(30),
    weightKg: const Value(21.0),
    frameClass: const Value('II'), // datasheet: Protection Class II
  ));

  await db.into(db.solarModules).insert(SolarModulesCompanion.insert(
    name: 'JAM54D41 455',
    manufacturer: const Value('JA Solar'),
    pMaxW: 455,
    vmp: const Value(33.10),
    imp: const Value(13.75),
    voc: 39.30,
    isc: 14.48,
    vocTempCoeff: const Value(-0.30),
    widthMm: 1762,
    heightMm: 1134,
    thicknessMm: const Value(30),
    weightKg: const Value(22.0),
  ));

  // JA Solar Deep Blue 4.0 (JAM54D41 LB) – n-type bifacial double glass,
  // 108 cells. Values from the Deep Blue 4.0 datasheet.
  await db.into(db.solarModules).insert(SolarModulesCompanion.insert(
    name: 'JAM54D41-430/LB',
    manufacturer: const Value('JA Solar'),
    pMaxW: 430,
    vmp: const Value(32.12),
    imp: const Value(13.39),
    voc: 38.50,
    isc: 14.14,
    vocTempCoeff: const Value(-0.26),
    widthMm: 1762,
    heightMm: 1134,
    thicknessMm: const Value(30),
    weightKg: const Value(22.0),
  ));

  await db.into(db.solarModules).insert(SolarModulesCompanion.insert(
    name: 'JAM54D41-435/LB',
    manufacturer: const Value('JA Solar'),
    pMaxW: 435,
    vmp: const Value(32.29),
    imp: const Value(13.47),
    voc: 38.70,
    isc: 14.23,
    vocTempCoeff: const Value(-0.26),
    widthMm: 1762,
    heightMm: 1134,
    thicknessMm: const Value(30),
    weightKg: const Value(22.0),
  ));

  await db.into(db.solarModules).insert(SolarModulesCompanion.insert(
    name: 'JAM54D41-440/LB',
    manufacturer: const Value('JA Solar'),
    pMaxW: 440,
    vmp: const Value(32.47),
    imp: const Value(13.55),
    voc: 38.90,
    isc: 14.31,
    vocTempCoeff: const Value(-0.26),
    widthMm: 1762,
    heightMm: 1134,
    thicknessMm: const Value(30),
    weightKg: const Value(22.0),
  ));

  await db.into(db.solarModules).insert(SolarModulesCompanion.insert(
    name: 'JAM54D41-445/LB',
    manufacturer: const Value('JA Solar'),
    pMaxW: 445,
    vmp: const Value(32.65),
    imp: const Value(13.63),
    voc: 39.10,
    isc: 14.40,
    vocTempCoeff: const Value(-0.26),
    widthMm: 1762,
    heightMm: 1134,
    thicknessMm: const Value(30),
    weightKg: const Value(22.0),
  ));

  await db.into(db.solarModules).insert(SolarModulesCompanion.insert(
    name: 'JAM54D41-450/LB',
    manufacturer: const Value('JA Solar'),
    pMaxW: 450,
    vmp: const Value(32.82),
    imp: const Value(13.71),
    voc: 39.30,
    isc: 14.48,
    vocTempCoeff: const Value(-0.26),
    widthMm: 1762,
    heightMm: 1134,
    thicknessMm: const Value(30),
    weightKg: const Value(22.0),
  ));

  await db.into(db.solarModules).insert(SolarModulesCompanion.insert(
    name: 'JAM54D41-455/LB',
    manufacturer: const Value('JA Solar'),
    pMaxW: 455,
    vmp: const Value(33.00),
    imp: const Value(13.79),
    voc: 39.50,
    isc: 14.56,
    vocTempCoeff: const Value(-0.26),
    widthMm: 1762,
    heightMm: 1134,
    thicknessMm: const Value(30),
    weightKg: const Value(22.0),
  ));

  // Trina Solar Vertex S (TSM-NEG9RC.27) – bifacial double-glass N-type
  // i-TOPCon, 144 cells. Values from the Vertex S datasheet (2023).
  // Range products use their max Pmax; electrical values are the top of range.
  // Anodized aluminum frame → Protection Class I (frame must be earthed).
  await db.into(db.solarModules).insert(SolarModulesCompanion.insert(
    name: 'TSM-415/420',
    manufacturer: const Value('Trina Solar'),
    pMaxW: 420,
    vmp: const Value(42.5),
    imp: const Value(9.89),
    voc: 50.5,
    isc: 10.53,
    vocTempCoeff: const Value(-0.24),
    widthMm: 1762,
    heightMm: 1134,
    thicknessMm: const Value(30),
    weightKg: const Value(21.0),
    frameClass: const Value('I'), // anodized aluminum frame → Class I
  ));

  await db.into(db.solarModules).insert(SolarModulesCompanion.insert(
    name: 'TSM-425',
    manufacturer: const Value('Trina Solar'),
    pMaxW: 425,
    vmp: const Value(42.9),
    imp: const Value(9.92),
    voc: 50.9,
    isc: 10.56,
    vocTempCoeff: const Value(-0.24),
    widthMm: 1762,
    heightMm: 1134,
    thicknessMm: const Value(30),
    weightKg: const Value(21.0),
    frameClass: const Value('I'), // anodized aluminum frame → Class I
  ));

  await db.into(db.solarModules).insert(SolarModulesCompanion.insert(
    name: 'TSM-430',
    manufacturer: const Value('Trina Solar'),
    pMaxW: 430,
    vmp: const Value(43.2),
    imp: const Value(9.96),
    voc: 51.4,
    isc: 10.59,
    vocTempCoeff: const Value(-0.24),
    widthMm: 1762,
    heightMm: 1134,
    thicknessMm: const Value(30),
    weightKg: const Value(21.0),
    frameClass: const Value('I'), // anodized aluminum frame → Class I
  ));

  await db.into(db.solarModules).insert(SolarModulesCompanion.insert(
    name: 'TSM-435/440',
    manufacturer: const Value('Trina Solar'),
    pMaxW: 440,
    vmp: const Value(44.0),
    imp: const Value(10.01),
    voc: 52.2,
    isc: 10.67,
    vocTempCoeff: const Value(-0.24),
    widthMm: 1762,
    heightMm: 1134,
    thicknessMm: const Value(30),
    weightKg: const Value(21.0),
    frameClass: const Value('I'), // anodized aluminum frame → Class I
  ));

  // ------------------------------------------------------------------
  // Inverters
  // ------------------------------------------------------------------
  // GoodWe ET PLUS+ series (16A) – hybrid, three-phase, 2 MPPT × 1 string.
  // Values from the GoodWe ET PLUS+ datasheet (iOutA = max AC output current
  // to grid; DC limit 1000 V).
  await db.into(db.inverters).insert(InvertersCompanion.insert(
    name: 'GW5KN-ET',
    manufacturer: const Value('GoodWe'),
    mppMinVoltage: const Value(200), // MPPT operating voltage range
    mppMaxVoltage: const Value(850),
    powerKw: 5,
    mppCount: const Value(2),
    maxStringsPerMpp: const Value(1),
    minInputVoltage: const Value(180), // start-up voltage
    maxInputVoltage: const Value(1000),
    maxInputCurrentPerMpp: const Value(16),
    maxShortCircuitCurrentPerMpp: const Value(21.2),
    iOutA: const Value(8.5), // max AC output current to grid
    mcbA: Value(mcbRatingForInverter(powerKw: 5, acPhases: 3, iOutA: 8.5)),
    dcVoltageClass: const Value('1000V'),
    isHybrid: const Value(true),
  ));

  await db.into(db.inverters).insert(InvertersCompanion.insert(
    name: 'GW6.5KN-ET',
    manufacturer: const Value('GoodWe'),
    mppMinVoltage: const Value(200), // MPPT operating voltage range
    mppMaxVoltage: const Value(850),
    powerKw: 6.5,
    mppCount: const Value(2),
    maxStringsPerMpp: const Value(1),
    minInputVoltage: const Value(180), // start-up voltage
    maxInputVoltage: const Value(1000),
    maxInputCurrentPerMpp: const Value(16),
    maxShortCircuitCurrentPerMpp: const Value(21.2),
    iOutA: const Value(10.8), // max AC output current to grid
    mcbA: Value(mcbRatingForInverter(powerKw: 6.5, acPhases: 3, iOutA: 10.8)),
    dcVoltageClass: const Value('1000V'),
    isHybrid: const Value(true),
  ));

  await db.into(db.inverters).insert(InvertersCompanion.insert(
    name: 'GW8KN-ET',
    manufacturer: const Value('GoodWe'),
    mppMinVoltage: const Value(200), // MPPT operating voltage range
    mppMaxVoltage: const Value(850),
    powerKw: 8,
    mppCount: const Value(2),
    maxStringsPerMpp: const Value(1),
    minInputVoltage: const Value(180), // start-up voltage
    maxInputVoltage: const Value(1000),
    maxInputCurrentPerMpp: const Value(16),
    maxShortCircuitCurrentPerMpp: const Value(21.2),
    iOutA: const Value(13.5), // max AC output current to grid
    mcbA: Value(mcbRatingForInverter(powerKw: 8, acPhases: 3, iOutA: 13.5)),
    dcVoltageClass: const Value('1000V'),
    isHybrid: const Value(true),
  ));

  await db.into(db.inverters).insert(InvertersCompanion.insert(
    name: 'GW10KN-ET',
    manufacturer: const Value('GoodWe'),
    mppMinVoltage: const Value(200), // MPPT operating voltage range
    mppMaxVoltage: const Value(850),
    powerKw: 10,
    mppCount: const Value(2),
    maxStringsPerMpp: const Value(1),
    minInputVoltage: const Value(180), // start-up voltage
    maxInputVoltage: const Value(1000),
    maxInputCurrentPerMpp: const Value(16),
    maxShortCircuitCurrentPerMpp: const Value(21.2),
    iOutA: const Value(16.5), // max AC output current to grid
    mcbA: Value(mcbRatingForInverter(powerKw: 10, acPhases: 3, iOutA: 16.5)),
    dcVoltageClass: const Value('1000V'),
    isHybrid: const Value(true),
  ));

  // SMA Sunny Tripower X series (STPxx-50) – hybrid, 3 MPPT trackers,
  // 2 strings per tracker. Values from the STPxx-50 datasheet (08/2023).
  await db.into(db.inverters).insert(InvertersCompanion.insert(
    name: 'STP 12-50',
    manufacturer: const Value('SMA'),
    mppMinVoltage: const Value(210), // MPP voltage range (datasheet)
    mppMaxVoltage: const Value(800),
    powerKw: 12,
    mppCount: const Value(3),
    maxStringsPerMpp: const Value(2),
    minInputVoltage: const Value(210), // MPP voltage range start
    maxInputVoltage: const Value(800),
    iOutA: const Value(20.0), // max output current
    mcbA: Value(mcbRatingForInverter(powerKw: 12, acPhases: 3, iOutA: 20.0)),
    dcVoltageClass: const Value('1000V'),
    isHybrid: const Value(true),
  ));

  await db.into(db.inverters).insert(InvertersCompanion.insert(
    name: 'STP 15-50',
    manufacturer: const Value('SMA'),
    mppMinVoltage: const Value(260), // MPP voltage range (datasheet)
    mppMaxVoltage: const Value(800),
    powerKw: 15,
    mppCount: const Value(3),
    maxStringsPerMpp: const Value(2),
    minInputVoltage: const Value(260), // MPP voltage range start
    maxInputVoltage: const Value(800),
    iOutA: const Value(25.0), // max output current
    mcbA: Value(mcbRatingForInverter(powerKw: 15, acPhases: 3, iOutA: 25.0)),
    dcVoltageClass: const Value('1000V'),
    isHybrid: const Value(true),
  ));

  await db.into(db.inverters).insert(InvertersCompanion.insert(
    name: 'STP 20-50',
    manufacturer: const Value('SMA'),
    mppMinVoltage: const Value(345), // MPP voltage range (datasheet)
    mppMaxVoltage: const Value(800),
    powerKw: 20,
    mppCount: const Value(3),
    maxStringsPerMpp: const Value(2),
    minInputVoltage: const Value(150), // start-up voltage
    maxInputVoltage: const Value(1000),
    maxShortCircuitCurrentPerMpp: const Value(37.5),
    iOutA: const Value(36.6), // max output current
    mcbA: Value(mcbRatingForInverter(powerKw: 20, acPhases: 3, iOutA: 36.6)),
    dcVoltageClass: const Value('1000V'),
    isHybrid: const Value(true),
  ));

  await db.into(db.inverters).insert(InvertersCompanion.insert(
    name: 'STP 25-50',
    manufacturer: const Value('SMA'),
    mppMinVoltage: const Value(430), // MPP voltage range (datasheet)
    mppMaxVoltage: const Value(800),
    powerKw: 25,
    mppCount: const Value(3),
    maxStringsPerMpp: const Value(2),
    minInputVoltage: const Value(430), // MPP voltage range start
    maxInputVoltage: const Value(800),
    maxInputCurrentPerMpp: const Value(24),
    iOutA: const Value(36.6), // max output current
    mcbA: Value(mcbRatingForInverter(powerKw: 25, acPhases: 3, iOutA: 36.6)),
    dcVoltageClass: const Value('1000V'),
    isHybrid: const Value(true),
  ));

  // SMA Sunny Tripower Hybrid X series (STPHxx-60) – hybrid, 3 MPPT trackers,
  // 1 string per tracker. Values from the STPHxx-60 datasheet (06/2026).
  // Name uses the technical name; marketing name in parentheses.
  await db.into(db.inverters).insert(InvertersCompanion.insert(
    name: 'STPH5-60 (Hybrid X 5)',
    manufacturer: const Value('SMA'),
    mppMinVoltage: const Value(100), // MPP range @ rated power
    mppMaxVoltage: const Value(850),
    powerKw: 5,
    mppCount: const Value(3),
    maxStringsPerMpp: const Value(1),
    minInputVoltage: const Value(100), // MPP range @ rated power start
    maxInputVoltage: const Value(850),
    iOutA: const Value(7.6), // max output current
    mcbA: Value(mcbRatingForInverter(powerKw: 5, acPhases: 3, iOutA: 7.6)),
    dcVoltageClass: const Value('1000V'),
    isHybrid: const Value(true),
  ));

  await db.into(db.inverters).insert(InvertersCompanion.insert(
    name: 'STPH6-60 (Hybrid X 6)',
    manufacturer: const Value('SMA'),
    mppMinVoltage: const Value(120), // MPP range @ rated power
    mppMaxVoltage: const Value(850),
    powerKw: 6,
    mppCount: const Value(3),
    maxStringsPerMpp: const Value(1),
    minInputVoltage: const Value(120), // MPP range @ rated power start
    maxInputVoltage: const Value(850),
    iOutA: const Value(9.1), // max output current
    mcbA: Value(mcbRatingForInverter(powerKw: 6, acPhases: 3, iOutA: 9.1)),
    dcVoltageClass: const Value('1000V'),
    isHybrid: const Value(true),
  ));

  await db.into(db.inverters).insert(InvertersCompanion.insert(
    name: 'STPH8-60 (Hybrid X 8)',
    manufacturer: const Value('SMA'),
    mppMinVoltage: const Value(160), // MPP range @ rated power
    mppMaxVoltage: const Value(850),
    powerKw: 8,
    mppCount: const Value(3),
    maxStringsPerMpp: const Value(1),
    minInputVoltage: const Value(160), // MPP range @ rated power start
    maxInputVoltage: const Value(850),
    iOutA: const Value(12.1), // max output current
    mcbA: Value(mcbRatingForInverter(powerKw: 8, acPhases: 3, iOutA: 12.1)),
    dcVoltageClass: const Value('1000V'),
    isHybrid: const Value(true),
  ));

  await db.into(db.inverters).insert(InvertersCompanion.insert(
    name: 'STPH10-60 (Hybrid X 10)',
    manufacturer: const Value('SMA'),
    mppMinVoltage: const Value(200), // MPP range @ rated power
    mppMaxVoltage: const Value(850),
    powerKw: 10,
    mppCount: const Value(3),
    maxStringsPerMpp: const Value(1),
    minInputVoltage: const Value(90), // min PV input voltage
    maxInputVoltage: const Value(1000),
    maxInputCurrentPerMpp: const Value(18),
    maxShortCircuitCurrentPerMpp: const Value(24),
    iOutA: const Value(15.2), // max output current
    mcbA: Value(mcbRatingForInverter(powerKw: 10, acPhases: 3, iOutA: 15.2)),
    dcVoltageClass: const Value('1000V'),
    isHybrid: const Value(true),
  ));

  await db.into(db.inverters).insert(InvertersCompanion.insert(
    name: 'STPH12-60 (Hybrid X 12)',
    manufacturer: const Value('SMA'),
    mppMinVoltage: const Value(240), // MPP range @ rated power
    mppMaxVoltage: const Value(850),
    powerKw: 12,
    mppCount: const Value(3),
    maxStringsPerMpp: const Value(1),
    minInputVoltage: const Value(240), // MPP range @ rated power start
    maxInputVoltage: const Value(850),
    iOutA: const Value(18.2), // max output current
    mcbA: Value(mcbRatingForInverter(powerKw: 12, acPhases: 3, iOutA: 18.2)),
    dcVoltageClass: const Value('1000V'),
    isHybrid: const Value(true),
  ));

  await db.into(db.inverters).insert(InvertersCompanion.insert(
    name: 'STPH15-60 (Hybrid X 15)',
    manufacturer: const Value('SMA'),
    mppMinVoltage: const Value(300), // MPP range @ rated power
    mppMaxVoltage: const Value(850),
    powerKw: 15,
    mppCount: const Value(3),
    maxStringsPerMpp: const Value(1),
    minInputVoltage: const Value(300), // MPP range @ rated power start
    maxInputVoltage: const Value(850),
    iOutA: const Value(22.7), // max output current
    mcbA: Value(mcbRatingForInverter(powerKw: 15, acPhases: 3, iOutA: 22.7)),
    dcVoltageClass: const Value('1000V'),
    isHybrid: const Value(true),
  ));

  // ------------------------------------------------------------------
  // Battery
  // ------------------------------------------------------------------
  await db.into(db.batteries).insert(BatteriesCompanion.insert(
    name: 'Lynx Home F 10',
    manufacturer: const Value('GoodWe'),
    capacityKwh: 10,
    nominalVoltage: const Value(400),
    chemistry: const Value('LiFePO4'),
  ));

  // ------------------------------------------------------------------
  // Wallbox
  // ------------------------------------------------------------------
  await db.into(db.wallboxes).insert(WallboxesCompanion.insert(
    name: 'Wallbox 11 kW',
    manufacturer: const Value('Generic'),
    powerKw: 11,
    phases: const Value(3),
  ));

  // ------------------------------------------------------------------
  // Example project
  // ------------------------------------------------------------------
  final projectId = await db.into(db.projects).insert(ProjectsCompanion.insert(
    name: 'Beispielhaus Musterweg',
    address: const Value('Musterweg 1, 12345 Musterstadt'),
    latitude: const Value(51.0),
    longitude: const Value(10.0),
    createdAt: now,
    updatedAt: now,
  ));

  // A simple gabled roof (two sections) as a starting point.
  await db.into(db.roofs).insert(RoofsCompanion.insert(
    projectId: projectId,
    name: 'Südhang',
    polygon: '[[0,0],[12,0],[12,5],[0,5]]', // 12 m x 5 m, facing south
    lengthM: 12,
    widthM: 5,
    pitchDeg: const Value(30),
    azimuthDeg: const Value(180),
    type: const Value('pitched'),
    rafterWidthCm: const Value(6),
    rafterDepthCm: const Value(20),
    rafterSpacingCm: const Value(60),
    battenThicknessCm: const Value(2.5),
    rafterStraight: const Value(true),
    hasCounterBatten: const Value(false),
    tilesVisibleWidth: const Value(20),
    tilesVisibleHeight: const Value(8),
    tileOverlapCm: const Value(4.5),
    tileMaterial: const Value('clay'),
    hasSpareTiles: const Value(true),
    hasInsulation: const Value(true),
    insulationThicknessCm: const Value(18),
  ));

  await db.into(db.roofs).insert(RoofsCompanion.insert(
    projectId: projectId,
    name: 'Nordhang',
    polygon: '[[0,5],[12,5],[12,10],[0,10]]', // the other slope
    lengthM: 12,
    widthM: 5,
    pitchDeg: const Value(30),
    azimuthDeg: const Value(0),
    type: const Value('pitched'),
    rafterWidthCm: const Value(6),
    rafterDepthCm: const Value(20),
    rafterSpacingCm: const Value(60),
    battenThicknessCm: const Value(2.5),
    rafterStraight: const Value(true),
    hasCounterBatten: const Value(false),
    tilesVisibleWidth: const Value(20),
    tilesVisibleHeight: const Value(8),
    tileOverlapCm: const Value(4.5),
    tileMaterial: const Value('clay'),
    hasSpareTiles: const Value(false),
    hasInsulation: const Value(true),
    insulationThicknessCm: const Value(18),
  ));
}
