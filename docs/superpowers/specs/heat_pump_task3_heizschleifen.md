# Task 3: Heizschleifen (Heizkreise) — Datenmodell

Status: Design genehmigt, TDD-Implementierung läuft.
Teil der Wärmepumpen-Funktion (Feature "Heizung / Wärme").

## Ziel

Das Heizsystem eines Projekts wird als **Liste von Heizschleifen (Heizkreisen)** modelliert.
Jede Schleife hat einen Namen, eine Art (Fußboden/Radiator/…), Nennlast und Vorlauftemperatur.
Die Wärmepumpe (Bestand aus `seeds_waermepumpe.json`) wird pro Projekt referenziert;
die Schleifen hängen zur Laufzeit an dem aktiven Wärmepumpen-Projekt.

## Datenmodell (Drift)

### Neue Tabelle `heat_loops` (in `app/lib/db/tables.dart`)

```dart
@DataClassName('HeatLoop')
class HeatLoops extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().withLength(min: 1, max: 80)();
  TextColumn get loopType => text().withDefault(const Constant('radiator'))(); // radiator | underfloor
  RealColumn get nominalKw => real().withDefault(const Constant(0))();
  IntColumn get flowTempC => integer().withDefault(const Constant(55))(); // Vorlauftemperatur
  IntColumn returnTempC => integer().withDefault(const Constant(45))(); // Rücklauftemperatur
  IntColumn get volumeL => integer().withDefault(const Constant(0))(); // Wasserinhalt (optional, 0 = unbekannt)
}
```

- **Kein FK zu Projects**: Schleifen sind projektweit über `activeHeatPumpId`-Logik erreichbar —
  aber das wäre ein Zirkel. Stattdessen: Schleifen gehören zum Projekt über eine
  `projectId`-Spalte (FK, ON DELETE CASCADE), analog zu `Roofs`.

Korrektur: **`projectId` FK hinzufügen** (NOT NULL, CASCADE) — Heizschleifen sind
projektgebundene Daten wie Dächer.

```dart
IntColumn get projectId => integer().references(Projects, #id)();
```

### Neue Tabelle `heat_pumps` (Bestand, analog Inverters/Batteries/Wallboxes)

Alle 25 Eigenschaften aus `data/datenblatt/silver/HYD.HEI.Waermepumpe/seeds_waermepumpe.json`
1:1 als Spalten. Nullable für kühlspezifische/optionale Felder, da nicht alle Modelle sie haben:

| JSON-Property | Spalte | Typ |
|---|---|---|
| `name` | `displayName` | Text (unique) |
| `manufacturer` | `manufacturer` | Text |
| `model_number` | `modelName` | Text |
| `heat_pump_type` | `hpType` | Text (air_to_water) |
| `nominal_heating_capacity_kw` | `heatingCapacityKw` | Real |
| `heat_source_temperature_c` | `sourceTempC` | Int (Sollwert) |
| `power_input_heating_kw` | `heatingInputKw` | Real (nullable) |
| `scop_35c7c` / `cop_35c7c` | `scop35C7C`, `cop35C7C` | Real (nullable) |
| `scop_55c7c` / `cop_55c7c` | `scop55C7C`, `cop55C7C` | Real (nullable) |
| `cooling_capacity_kw` | `coolingCapacityKw` | Real (nullable) |
| `eer_ratio_27c16c` / `eerp_cooling_class` | `eer27C16C`, `coolingClass` | Real/Text (nullable) |
| `energy_efficiency_class_35c7c` / `_55c7c` | `effClass35C7C`, `effClass55C7C` | Text (nullable) |
| `energy_efficiency_class_35c55c` | `effClass35C55C` | Text (nullable) |
| `max_flow_temperature_c` / `_min` | `flowTempMaxC`, `flowTempMinC` | Int (nullable) |
| `water_volume_l` / `_max_flow_rate_l_min` | `waterVolumeL`, `flowRateMaxLMin` | Int/Real (nullable) |
| `compressor_type`, `refrigerant`, `min_start_temp_c` | gleichnamig | Text/Text/Int (nullable) |
| `dimensions_unpacked_mm` [3] | `widthMm`, `depthMm`, `heightMm` | Int (nullable) |
| `weight_kg_unpacked` / `_packed`, `ac_supply_voltage_v_phases_hz`, `sound_power_level_db_a_3m` | gleichnamig | Real/Text (nullable) |

### Projekte-Verknüpfung (`Projects` in tables.dart)

Neue Spalte: `IntColumn get activeHeatPumpId => integer().nullable()();`
(Analog zu `activeInverterId`/`activeWallboxId`; FK wird über Drift-Relation, nicht
als hartes DB-FK — konsistent mit bestehenden `active*Id`-Spalten.)

### Migration (schemaVersion 9 → 10, `app/lib/db/database.dart`)

- `onUpgrade`: idempotente Guards
  - `_createTableIfMissing` für `heat_pumps`, `heat_loops` (CREATE TABLE IF NOT EXISTS)
  - `_addColumnIfMissing(projects, activeHeatPumpId INTEGER REFERENCES heat_pumps(id))`
- `schemaVersion => 10`.

### Seeding (`app/lib/db/seed.dart`)

Neue Funktion `heatPumpSeeds()` (hartkodiert, analog zu den anderen Beständen —
die Silver-JSONs werden nicht zur Laufzeit eingelesen, vgl. `docs/seed-data.md`).
`seedIfEmpty()` bekommt einen Block: 3 Vaillant aroTHERM pro Modelle eintragen,
wenn `heat_pumps` leer ist.

## TDD-Ablauf

1. **RED**: `app/test/heat_pump_test.dart`
   - Tabelle `heat_loops` existiert nach Migration (Insert/Read)
   - Projekt-Verknüpfung `activeHeatPumpId` setzbar
   - Migration idempotent (doppeltes onUpgrade / Fresh-DB == v9→v10)
   - Seed liefert 3 Wärmepumpen, `displayName` korrekt
2. **GREEN**: tables.dart + database.dart (v10) + seed.dart, build_runner
3. **REFACTOR**: Typprüfungen, `dart analyze` sauber

## Abgrenzung / Folgetasks

- UI (Dialog "Heizschleifen verwalten") → Task 4
- VDE/thermische Validierung (Σ Nennlast vs. Wärmepumpen-Leistung) → später,
  gehört in `docs/vde-norm-ideas.md`
