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

  // ------------------------------------------------------------------
  // Haushaltsparameter (Eingabewerte) — komponenten.md §1
  // ------------------------------------------------------------------

  /// Number of household members.
  IntColumn get personen => integer().withDefault(const Constant(4))();

  /// Number of floors (Etagen).
  IntColumn get etagen => integer().withDefault(const Constant(2))();

  /// Whether the building has a basement (Keller).
  BoolColumn get keller => boolean().withDefault(const Constant(true))();

  /// Number of bathrooms.
  IntColumn get baeder => integer().withDefault(const Constant(2))();

  /// Number of kitchens.
  IntColumn get kuechen => integer().withDefault(const Constant(1))();

  /// Number of underfloor-heating zones (WP system).
  IntColumn get fbhZonen => integer().withDefault(const Constant(4))();

  /// Whether radiators are present (WP system).
  BoolColumn get radiatoren => boolean().withDefault(const Constant(false))();

  /// Whether there is a garden (WP system, affects heat-rejection sizing).
  BoolColumn get garten => boolean().withDefault(const Constant(true))();

  /// Heat-pump rated output in kW (WP system).
  RealColumn get wpKw => real().withDefault(const Constant(10.25))();

  /// Length of the district-heating / heat-source loop in metres.
  IntColumn get hwSchleifeM => integer().withDefault(const Constant(28))();

  /// PV plant size in kWp.
  RealColumn get pvKwp => real().withDefault(const Constant(10))();

  /// Wallbox rated output in kW.
  RealColumn get wbKw => real().withDefault(const Constant(11))();

  /// Wallbox installed outdoors?
  BoolColumn get wbAussen => boolean().withDefault(const Constant(true))();

  /// Wallbox has communication (LAN/WLAN/OCPP)?
  BoolColumn get wbKomm => boolean().withDefault(const Constant(true))();

  /// Wallbox uses PV surplus charging?
  BoolColumn get wbUeberschuss => boolean().withDefault(const Constant(false))();

  /// Backup power (BZA) required?
  BoolColumn get bza => boolean().withDefault(const Constant(false))();

  /// Wallbox cable run length in metres.
  IntColumn get wbLeitungM => integer().withDefault(const Constant(30))();

  /// Battery storage capacity in kWh.
  RealColumn get batKwh => real().withDefault(const Constant(10))();

  /// Number of battery storage units.
  IntColumn get batUnits => integer().withDefault(const Constant(2))();

  /// Battery DC fuse rating in amperes.
  RealColumn get batDcA => real().withDefault(const Constant(45))();

  /// Battery AC inverter output in kW.
  RealColumn get batAcKw => real().withDefault(const Constant(6.4))();

  /// Battery storage installed outdoors?
  BoolColumn get batAussen => boolean().withDefault(const Constant(true))();

  /// PV plant is planned for this project?
  BoolColumn get pvAnlage => boolean().withDefault(const Constant(false))();

  /// Battery storage is planned for this project?
  BoolColumn get batAnlage => boolean().withDefault(const Constant(false))();

  /// Wallbox is planned for this project?
  BoolColumn get wbAnlage => boolean().withDefault(const Constant(false))();

  /// Heat pump is planned for this project?
  BoolColumn get wpAnlage => boolean().withDefault(const Constant(false))();

  /// The heat pump from the inventory used for this project (null = none).
  IntColumn get activeHeatPumpId => integer().nullable()();
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

/// Inventory table for heat pumps (Wärmepumpen), seeded from the silver
/// layer (`data/datenblatt/silver/HYD.HEI.Waermepumpe/`).
class HeatPumps extends Table {
  IntColumn get id => integer().autoIncrement()();

  /// Display name, e.g. "Vaillant aroTHERM pro VWL 55/7.1 A 230V".
  TextColumn get displayName => text()();

  /// Manufacturer, e.g. "Vaillant".
  TextColumn get manufacturer => text()();

  /// Series name, e.g. "aroTHERM pro".
  TextColumn get seriesName => text()();

  /// Model number, e.g. "VWL 55/7.1 A 230V".
  TextColumn get modelNumber => text()();

  /// Heating capacity in kW at A7/W35.
  RealColumn get heatingCapacityKwA7W35 => real()();

  /// Electrical consumption in kW at A7/W35.
  RealColumn get electricalConsumptionKwA7W35 => real()();

  /// COP ratio at A7/W35.
  RealColumn get copRatioA7W35 => real()();

  /// Heating capacity in kW at A2/W35.
  RealColumn get heatingCapacityKwA2W35 => real()();

  /// Electrical consumption in kW at A2/W35.
  RealColumn get electricalConsumptionKwA2W35 => real()();

  /// COP ratio at A2/W35.
  RealColumn get copRatioA2W35 => real()();

  /// Heating capacity in kW at partial load.
  RealColumn get heatingCapacityKwPartialLoad => real()();

  /// Electrical consumption in kW at partial load.
  RealColumn get electricalConsumptionKwPartialLoad => real()();

  /// COP ratio at partial load.
  RealColumn get copRatioPartialLoad => real()();

  /// Cooling capacity in kW (null if not available).
  RealColumn get coolingCapacityKw => real().nullable()();

  /// Electrical consumption in kW for cooling.
  RealColumn get electricalConsumptionKwCooling => real().nullable()();

  /// EER ratio (null if not available).
  RealColumn get eerRatio => real().nullable()();

  /// Annual heating efficiency in percent (as string, e.g. "198 / 145").
  TextColumn get annualHeatingEfficiencyPercent => text()();

  /// Compressor nominal voltage (V).
  IntColumn get compressorVoltageNominalVolts => integer()();

  /// Compressor frequency in Hz.
  IntColumn get compressorFrequencyHz => integer()();

  /// Sound level (ERP) in dB(A).
  RealColumn get soundLevelErpDbA => real()();

  /// Max sound level day/night in dB(A) (as string, e.g. "57.7 / 48.2").
  TextColumn get maxSoundLevelDayNightDbA => text()();

  /// Dimensions unpacked (mm): width.
  IntColumn get dimensionsUnpackedWidthMm => integer()();

  /// Dimensions unpacked (mm): depth.
  IntColumn get dimensionsUnpackedDepthMm => integer()();

  /// Dimensions unpacked (mm): height.
  IntColumn get dimensionsUnpackedHeightMm => integer()();

  /// Weight in kg.
  RealColumn get weightKg => real()();

  /// Refrigerant type, e.g. "R290".
  TextColumn get refrigerantType => text()();

  /// GWP (EU regulation) value.
  RealColumn get gwpEuRegulationValue => real()();

  /// Refrigerant quantity in kg CO2 equivalent.
  RealColumn get refrigerantQuantityKgCo2Equivalent => real()();

  /// CO2 equivalent per ton.
  RealColumn get co2EquivalentPerTon => real()();

  /// Energy efficiency class at 35°C/55°C (e.g. "III", empty if not classified).
  TextColumn get energyEfficiencyClass35C55C => text()();
}

/// Heating loops (Heizschleifen) for a project.
class HeatLoops extends Table {
  IntColumn get id => integer().autoIncrement()();

  /// The project this loop belongs to.
  IntColumn get projectId => integer().references(Projects, #id)();

  /// Name of the loop (e.g. "Erdgeschoss Fußboden").
  TextColumn get name => text()();

  /// Loop type: "radiator" or "underfloor".
  TextColumn get loopType => text().withDefault(const Constant('radiator'))();

  /// Nominal heating power in kW.
  RealColumn get nominalKw => real().withDefault(const Constant(0))();

  /// Flow temperature in °C.
  IntColumn get flowTempC => integer().withDefault(const Constant(55))();
}

// ===========================================================================
// Heat Pump Components Inventory (27 tables + shared status table)
// ===========================================================================

/// Component status values used by the state machine.
///
/// Each status is project-scoped via the [ComponentStatus] table.
enum ComponentStatus {
  /// Nothing assigned yet, but component is required.
  offen,

  /// A manufacturer/model is assigned, but not yet installed.
  inPlanung,

  /// Planned but no specific manufacturer/model known.
  geplant,

  /// Installed, manufacturer/model assigned.
  eingebaut,

  /// Neither planned nor required.
  nichtBenotigt,
}

/// All 28 component types from `komponenten.md` assigned to the Wärmepumpe
/// system (plus shared components visible in the Projekt tab).
///
/// This enum provides type-safe references to every component type.
enum ComponentType {
  // -- Hydraulische Komponenten (22) --
  boilerTww,
  hwVerteiler,
  zirkulationspumpe,
  // Waermepumpe → reuses existing `HeatPumps` table (skip)
  rueckflussverhinderer,
  schmutzfanger,
  durchflusswaechter,
  pufferspeicher,
  plattenwaermetauscher,
  safetyValve,
  membranausdehnungsgefaess,
  entluftungsventil,
  heizkreispumpe,
  absperrventil,
  fbhVerteiler,
  fbhSchleife,
  mischbatterie,
  rfvGartenanschluss,
  fuellwasserZuleitung,
  kaltwasserVerbraucher,
  // -- Elektrische Komponenten (6) --
  lsSchalter,
  fiSchutzschalter,
  zuleitungStarkstrom,
  trennschalter,
  klemmenleiste,
  peAnschluss,
  // -- Shared components --
  hpaAnschluss,
}

/// Returns the component type ID string (e.g. "HYD.WAR.Boiler_TWW").
extension ComponentTypeExt on ComponentType {
  String get idString {
    switch (this) {
      case ComponentType.boilerTww:
        return 'HYD.WAR.Boiler_TWW';
      case ComponentType.hwVerteiler:
        return 'HYD.WAR.HW_Verteiler';
      case ComponentType.zirkulationspumpe:
        return 'HYD.WAR.Zirkulationspumpe';
      case ComponentType.rueckflussverhinderer:
        return 'HYD.HEI.Rueckflussverhinderer';
      case ComponentType.schmutzfanger:
        return 'HYD.HEI.Schmutzfanger_Filter';
      case ComponentType.durchflusswaechter:
        return 'HYD.HEI.Durchflusswaechter';
      case ComponentType.pufferspeicher:
        return 'HYD.HEI.Pufferspeicher';
      case ComponentType.plattenwaermetauscher:
        return 'HYD.HEI.Plattenwaermetauscher';
      case ComponentType.safetyValve:
        return 'HYD.HEI.Sicherheitsventil_3bar';
      case ComponentType.membranausdehnungsgefaess:
        return 'HYD.HEI.Membranausdehnungsgefaess';
      case ComponentType.entluftungsventil:
        return 'HYD.HEI.Entluftungsventil_auto';
      case ComponentType.heizkreispumpe:
        return 'HYD.HEI.Pumpe_Heizkreis';
      case ComponentType.absperrventil:
        return 'HYD.HEI.Absperrventil_Vorlauf';
      case ComponentType.fbhVerteiler:
        return 'HYD.HEI.FBH_Verteiler';
      case ComponentType.fbhSchleife:
        return 'HYD.HEI.FBH_Schleife';
      case ComponentType.mischbatterie:
        return 'HYD.WAR.Mischbatterie';
      case ComponentType.rfvGartenanschluss:
        return 'HYD.KAL.RFV_Gartenanschluss';
      case ComponentType.fuellwasserZuleitung:
        return 'HYD.HEI.Zuleitung_Fuellwasser';
      case ComponentType.kaltwasserVerbraucher:
        return 'HYD.KAL.Verbraucher_nur_KW';
      case ComponentType.lsSchalter:
        return 'ELE.STK.LS_Schalter_WP';
      case ComponentType.fiSchutzschalter:
        return 'ELE.STK.FI_Schutzschalter';
      case ComponentType.zuleitungStarkstrom:
        return 'ELE.STK.Zuleitung_Starkstrom';
      case ComponentType.trennschalter:
        return 'ELE.SCH.Trennschalter';
      case ComponentType.klemmenleiste:
        return 'ELE.SCH.Klemmenleiste';
      case ComponentType.peAnschluss:
        return 'ELE.ERD.PE_Anschluss';
      case ComponentType.hpaAnschluss:
        return 'ELE.ERD.HPA_Anschluss';
    }
  }

  String get displayName {
    switch (this) {
      case ComponentType.boilerTww:
        return 'Warmwasser-Boiler';
      case ComponentType.hwVerteiler:
        return 'HW-Verteiler';
      case ComponentType.zirkulationspumpe:
        return 'Zirkulationspumpe';
      case ComponentType.rueckflussverhinderer:
        return 'Rückflussverhinderer';
      case ComponentType.schmutzfanger:
        return 'Schmutzfänger';
      case ComponentType.durchflusswaechter:
        return 'Durchflusswächter';
      case ComponentType.pufferspeicher:
        return 'Pufferspeicher';
      case ComponentType.plattenwaermetauscher:
        return 'Plattenwärmetauscher';
      case ComponentType.safetyValve:
        return 'Sicherheitsventil 3 bar';
      case ComponentType.membranausdehnungsgefaess:
        return 'Membranausdehnungsgefäß';
      case ComponentType.entluftungsventil:
        return 'Entlüftungsventil';
      case ComponentType.heizkreispumpe:
        return 'Heizkreispumpe';
      case ComponentType.absperrventil:
        return 'Absperrventil';
      case ComponentType.fbhVerteiler:
        return 'FBH-Verteiler';
      case ComponentType.fbhSchleife:
        return 'FBH-Schleife';
      case ComponentType.mischbatterie:
        return 'Mischbatterie';
      case ComponentType.rfvGartenanschluss:
        return 'RFV Gartenanschluss';
      case ComponentType.fuellwasserZuleitung:
        return 'Füllwasser-Zuleitung';
      case ComponentType.kaltwasserVerbraucher:
        return 'Kaltwasser-Verbraucher';
      case ComponentType.lsSchalter:
        return 'LS-Schalter WP';
      case ComponentType.fiSchutzschalter:
        return 'FI-Schutzschalter';
      case ComponentType.zuleitungStarkstrom:
        return 'Zuleitung Starkstrom';
      case ComponentType.trennschalter:
        return 'Trennschalter';
      case ComponentType.klemmenleiste:
        return 'Klemmenleiste';
      case ComponentType.peAnschluss:
        return 'PE-Anschluss';
      case ComponentType.hpaAnschluss:
        return 'HPA-Anschluss';
    }
  }
}

/// Shared inventory items table — all 28 component types share this table.
///
/// Each row represents one inventory item (manufacturer/model) that can be
/// assigned to any component type. The [componentType] column identifies
/// which of the 28 types this item belongs to.
class InventoryItems extends Table {
  IntColumn get id => integer().autoIncrement()();

  /// Display name, e.g. "Vaillant aroTHERM pro VWL 115".
  TextColumn get name => text()();

  /// Manufacturer, e.g. "Vaillant".
  TextColumn get manufacturer => text().withDefault(const Constant(''))();

  /// Series name.
  TextColumn get seriesName => text().withDefault(const Constant(''))();

  /// Model number.
  TextColumn get modelNumber => text().withDefault(const Constant(''))();

  /// Which of the 28 component types this item belongs to.
  TextColumn get componentType => text()();
}

/// Status mapping table — project-scoped state machine.
///
/// Each row maps a project + inventory item to a status. This is the single
/// source of truth for the component state machine.
class ComponentStatusTable extends Table {
  IntColumn get id => integer().autoIncrement()();

  /// The project this status belongs to.
  IntColumn get projectId => integer().references(Projects, #id)();

  /// Reference to the inventory item (from [InventoryItems]).
  IntColumn get inventoryItemId => integer().references(InventoryItems, #id)();

  /// Current status: Offen, In Planung, Geplant, Eingebaut, Nicht Benötigt.
  TextColumn get status => text().withDefault(const Constant('Offen'))();

  /// Is this component required for the project?
  BoolColumn get required => boolean().withDefault(const Constant(false))();

  /// Calculated quantity (from formulas).
  IntColumn get quantity => integer().withDefault(const Constant(0))();
}

// -- 27 inventory tables (one per component type) --

class Boiler extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  TextColumn get manufacturer => text().withDefault(const Constant(''))();
  TextColumn get seriesName => text().withDefault(const Constant(''))();
  TextColumn get modelNumber => text().withDefault(const Constant(''))();
  /// Nominal volume in litres (CALC_Boiler_Volumen).
  IntColumn get volumeLitres => integer().withDefault(const Constant(200))();
}

class HwVerteiler extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  TextColumn get manufacturer => text().withDefault(const Constant(''))();
  TextColumn get seriesName => text().withDefault(const Constant(''))();
  TextColumn get modelNumber => text().withDefault(const Constant(''))();
  /// Number of zones served.
  IntColumn get zones => integer().withDefault(const Constant(1))();
}

class Zirkulationspumpe extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  TextColumn get manufacturer => text().withDefault(const Constant(''))();
  TextColumn get seriesName => text().withDefault(const Constant(''))();
  TextColumn get modelNumber => text().withDefault(const Constant(''))();
  RealColumn get flowRateLMin => real().withDefault(const Constant(0))();
  RealColumn get headPressureM => real().withDefault(const Constant(0))();
  RealColumn get eeiRating => real().withDefault(const Constant(0.2))();
}

class Rueckflussverhinderer extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  TextColumn get manufacturer => text().withDefault(const Constant(''))();
  TextColumn get seriesName => text().withDefault(const Constant(''))();
  TextColumn get modelNumber => text().withDefault(const Constant(''))();
  IntColumn get dnSize => integer().withDefault(const Constant(25))();
}

class Schmutzfanger extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  TextColumn get manufacturer => text().withDefault(const Constant(''))();
  TextColumn get seriesName => text().withDefault(const Constant(''))();
  TextColumn get modelNumber => text().withDefault(const Constant(''))();
  /// Filter mesh size in mm (typically 2).
  RealColumn get filterSizeMm => real().withDefault(const Constant(2))();
}

class Durchflusswaechter extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  TextColumn get manufacturer => text().withDefault(const Constant(''))();
  TextColumn get seriesName => text().withDefault(const Constant(''))();
  TextColumn get modelNumber => text().withDefault(const Constant(''))();
  /// Minimum flow rate in m³/h (CALC_Min_Durchfluss).
  RealColumn get minFlowM3H => real().withDefault(const Constant(0.5))();
}

class Pufferspeicher extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  TextColumn get manufacturer => text().withDefault(const Constant(''))();
  TextColumn get seriesName => text().withDefault(const Constant(''))();
  TextColumn get modelNumber => text().withDefault(const Constant(''))();
  /// Volume in litres (CALC_Puffer_Volumen).
  IntColumn get volumeLitres => integer().withDefault(const Constant(500))();
}

class Plattenwaermetauscher extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  TextColumn get manufacturer => text().withDefault(const Constant(''))();
  TextColumn get seriesName => text().withDefault(const Constant(''))();
  TextColumn get modelNumber => text().withDefault(const Constant(''))();
  IntColumn get plates => integer().withDefault(const Constant(30))();
  RealColumn get areaM2 => real().withDefault(const Constant(2.0))();
}

class SafetyValve extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  TextColumn get manufacturer => text().withDefault(const Constant(''))();
  TextColumn get seriesName => text().withDefault(const Constant(''))();
  TextColumn get modelNumber => text().withDefault(const Constant(''))();
  /// Opening pressure in bar (default 3).
  RealColumn get openingPressureBar => real().withDefault(const Constant(3))();
}

class Membranausdehnungsgefaess extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  TextColumn get manufacturer => text().withDefault(const Constant(''))();
  TextColumn get seriesName => text().withDefault(const Constant(''))();
  TextColumn get modelNumber => text().withDefault(const Constant(''))();
  /// Volume in litres (CALC_MAG_Volumen).
  IntColumn get volumeLitres => integer().withDefault(const Constant(10))();
}

class Entluftungsventil extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  TextColumn get manufacturer => text().withDefault(const Constant(''))();
  TextColumn get seriesName => text().withDefault(const Constant(''))();
  TextColumn get modelNumber => text().withDefault(const Constant(''))();
  IntColumn get dnSize => integer().withDefault(const Constant(25))();
}

class Heizkreispumpe extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  TextColumn get manufacturer => text().withDefault(const Constant(''))();
  TextColumn get seriesName => text().withDefault(const Constant(''))();
  TextColumn get modelNumber => text().withDefault(const Constant(''))();
  RealColumn get flowRateLMin => real().withDefault(const Constant(0))();
  RealColumn get headPressureM => real().withDefault(const Constant(0))();
  RealColumn get eeiRating => real().withDefault(const Constant(0.2))();
}

class Absperrventil extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  TextColumn get manufacturer => text().withDefault(const Constant(''))();
  TextColumn get seriesName => text().withDefault(const Constant(''))();
  TextColumn get modelNumber => text().withDefault(const Constant(''))();
  IntColumn get dnSize => integer().withDefault(const Constant(25))();
}

class FbhVerteiler extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  TextColumn get manufacturer => text().withDefault(const Constant(''))();
  TextColumn get seriesName => text().withDefault(const Constant(''))();
  TextColumn get modelNumber => text().withDefault(const Constant(''))();
  IntColumn get zones => integer().withDefault(const Constant(1))();
}

class FbhSchleife extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  TextColumn get manufacturer => text().withDefault(const Constant(''))();
  TextColumn get seriesName => text().withDefault(const Constant(''))();
  TextColumn get modelNumber => text().withDefault(const Constant(''))();
  RealColumn get pipeLengthM => real().withDefault(const Constant(0))();
  IntColumn get pipeDiameterMm => integer().withDefault(const Constant(16))();
}

class Mischbatterie extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  TextColumn get manufacturer => text().withDefault(const Constant(''))();
  TextColumn get seriesName => text().withDefault(const Constant(''))();
  TextColumn get modelNumber => text().withDefault(const Constant(''))();
  IntColumn get dnSize => integer().withDefault(const Constant(25))();
}

class RfvGartenanschluss extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  TextColumn get manufacturer => text().withDefault(const Constant(''))();
  TextColumn get seriesName => text().withDefault(const Constant(''))();
  TextColumn get modelNumber => text().withDefault(const Constant(''))();
  IntColumn get dnSize => integer().withDefault(const Constant(25))();
}

class FuellwasserZuleitung extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  TextColumn get manufacturer => text().withDefault(const Constant(''))();
  TextColumn get seriesName => text().withDefault(const Constant(''))();
  TextColumn get modelNumber => text().withDefault(const Constant(''))();
  IntColumn get pipeDiameterMm => integer().withDefault(const Constant(20))();
}

class KaltwasserVerbraucher extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  TextColumn get manufacturer => text().withDefault(const Constant(''))();
  TextColumn get seriesName => text().withDefault(const Constant(''))();
  TextColumn get modelNumber => text().withDefault(const Constant(''))();
  IntColumn get count => integer().withDefault(const Constant(1))();
}

class LsSchalter extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  TextColumn get manufacturer => text().withDefault(const Constant(''))();
  TextColumn get seriesName => text().withDefault(const Constant(''))();
  TextColumn get modelNumber => text().withDefault(const Constant(''))();
  IntColumn get currentRatingA => integer().withDefault(const Constant(16))();
  IntColumn get poleCount => integer().withDefault(const Constant(3))();
  TextColumn get charType => text().withDefault(const Constant('B'))();
}

class FiSchutzschalter extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  TextColumn get manufacturer => text().withDefault(const Constant(''))();
  TextColumn get seriesName => text().withDefault(const Constant(''))();
  TextColumn get modelNumber => text().withDefault(const Constant(''))();
  IntColumn get currentRatingA => integer().withDefault(const Constant(40))();
  IntColumn get sensitivityMa => integer().withDefault(const Constant(30))();
  TextColumn get type => text().withDefault(const Constant('A'))();
}

class ZuleitungStarkstrom extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  TextColumn get manufacturer => text().withDefault(const Constant(''))();
  TextColumn get seriesName => text().withDefault(const Constant(''))();
  TextColumn get modelNumber => text().withDefault(const Constant(''))();
  IntColumn get crossSectionMm2 => integer().withDefault(const Constant(6))();
  RealColumn get lengthM => real().withDefault(const Constant(0))();
  TextColumn get conductorMaterial => text().withDefault(const Constant('Cu'))();
}

class Trennschalter extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  TextColumn get manufacturer => text().withDefault(const Constant(''))();
  TextColumn get seriesName => text().withDefault(const Constant(''))();
  TextColumn get modelNumber => text().withDefault(const Constant(''))();
  IntColumn get currentRatingA => integer().withDefault(const Constant(16))();
  IntColumn get poleCount => integer().withDefault(const Constant(3))();
}

class Klemmenleiste extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  TextColumn get manufacturer => text().withDefault(const Constant(''))();
  TextColumn get seriesName => text().withDefault(const Constant(''))();
  TextColumn get modelNumber => text().withDefault(const Constant(''))();
  IntColumn get busWidth => integer().withDefault(const Constant(12))();
}

class PeAnschluss extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  TextColumn get manufacturer => text().withDefault(const Constant(''))();
  TextColumn get seriesName => text().withDefault(const Constant(''))();
  TextColumn get modelNumber => text().withDefault(const Constant(''))();
  IntColumn get wireCrossSectionMm2 => integer().withDefault(const Constant(4))();
}

class HpaAnschluss extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  TextColumn get manufacturer => text().withDefault(const Constant(''))();
  TextColumn get seriesName => text().withDefault(const Constant(''))();
  TextColumn get modelNumber => text().withDefault(const Constant(''))();
  IntColumn get conductorCrossSectionMm2 => integer().withDefault(const Constant(4))();
}
