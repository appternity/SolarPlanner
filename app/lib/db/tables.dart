import 'package:drift/drift.dart';

/// Photovoltaic modules (solar panels) in the inventory.
class SolarModules extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  TextColumn get manufacturer => text().withDefault(const Constant(''))();
  /// Rated output in Watt (Pmax at STC).
  RealColumn get pMaxW => real()();
  RealColumn get vmp => real().withDefault(const Constant(0))();
  RealColumn get imp => real().withDefault(const Constant(0))();
  /// Open-circuit voltage in Volt.
  RealColumn get voc => real()();
  /// Short-circuit current in Ampere.
  RealColumn get isc => real()();
  /// Temperature coefficient of Voc in %/K (typically negative).
  RealColumn get vocTempCoeff => real().withDefault(const Constant(-0.3))();
  RealColumn get widthMm => real()();
  RealColumn get heightMm => real()();
  RealColumn get thicknessMm => real().withDefault(const Constant(30))();
  RealColumn get weightKg => real().nullable()();
  /// IEC protection class of the frame: 'I' (metallic frame, must be
  /// earthed) or 'II' (double insulated, no earthing needed). Null = unknown,
  /// treated as 'I' (conservative) by the VDE checks.
  TextColumn get frameClass => text().nullable()();
}

/// PV inverters in the inventory.
class Inverters extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  TextColumn get manufacturer => text().withDefault(const Constant(''))();
  /// Nominal AC power in kW.
  RealColumn get powerKw => real()();
  /// Number of MPPT trackers.
  IntColumn get mppCount => integer().withDefault(const Constant(1))();
  /// Strings that can be paralleled per MPPT.
  IntColumn get maxStringsPerMpp => integer().withDefault(const Constant(1))();
  RealColumn get minInputVoltage => real().nullable()();
  RealColumn get maxInputVoltage => real().nullable()();
  RealColumn get maxInputCurrentPerMpp => real().nullable()();
  RealColumn get maxShortCircuitCurrentPerMpp => real().nullable()();
  /// AC connection: 1 (single-phase) or 3 (three-phase). Drives the output
  /// current formula I_out = P/(U·cosφ) (VDE-AR-N 4105 §2).
  IntColumn get acPhases => integer().withDefault(const Constant(3))();
  /// DC voltage class of the device, e.g. '1000V' / '1500V'. Informational:
  /// the cold-Voc check uses min(1500, maxInputVoltage) regardless.
  TextColumn get dcVoltageClass => text().nullable()();
  /// Rated AC output current in A, straight from the datasheet. When null it
  /// is derived as P/(U·cosφ) with cos φ = 1.
  RealColumn get iOutA => real().nullable()();
  /// Recommended MCB (LS-Schalter) rating in A for the AC output connection,
  /// derived from [iOutA] (next IEC 60898 rating). Stored per inventory item;
  /// `validateProject` shows it for the project's active inverter only.
  IntColumn get mcbA => integer().nullable()();
  /// MPP operating voltage window from the datasheet (V). Planning aid for
  /// the VDE-AR-N 4105 §3.3 MPP check: `Vmp(T_cell,hot) >= mppMinVoltage` and
  /// `Vmp(T_cell,cold) <= mppMaxVoltage`. Null = not specified (check skipped).
  RealColumn get mppMinVoltage => real().nullable()();
  RealColumn get mppMaxVoltage => real().nullable()();
  /// Reactive power capability in kvar (VDE-AR-N 4105 §2, Q(U)/P(Q)).
  /// Informational only — no sizing is derived from it.
  RealColumn get qKvar => real().nullable()();
  BoolColumn get isHybrid => boolean().withDefault(const Constant(false))();
}

/// Battery storage systems in the inventory.
class Batteries extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  TextColumn get manufacturer => text().withDefault(const Constant(''))();
  /// Usable capacity in kWh.
  RealColumn get capacityKwh => real()();
  RealColumn get nominalVoltage => real().nullable()();
  TextColumn get chemistry => text().withDefault(const Constant('LiFePO4'))();
}

/// EV wallboxes in the inventory.
///
/// drift's naive pluralization would turn `Wallboxes` into `Wallboxe`, so the
/// data class name is pinned to `Wallbox`.
@DataClassName('Wallbox')
class Wallboxes extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  TextColumn get manufacturer => text().withDefault(const Constant(''))();
  /// Charging power in kW.
  RealColumn get powerKw => real()();
  IntColumn get phases => integer().withDefault(const Constant(1))();
  /// Required RCD type for the charging circuit: 'A' or 'B'. EV circuits
  /// require Type B (smooth DC fault detection, VDE 0100-534).
  TextColumn get rcdType => text().withDefault(const Constant('B'))();
  /// Rated current of the circuit breaker (LS) protecting the charging
  /// circuit in A. Null = not specified; `validateProject` then only asks for
  /// the value instead of checking I_charge <= breakerA (VDE 0100-443).
  RealColumn get breakerA => real().nullable()();
  /// Rated current of the RCD (FI) for the charging circuit in A. Null = not
  /// specified; same handling as [breakerA] (VDE 0100-534).
  RealColumn get rcdRatedA => real().nullable()();
}

/// A planning project for one site (house, farm, hall, ...).
class Projects extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  TextColumn get address => text().withDefault(const Constant(''))();
  RealColumn get latitude => real().withDefault(const Constant(51.0))();
  RealColumn get longitude => real().withDefault(const Constant(10.0))();
  /// Epoch milliseconds.
  IntColumn get createdAt => integer()();
  IntColumn get updatedAt => integer()();

  /// The module type the user is currently placing / auto-filling with.
  IntColumn get activeModuleTypeId => integer().nullable()();
  /// The inverter the user has selected for stringing.
  IntColumn get activeInverterId => integer().nullable()();

  // -- Site conditions (VDE checks) -------------------------------------

  /// Coldest expected ambient temperature in °C — fixed IEC cold condition
  /// (−25 °C, read-only in the UI). Cell temperature for the cold-Voc check
  /// is T_ambient,min − 10 K (planning assumption).
  RealColumn get tAmbientMinC => real().withDefault(const Constant(-25))();
  /// Hottest expected ambient temperature in °C — fixed at 40 °C (read-only
  /// in the UI). Cell temperature for the hot-Voc (start-up) check is
  /// T_ambient,max + 30 K.
  RealColumn get tAmbientMaxC => real().withDefault(const Constant(40))();
  /// Grid connection phases at the coupling device: 1 or 3.
  IntColumn get gridPhases => integer().withDefault(const Constant(3))();
  /// Agreed maximum feed-in power in kW (grid operator). Null = not set.
  RealColumn get maxFeedInKw => real().nullable()();
  /// Whether a main equipotential (Haupt-Potenzialausgleich) is available
  /// for module frames / inverter (VDE 0100-600 §542).
  BoolColumn get hasMainEquipotential =>
      boolean().withDefault(const Constant(false))();
  /// Whether the mounting is bolted. Ballasted (non-bolted) flat-roof
  /// mounting makes the natural protective conductor questionable → a
  /// dedicated PE conductor is recommended.
  BoolColumn get isBoltedMounting => boolean().withDefault(const Constant(true))();
}

/// Roof type: flat roof or one slope of a gabled (pitched) roof.
enum RoofType { flat, pitched }

/// Tile material for a gabled roof.
enum TileMaterial { clay, concrete }

extension RoofTypeX on RoofType {
  String get label => this == RoofType.flat ? 'Flachdach' : 'Steildach';

  static RoofType parse(String? value) =>
      value == 'flat' ? RoofType.flat : RoofType.pitched;
}

extension TileMaterialX on TileMaterial {
  String get label => this == TileMaterial.clay ? 'Ton' : 'Beton';

  static TileMaterial parse(String? value) =>
      value == 'concrete' ? TileMaterial.concrete : TileMaterial.clay;
}

/// A roof section: one rectangular slope in plan view plus pitch and facing.
///
/// The rectangle is defined by [lengthM] x [widthM]; the ridge (long edge)
/// runs perpendicular to [azimuthDeg], i.e. the roof faces/slopes down in
/// direction of [azimuthDeg]. The type and dimensions are fixed after
/// creation – to change them, delete the roof and add a new one.
class Roofs extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get projectId => integer()();
  TextColumn get name => text()();

  // -- Geometry (fixed after creation) ---------------------------------

  /// JSON-encoded list of [x, y] points in meters (plan view, y = north).
  TextColumn get polygon => text()();
  /// Roof length (ridge direction) in meters.
  RealColumn get lengthM => real()();
  /// Roof width (slope direction) in meters.
  RealColumn get widthM => real()();
  /// Roof pitch in degrees (0 = flat).
  RealColumn get pitchDeg => real().withDefault(const Constant(30))();
  /// Direction the roof faces/slopes down toward, degrees clockwise from
  /// north (180 = south).
  RealColumn get azimuthDeg => real().withDefault(const Constant(180))();

  // -- Type (fixed after creation) --------------------------------------

  /// 'flat' or 'pitched'.
  TextColumn get type => text().withDefault(const Constant('pitched'))();

  // -- Flachdach details (centimeters) ----------------------------------

  /// Height of the lowest point above ground in cm.
  RealColumn get flatBaseHeightCm => real().nullable()();
  /// Parapet (Attika) height in cm.
  RealColumn get flatAttikaHeightCm => real().nullable()();
  /// Parapet (Attika) width in cm.
  RealColumn get flatAttikaWidthCm => real().nullable()();

  // -- Steildach details (centimeters) ----------------------------------

  /// Rafter width in cm.
  RealColumn get rafterWidthCm => real().nullable()();
  /// Rafter depth in cm.
  RealColumn get rafterDepthCm => real().nullable()();
  /// Rafter spacing in cm.
  RealColumn get rafterSpacingCm => real().nullable()();
  /// Batten (Dachlatte) thickness in cm.
  RealColumn get battenThicknessCm => real().nullable()();
  /// Whether the rafters are straight.
  BoolColumn get rafterStraight => boolean().withDefault(const Constant(true))();
  /// Whether counter-battens (Konterlattung) are used.
  BoolColumn get hasCounterBatten => boolean().withDefault(const Constant(false))();

  // -- Steildach: tiles ---------------------------------------------------

  /// Number of visible tile courses across the slope width.
  IntColumn get tilesVisibleWidth => integer().nullable()();
  /// Number of visible tile courses up the slope height.
  IntColumn get tilesVisibleHeight => integer().nullable()();
  /// Tile overlap (Überdeckung) in cm.
  RealColumn get tileOverlapCm => real().nullable()();
  /// 'clay' (Ton) or 'concrete' (Beton).
  TextColumn get tileMaterial => text().withDefault(const Constant('clay'))();

  // -- Steildach: spares & insulation -------------------------------------

  /// Whether spare tiles are available.
  BoolColumn get hasSpareTiles => boolean().withDefault(const Constant(false))();
  /// Whether insulation (Aufsparrendämmung) is present.
  BoolColumn get hasInsulation => boolean().withDefault(const Constant(false))();
  /// Insulation thickness in cm.
  RealColumn get insulationThicknessCm => real().nullable()();

  // -- Module layout (auto-fill) ----------------------------------------

  /// Edge margin for auto-filled modules, in meters. Null = use the default
  /// (one tile row ≈ 5 cm for pitched, 15 cm clearance for flat roofs).
  RealColumn get moduleMarginM => real().nullable()();
  /// Gap between auto-filled modules, in meters. Null = use the default
  /// (2 cm clamp width).
  RealColumn get moduleGapM => real().nullable()();
}

/// Shading obstacles: chimneys, trees, neighboring buildings, roof edges.
class Obstacles extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get projectId => integer()();
  /// One of: chimney, tree, building, other.
  TextColumn get kind => text()();
  /// JSON-encoded polygon in meters (plan view).
  TextColumn get polygon => text()();
  /// Height above ground in meters.
  RealColumn get heightM => real()();
}

/// A module placed on a roof at a concrete position.
class PlacedModules extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get roofId => integer()();
  /// Reference to the inventory module type.
  IntColumn get moduleId => integer()();
  /// Center position on the roof plane in meters.
  RealColumn get x => real()();
  RealColumn get y => real()();
  /// Rotation around the vertical axis in degrees.
  RealColumn get rotationDeg => real().withDefault(const Constant(0))();
}

/// A DC string: modules connected in series, assigned to an inverter MPPT.
///
/// Named ModuleStrings (not Strings) because drift singularizes table names
/// for data classes – `Strings` would generate a `String` class that
/// collides with dart:core's String.
class ModuleStrings extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get projectId => integer()();
  TextColumn get name => text()();
  IntColumn get inverterId => integer().nullable()();
  /// Index of the MPPT tracker on the inverter (0-based).
  IntColumn get mppIndex => integer().nullable()();
  /// DC cable cross-section in mm² (VDE 0100-443). Null = not specified.
  RealColumn get dcCableMm2 => real().nullable()();
  /// Installed DC fuse rating in A. Null = not specified.
  RealColumn get fuseA => real().nullable()();
}

/// Membership of a placed module in a string (series order).
class StringModules extends Table {
  IntColumn get stringId => integer()();
  IntColumn get placedModuleId => integer()();
  /// Position in the series chain (0-based).
  IntColumn get position => integer().withDefault(const Constant(0))();

  @override
  Set<Column> get primaryKey => {stringId, placedModuleId};
}

/// A complete system variant: inverter + battery + wallbox choice.
class Scenarios extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get projectId => integer()();
  TextColumn get name => text()();
  IntColumn get inverterId => integer().nullable()();
  IntColumn get batteryId => integer().nullable()();
  IntColumn get wallboxId => integer().nullable()();
  TextColumn get notes => text().withDefault(const Constant(''))();
}

/// Cached computation results for a scenario.
class ScenarioResults extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get scenarioId => integer()();
  RealColumn get annualYieldKwh => real()();
  RealColumn get shadingLossPct => real()();
  RealColumn get specificYieldKwhPerKwp => real()();
  /// Epoch milliseconds.
  IntColumn get computedAt => integer()();
}
