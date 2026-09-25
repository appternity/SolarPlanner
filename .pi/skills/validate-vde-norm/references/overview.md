# Overview — scope & interplay of the five standards

This file is the map. Load a detailed reference only when its topic comes up.

## What each standard governs (and what SolarPlanner can check)

| Standard | Scope | Relevance for a PV planning tool |
|---|---|---|
| **DIN VDE 0100-443** (IEC 60364-4-43) | Protection against overcurrent: conductor thermal protection, short-circuit clearing ≤ 5 s, protective device selection & coordination (Stufung) | Cable cross-section checks for DC strings and AC feed-in; fuse/MCB sizing per string & inverter output |
| **DIN VDE 0100-534** (IEC 60364-4-43 → actually -534: IEC 60364-4-41) | Protection against touch voltage / electric shock: RCD (FI-Schutzschalter) requirements, residual current limits | Whether an RCD is required at the inverter AC side / wallbox; 30 mA vs 300 mA class selection |
| **DIN VDE 0100-712** (IEC 60364-7-712) | Special installations: **photovoltaic systems** — DC circuit rules, string limits, earthing of module frames, separation from AC | The most PV-specific one: max modules per string by system voltage class (≤ 60 V / ≤ 1500 V DC), string I_sc vs fuse, frame earthing |
| **VDE-AR-N 4105** (2018) | Technical rules for grid connection of generation systems up to 30 kW (now largely superseded by VDE-AR-E / DIN VDE 4110 for new installs, but still the reference many installers use) | Inverter AC output vs connection point, feed-in limits, protection at the coupling device (Kuppelstelle), metering |
| **DIN VDE 0100-600** (IEC 60364-5-54) | Earthing arrangements & equipotential bonding: PE conductor sizing, module/inverter frame grounding, natural vs artificial conductors | Whether frames must be earthed (DC voltage class), PE cross-section for PV strings, equipotential of the roof |

> **Note on edition:** VDE-AR-N 4105:2018 has been replaced by **DIN VDE
> 4110 / VDE-AR-E** for installations after mid-2023. When validating, mention
> both: check against 4105 (legacy) and flag where DIN VDE 4110 differs.

## System voltage classes (DIN VDE 0100-712 / IEC 60364-7-712)

The class drives several hard limits and is the key to string sizing:

- **Class A:** DC ≤ 60 V (open-circuit) — e.g. small balcony systems
- **Class B:** 60 V < DC ≤ 1500 V — standard residential PV
- **Class C:** > 1500 V DC (limited to trained persons / commercial)

For residential SolarPlanner projects the target is **Class B**:
- `Voc` of a string at **coldest expected ambient temperature** must stay ≤ 1500 V
- `Voc` of a string at **hottest conditions** must stay ≥ inverter min. start-up voltage
- Inverters rated for 1500 V DC are the norm; modules ~40–60 V Voc each →
  roughly **25–35 modules per string** is the typical ceiling

## The five mandatory checks a PV planner must be able to run

1. **String voltage window** (VDE-AR-N 4105 / VDE 0100-712):
   `Voc_min ≤ Voc_string(T_cold) ≤ 1500 V` and
   `Voc_string(T_hot) ≥ U_start(inverter)` — needs module `voc`,
   `vocTempCoeff` (%/K), site min/max ambient temperature, inverter
   `minInputVoltage`, `maxInputVoltage`.

2. **String current vs inverter input** (VDE-AR-N 4105):
   `Isc_string ≤ I_sc,max(MPPT)` and, for paralleled strings on one MPPT:
   `n_strings · Isc_string ≤ I_sc,max(MPPT)` — needs module `isc`,
   inverter `maxShortCircuitCurrentPerMpp`.

3. **DC cable & fuse sizing** (VDE 0100-443):
   `I_B ≤ I_N(fuse) ≤ I_Z(cable)`; fuse rating = next standard value above
   `Isc` of **one** string (never the parallel sum); cable sized for continuous
   current with temperature correction.

4. **AC side: inverter output, RCD, feed-in** (VDE 0100-534 / VDE-AR-N 4105):
   inverter `powerKw` vs connection point rating; RCD class (30 mA for
   socket circuits incl. wallbox, 300 mA + upstream protection often accepted
   for inverter feed-in per local rules); coupling device (Kuppelstelle) with
   main switch.

5. **Earthing** (VDE 0100-600 / VDE 0100-712):
   module frames and inverter must be connected to the equipotential (PE);
   PE conductor cross-section per 0100-600 tables; on flat roofs the
   equipotential of the roof structure must be considered.

## Data SolarPlanner needs at PROJECT level (not per inventory item)

These are site-specific and must be persisted on `Projects` (or a new
`SiteConditions` table):

- **T_min / T_max ambient** (°C) — coldest/hottest expected, e.g. from
  weather data for the latitude/longitude already stored. Needed for check #1.
- **Grid connection point**: voltage class (230 V / 400 V), phases,
  max. feed-in power (kW) agreed with the grid operator — needed for #4.
- **Earthing concept**: existing equipotential available? (bool) — needed for #5.
- **DC system voltage class** (A/B/C) — derived, but worth storing as a
  computed flag so warnings can key off it.

## How to use this in the app (mapping)

- Inventory properties → `SolarModules`, `Inverters`, `Batteries`,
  `Wallboxes` in `app/lib/db/tables.dart`.
- Project-level site data → currently **missing** (see property audit in the
  skill output).
- Existing calculation to validate first: `autoAssignStrings()` in
  `app/lib/features/editor/editor_controller.dart` — it checks only
  `maxInputVoltage` and per-string `isc`; see the detailed gaps in
  `vde-ar-n-4105.md`.
