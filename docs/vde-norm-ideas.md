# VDE-Norm-Backlog — SolarPlanner

<!-- Maintained by the validate-vde-norm skill. Remove an entry once it is
     implemented in code; keep the rest sorted by priority within each section. -->

<!-- Last audit: 2026-09-22 (fourth pass, after schema v8). All backlog
     items from the previous audits are implemented: MPP-Fenster-Check
     (Inverters.mppMinVoltage/mppMaxVoltage), Wallbox-Ladestrom-Check
     (Wallboxes.breakerA/rcdRatedA), Inverters.qKvar, 11,5-kVA-Einphasen-
     Limit + Phasen-Mismatch, Misch-Strings-Warnung, Batterie-Erdungs-
     Check, Kabel-Temperaturkorrektur-Hinweis, recommendedFuseA > 35 A →
     null und DC/AC-Anzeige (Feed-in-Check nutzt jetzt totalAcKw).
     Offen: nur die Datenblatt-Lücken unten. -->

## 1. Fehlende Eigenschaften (Property audit)

Alle **Pflicht**- und alle optionalen Spalten existieren in Schema v8:
`Projects.tAmbientMinC` (fix −25 °C, read-only)/`tAmbientMaxC`(40 °C)/
`gridPhases/maxFeedInKw/hasMainEquipotential/isBoltedMounting`,
`Inverters.acPhases/dcVoltageClass/iOutA/mcbA/qKvar/
mppMinVoltage/mppMaxVoltage`, `SolarModules.frameClass`,
`Wallboxes.rcdType`(Default 'B')/`breakerA/rcdRatedA`,
`ModuleStrings.dcCableMm2/fuseA`. Werte aus `data/datenblatt/` sind in
`seed.dart` und per Name-Backfill in beiden bestehenden DBs (lokal +
OneDrive) persistiert.

> **Datenblatt-Lücken** (Bewusst NULL / Annahme — bei neuen Datenblättern
> prüfen):
> - **JA Solar Deep Blue 4.0 (JAM54D41-LB):** Schutzklasse im Datenblatt nicht
>   angegeben → `frameClass = NULL` (wird konservativ als Klasse I behandelt,
>   d. h. Erdungswarnung wird ausgelöst). Herstellerdatenblatt nachfragen
>   (Doppelscheiben-Module sind oft Klasse II).
> - **SMA STPxx-50 / STPHxx-60:** "Max. PV Input Voltage" steht nur beim
>   STP 20-50 (1000 V) im Datenblatt; `dcVoltageClass = '1000V'` ist für die
>   übrigen Modelle eine Annahme (nur informativ — der Kälte-Check nutzt
>   `min(1500, maxInputVoltage)`).
> - **Trina Vertex S:** Klasse nicht explizit angegeben; `frameClass = 'I'`
>   abgeleitet aus dem anodisierten Aluminiumrahmen.

## 2. Berechnungen & Warnungen — umgesetzt in `EditorController.validateProject()`

Alle Checks aus den früheren Audits sind implementiert (Details +
Regressionstests in `test/vde_validation_test.dart`):

- String: Kälte-Voc ≤ min(1500, maxInputVoltage), Hitze-Voc ≥ Startspannung,
  MPP-Fenster `Vmp(T_cell)` ∈ [mppMinVoltage, mppMaxVoltage] (γ_Voc als
  Proxy), MPPT-ΣIsc/ΣImp, Sicherung (`recommendedFuseA`, null bei Isc > 35 A)
  + Kabel-Querschnitt (`cableIzA`), Temperaturkorrektur-Hinweis bei
  gesetztem `dcCableMm2`, Misch-Strings pro MPPT (Anzahl/Typ).
- Projekt: Feed-in-Limit gegen **AC-Nennleistung** (`totalAcKw`, nicht
  DC-kWp), 11,5-kVA-Einphasen-Limit (Inverter-spezifisch + projektweit),
  Phasen-Mismatch Inverter ↔ Netz, Erdung/Potenzialausgleich (Klasse I
  Module + Batteriesystem), AC-Ausstrom-Info mit LS-Empfehlung pro aktivem
  Inverter, Wallbox: FI-Typ-B + Ladestrom vs. `breakerA`/`rcdRatedA`.
- UI: `_ViolationsPanel` + Anlagen-Zeile "DC X kWp / AC Y kW (Verhältnis Z)"
  in `editor_screen.dart`.

## 3. Formel-Korrekturen — umgesetzt

- Feed-in-Check vergleicht `totalAcKw` (Σ aktive Inverter, Fallback:
  aktiver Inverter) mit `maxFeedInKw`; UI zeigt DC/AC nebeneinander.
- `recommendedFuseA` liefert bei Isc > 35 A **null** → Warnung "keine
  Standard-DC-Sicherung — größere DC-Sicherung oder Aufteilung auf mehrere
  Strings".

> Hinweis: SolarPlanner ist ein Planungstool, keine Zertifizierung — alle
> Checks sind Hinweise für den Planer; die finale Dimensionierung muss eine
> Elektro-Fachkraft bestätigen.
