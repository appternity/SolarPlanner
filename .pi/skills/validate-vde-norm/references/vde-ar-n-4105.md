# VDE-AR-N 4105 — Grid connection of PV systems (≤ 30 kW)

Technical rules for connecting generation systems to the low-voltage grid.
**Edition note:** VDE-AR-N 4105:2018 has been largely superseded by
**DIN VDE 4110 / VDE-AR-E** for installations after mid-2023. Validate against
4105 (still widely used by installers) and flag where DIN VDE 4110 differs
(e.g. stricter requirements on protection at the coupling device, metering).

## 1. Scope & system categories

- Applies to generation systems up to **30 kW** (single-phase) / higher for
  three-phase, connected at the low-voltage level.
- SolarPlanner's residential projects fall squarely in this scope.

## 2. Inverter AC output vs connection point (Kuppelstelle)

### Power limit
- The inverter's rated AC power must not exceed the **agreed feed-in power**
  with the grid operator (`maxFeedInKw`, project-level — *missing in app*).
- For single-phase connection: typically limited to **11.5 kW** (or the grid
  operator's lower limit) per connection point; three-phase allows more.

### Output current & protection
- Inverter output current: `I_out = P_rated / (U · cos φ)`
  - single-phase: `/ 230 V`
  - three-phase: `/(√3 · 400 V)`
- The coupling device (Kuppelstelle) must have a **main switch** (Hauptschalter,
  all-pole) and the inverter output MCB sized per VDE 0100-443 (see that
  reference). The main switch rating must cover the total feed-in current.

### Reactive power / cos φ
- Inverters may be required to provide reactive power (Blindleistung) per grid
  operator settings (`Q(U)` / `P(Q)` control). For a planning tool this is an
  **informational note**, not a sizing check — but store the inverter's reactive
  power capability if available.

## 3. String (DC) limits — the rules SolarPlanner must enforce

These are the DC-side requirements that 4105 (together with VDE 0100-712)
imposes on string construction. The app's `autoAssignStrings()` implements a
subset; the full set:

### 3.1 Voltage window (see vde-0100-712.md for the formulas)
```
Voc_hot  ≥ inverter.minInputVoltage          (start-up, hottest day)
Voc_cold ≤ min(1500 V, inverter.maxInputVoltage)   (Class B + device limit)
```

### 3.2 Current limits per MPPT
- Single string: `Isc(string) ≤ inverter.maxShortCircuitCurrentPerMpp`
- Paralleled strings on one MPPT: `n · Isc(string) ≤ inverter.maxShortCircuitCurrentPerMpp`
- Operating current: `n · Imp(string) ≤ inverter.maxInputCurrentPerMpp`
  (the app stores `maxInputCurrentPerMpp` but does **not** check it — add this).

### 3.3 MPP voltage range
- The string's **operating** (MPP) voltage at expected conditions should lie
  within the inverter's MPP tracking range. Planning approximation: use `Vmp`
  at STC as a first estimate; refine with the cell-temperature model:
  `Vmp(T) ≈ Vmp_STC · (1 + γ_Voc·(T_cell − 25))` (using the Voc coefficient as
  a proxy, since `Vmp` has a similar temperature behavior).

## Properties SolarPlanner should persist for this standard

| Item | Property | Required? | Why (which check) |
|---|---|---|---|
| Inverter (inventory) | `maxInputCurrentPerMpp` — *present* | **required** | operating-current limit per MPPT (`n·Imp ≤ I_in,max`). Currently stored but **never checked** in `autoAssignStrings`. |
| Inverter (inventory) | `acPhases` (1/3) — *missing* | **required** | output current formula & single-phase 11.5 kW limit. Add int column, default 1. |
| Inverter (inventory) | `maxFeedInKw` per unit or project-level grid limit — *missing* | **required** for feed-in check | agreed power with the grid operator. Project-level field `maxFeedInKw` on `Projects`. |
| Inverter (inventory) | reactive power capability (`qKvar` or `cosPhiRange`) — *missing* | optional | informational note on grid-code compliance. Add nullable real/text. |
| Project (site) | `gridPhases` (1/3), `maxFeedInKw`, coupling-device main switch rating — *missing* | **required** for feed-in checks | Add to `Projects` or a new `GridConnection` table. |
| Project (site) | `tAmbientMinC`, `tAmbientMaxC` — *missing* (see vde-0100-712.md) | **required** for the voltage window | same fields, shared with 0100-712. |

## Formulas to validate in the app (full list for `autoAssignStrings`)

Current implementation checks:
1. ✅ `voc_string(STC) ≤ maxInputVoltage` — **incomplete** (no cold correction,
   no 1500 V Class B cap explicitly).
2. ✅ per-string `isc ≤ maxShortCircuitCurrentPerMpp`.

Missing (add as post-assignment validation per string and per MPPT):
3. ❌ `Voc_cold ≤ min(1500, maxInputVoltage)` — cold-temperature correction.
4. ❌ `Voc_hot ≥ minInputVoltage` — hot start-up check.
5. ❌ per-MPPT parallel sum: `n_strings · Isc ≤ maxShortCircuitCurrentPerMpp`.
6. ❌ per-MPPT operating current: `n_strings · Imp ≤ maxInputCurrentPerMpp`.
7. ❌ total AC power vs `maxFeedInKw` (project) and single-phase 11.5 kW cap.

Suggested implementation: a `validateStrings()` method in
`EditorController` that runs checks 1–7 and returns a list of violations
(severity + message), surfaced in the UI as a warnings panel. Keep
`autoAssignStrings()` for construction; move **validation** out of it so manual
string edits are also checked.

## Warning triggers to implement (VDE-AR-N 4105)

- ⚠️ Total inverter AC power > `maxFeedInKw` → "Anlageleistung überschreitet
  die mit dem Netzbetreiber vereinbarte Einspeisung".
- ⚠️ Single-phase inverter > 11.5 kW → exceeds typical single-phase limit.
- ⚠️ `n_strings(MPPT) · Imp > maxInputCurrentPerMpp` → operating current
  exceeds MPPT input limit (inverter will clamp / lose yield).
- ⚠️ `Voc_hot < minInputVoltage` → no start-up on hot days (see 0100-712).
- ⚠️ Inverter `acPhases` ≠ project `gridPhases` → connection mismatch.
- ℹ️ Note: for installations after 2023, DIN VDE 4110 may require additional
  protection at the coupling device — flag for electrician review.
