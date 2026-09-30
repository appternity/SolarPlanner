# Stromlaufplan Gesamtanlage — PV + Speicher + Wärmepumpe + Wallbox

<!-- Rolle: Elektromeister. Gültig für dreiphasigen Netzanschluss (400/230 V, TN-C-S).
     Kombiniert: STROMLAUFPLAN_PV.md (Abschnitt 0), STROMLAUFPLAN_WAERMEPUMPE.md,
     STROMLAUFPLAN_WALLBOX.md (Abschnitt 0) + Batteriespeicher (PV-Abschnitt G).
     Basis: HAUSANSCHLUSSKASTEN_INVENTAR.md (Bestand) + VDE/DIN-Normen.
     Normen: DIN VDE 0100-430/-520/-534 (Überschutz, Leitungen, FI),
            VDE 0100-712 (PV-DC), -600 (Erdung/PA),
            VDE-AR-N 4105 / DIN VDE 4110 (Netzeinspeisung),
            VDE 0127-1 / IEC 61851 (Ladeeinrichtungen),
            VDE-AR-E 2105-100 (WP-Anlage), IEC 62619 (Batterie).
     AC = Wechselstrom, DC = Gleichstrom. Trennung strikt! -->

**Anlage:** PV (8–25 kWp) + Batteriespeicher (≤ 20 kWh, bis 4 Units)
           + Wärmepumpe Vaillant aroTHERM pro VWL 115/7.1 A (~4,36 kW)
           + Wallbox (IC-CPD, 7–22 kW)

**Prinzip:** Ein HAK versorgt alle Verbraucher. Jede Anlage hat **eigenen LS + FI**
(im HAK bzw. UV) — Komponenten wie Zähler, Hauptschalter und HPA-Schiene sind
**einmalig**, LS/FI-Stromkreise sind **pro Anlage redundant**.

---

## 0. Systemübersicht (Blockschaltbild)

```
┌───────────────┐   AC 400/230V   ┌──────────────────────────────────────────────────┐
│ NETZBETREIBER │◄═══════════════►│              HAK (Bestand)                       │
│ Stadtwerke    │  3~ + N + PE    │ ┌──────────────┐   ┌─────────────────┐           │
│ (3×63 A?)     │                 │ │ Zähler       │   │ Hauptschalter   │           │
│               │  bidirektional: │ │ AEGIS M132   │   │ (R1, 63 A C?)   │           │
│ Bezug +       │◄═══════════════►│ │ 5(60) A,     │   └────────┬────────┘           │
│ Einspeisung   │  (Einspeisung)  │ │ ePRM         │            │                    │
└───────────────┘                 │ └──────┬───────┘            │                    │
                                  │        ▼                    ▼                    │
                                  │ ┌─────────────────────────────────────────┐      │
                                  │ │  HAK-Hutschiene (Bestand)               │      │
                                  │ │  R2/R3: LS Endstromkreise (Bestand)     │      │
                                  │ └────────────────────┬────────────────────┘      │
                                  │                      ▼                           │
                                  │ ┌──────────────────────────────────────────────┐ │
                                  │ │  R4: FREIE PLÄTZE (Nr. 7–12, 17–23)          │ │
                                  │ ├──────────────┬────────────┬──────────────────┤ │
                                  │ │              │            │                  │ │
                                  │ │ ┌──────────┐ │ ┌────────┐ │ ┌──────────────┐ │ │
                                  │ │ │ PV-KUPPEL│ │ │SPEICHER│ │ │ WALLBOX      │ │ │
                                  │ │ │ STELLE   │ │ │ -AC    │ │ │ (Ladeeinr.)  │ │ │
                                  │ │ │ LS C25/32│ │ │LS C16/ │ │ │ LS 3P C16/C25│ │ │
                                  │ │ │ + FI TypB│ │ │  C25   │ │ │ + FI Typ B   │ │ │
                                  │ │ └────┬─────┘ │ └───┬────┘ │ └──────┬───────┘ │ │
                                  │ └──────┼───────┴─────┼──────┴────────┼─────────┘ │
                                  │        ▼             ▼               ▼           │
                                  │ ┌──────────────────────────────────────────┐     │
                                  │ │  R5: HPA-SCHIENE (Erdung, Bestand)       │     │
                                  │ └──────────────────────────────────────────┘     │
                                  └─────┬─────────────┬────────────┬─────────────────┘
                                        │             │            │
              ┌─────────────────────────┤             │            ├─────────┐
              │ AC 3×2,5–10 mm² Cu      │             │            │         │
              ▼                         ▼             ▼            ▼         │
┌─────────────────────┐   ┌──────────────────┐  ┌────────────────────────┐   │
│ WECHSELRICHTER      │   │ BATTERIESPEICHER │  │ WALLBOX (IC-CPD)       │   │
│ 8–25 kW, 3~, MPPT×2 │   │ AC-coupled, LFP  │  │ IP54/IP65 (außen)      │   │
│                     │   │ ≤ 20 kWh         │  │ 7 / 11 / 22 kW         │   │
└────┬───────────┬────┘   │ bis 4 Head-Units │  └───────────┬────────────┘   │
     │ DC        │ PE     └───┬───────────┬──┘              │                │
     │ 1000/1500V│            │ DC        │ PE              │                │
     ▼           ▼            ▼ (je Unit) ▼                 ▼                │
┌───────────────────────┐  ┌─────────────────────────────────────────────┐   │
│ DC-VERTEILER /        │  │                                             │   │
│ STRING-SCHALTER       │  │            HPA / ERDUNG (R5 im HAK)         │   │
│ je String:            │  │                                             │   │
│ LS DC + Sicherung     │  │  ← WR-Gehäuse (PE ≥4 mm²)                   │   │
└───┬────────┬───────┬──┘  │  ← Speicher-Gehäuse je Unit (PE ≥4 mm²)     │   │
    │        │       │     │  ← Wallbox (PE 4–10 mm²)                    │   │
    ▼        ▼       ▼     │  ← WP-Gehäuse (PE ≥4 mm²)                   │   │
┌──────┐ ┌──────┐ ┌─────┐  │  ← Modulrahmen (Klasse B)                   │   │
│STR.1 │ │STR.2 │ │STR.n│  └─────────────────────────────────────────────┘   │
│n₁×Mod│ │n₂×Mod│ │nₙ×Mod│                                                    │
└──┬───┘ └──┬───┘ └──┬──┘                                                    │
   ▼        ▼        ▼                                                       │
┌─────────────────────────────┐                                              │
│ SOLARMODULE (Dach)          │                                              │
│ Rahmen → Erdung             │                                              │
└─────────────────────────────┘                                              │
                                                                             ▼
                                   ┌────────────────────────────────────────────────────────────────┐
                                   │  ZWISCHENSCHRANK / E-BOX WÄRMEPUMPE (Keller, neben WP)         │
                                   │  ┌──────────────┐   ┌──────────────────────────┐               │
                                   │  │ Trennschalter│──►│ WÄRMEPUMPE               │               │
                                   │  │ 3P B16       │   │ Vaillant aroTHERM pro    │               │
                                   │  └──────────────┘   │ VWL 115/7.1 A (~4,36 kW) │               │
                                   │                     └─────────┬────────────────┘               │              
                                   └───────────────────────────────┼────────────────────────────────┘
                                                                   │ PE (≥4 mm² Cu) 
                                                                   │  AC 3×6 mm² + PE 4 mm² (NYM-J, ~15–25 m)
                                                                   │  HAK R4: LS 3P B16 + FI Typ A 40A/30mA
                                                                   ▼
                                   ┌──────────────────────────────────────────────────────────┐
                                   │  ELEKTROFAHRZEUG (Typ 2-Stecker, Mode 3)                 │
                                   │  Ladekabel Typ 2 (3–5 m, im Wallbox-Gehäuse)             │
                                   └──────────────────────────────────────────────────────────┘

═══════════════════════════════════════════════════════════════════════
  KOMMUNIKATION (optional, getrennt vom Starkstrom verlegen >30 cm)
════════════════════───────────────────────────────────────────────────

              ┌────────────────────────────────────┐
              │  ROUTER / SMARTHOME-GATEWAY        │
              └───┬────────────┬──────────────┬────┘
                  │ LAN/WLAN   │ Modbus/M-Bus │ ePRM (LAN)
                  ▼            ▼              ▼
         ┌─────────────┐  ┌────────────┐  ┌──────────────────┐
         │ WALLBOX     │  │ WÄRMEPUMPE │  │ BATTERIESPEICHER │
         │ (OCPP opt.) │  │ (vocu)     │  │ BMS-Gateway      │
         └─────────────┘  └────────────┘  └──────────────────┘
                  ▲                               ▲
                  │ PV-Überschussladen            │ PV-Überschussladen
                  └───────────────┬───────────────┘
                                  │ liest Bezug/Einspeisung am
                        ┌─────────▼──────────┐
                        │ ZÄHLER AEGIS M132  │ (bidirektional, ePRM)
                        └────────────────────┘
```

---

## 1. HAK-Belegung (Redundanzprinzip)

Jede Anlage erhält **eigenen LS + FI-Stromkreis** im HAK (R4) — kein gemeinsamer
Schutz für mehrere Anlagen. Zähler, Hauptschalter und HPA-Schiene sind einmalig (Bestand).

| Anlage | LS im HAK/UV | FI im HAK/UV | Bemerkung |
|--------|-------------|--------------|-----------|
| **PV (Einspeisung)** | 3P C25–C63 (je WR-Leistung) | Typ B, 40–63 A / 30 mA (empfohlen) | Kuppelstelle — allpolig (VDE-AR-N 4105 §6.3) |
| **Batteriespeicher** | 3P C16/C25 (Stufung unter Kuppelstelle) | — (interner Schutz der Head-Units) | Eigener Endstromkreis, nicht mit PV-Kuppelstelle geteilt |
| **Wärmepumpe** | 3P B16 (im HAK) + Trennschalter B16 (E-Box WP) | Typ A, 40 A / 30 mA | B-Charakteristik (Inverter-Kompressor, niedriger Einschaltstrom) |
| **Wallbox** | 3P C16/C25 (C-Charakteristik: Wechselrichter im EV) | **Typ B, 40 A / 30 mA — Pflicht** (VDE 0127-1) | DC-Fehlerströme des EV; interner RCD-Watchdog ersetzt FI Typ B **nicht** |

> ⚠️ **Stufung:** LS-Schalter (R4) < PV-Gruppenschalter/UV „PV" < Kuppelstelle < Hauptschalter (R1).
> VDE 0100-430 §542: `I_B ≤ I_N ≤ I_Z` in jeder Stufe.

---

## 2. Erdung & Potentialausgleich (einmalig, alle Anlagen)

| Anschluss | Querschnitt (min.) | Norm |
|-----------|-------------------|------|
| PE-Hauptleiter (Bestand, Fundamenterdung) | ≥ 10 mm² Cu | VDE 0100-534; < 100 Ω (BZA: < 10 Ω) |
| WR-Gehäuse → HPA (R5) | ≥ 4 mm² Cu | VDE 0100-600 §542 — **Pflicht** |
| Speicher-Gehäuse je Head-Unit → HPA (R5) | ≥ 4 mm² Cu | VDE 0100-600 §542 — **Pflicht je Unit** |
| WP-Gehäuse → HPA (R5) | ≥ 4 mm² Cu | VDE 0100-600 §542 — **Pflicht** |
| Wallbox → HPA (R5) | 4–10 mm² Cu (je nach LS-Größe) | VDE 0100-600 §542 — **Pflicht** (Klasse I) |
| Modulrahmen → Schienen/HPA (Klasse B) | ≥ 4 mm² Cu oder Schiene als PE-Leiter | VDE 0100-600 §543 + VDE 0100-712 |

---

## 3. Kommunikation (optional, getrennt vom Starkstrom)

| Gerät | Schnittstelle | Zweck |
|-------|--------------|-------|
| Wallbox ↔ Router | LAN (Cat 6) / WLAN; OCPP optional | Smart Charging, Lastmanagement |
| Speicher ↔ Router | LAN (Cat 6); ePRM-Gateway an Zähler | PV-Überschussladen, Monitoring (BMS) |
| Wärmepumpe ↔ Gateway | Modbus RTU / M-Bus (2×0,75 mm²) | vocu / SmartHome-Steuerung |
| Zähler (AEGIS M132) → Wallbox/Speicher | ePRM über LAN/Gateway | Bezugs-/Einspeisemessung für Überschussladen |

> Alle Kommunikationskabel **getrennt vom Starkstrom verlegen** (> 30 cm Abstand,
> VDE 0100-520 §7.6 EMV-Trennung).

---

## 4. DC-Seite (nur PV + Speicher — strikt getrennt von AC)

```
WECHSELRICHTER (DC-Eingang 1000/1500 V)
    │ DC-Verkabelung (H1Z2Z2-J, 4/6 mm² Cu)
    ▼
DC-VERTEILER / STRING-SCHALTER (je String: LS DC + gG-Sicherung)
    │                              │ Speicher-DC (je Head-Unit: LS + Sicherung)
    ▼                              ▼
SOLARMODULE (Dach)            BATTERIESPEICHER-HEAD-UNITS
```

| Regel | Norm |
|-------|------|
| DC-Kabel **nicht** mit AC-Kabel in einem Kanal (außer getrennte Abteile) | VDE 0100-712 §4 — **strikt** |
| „One string per fuse" / „one unit per fuse" — Sicherung pro String/Unit, nicht Parallelsumme | VDE 0100-712 §4 / VDE 0100-430 |
| String-Spannungsfenster: Voc_cold ≤ min(1500 V, WR_max) **und** Voc_hot ≥ WR_min | VDE 0100-712 §4 / VDE-AR-N 4105 |
| DC-Kabel: `I_Z` (Dach-/Umgebungstemp.) ≥ 1,25 · Imp/I_Nenn | VDE 0100-430 §542 / IEC 62548 |

---

## 5. Normen-Checkliste (Gesamtanlage, vor Inbetriebnahme)

| # | Prüfung | Norm | Status |
|---|---------|------|--------|
| 1 | `maxFeedInKw` beim Netzbetreiber erfragt & WR-Leistung ≤ Limit | VDE-AR-N 4105 §6 | ☐ offen |
| 2 | Zähler bidirektional (Bestand: ja, AEGIS M132) | VDE-AR-N 4105 §7 / DIN EN 50470-1 | ☑ erfüllt (Bestand) |
| 3 | PV-Kuppelstelle: allpoliger Schalter + FI Typ B (empfohlen) | VDE-AR-N 4105 §6.3 / VDE 0100-534 | ☐ neu einbauen (R4) |
| 4 | Speicher: LS-Schalter AC, Stufung unter Kuppelstelle | VDE 0100-430 §542 | ☐ nur bei Speicher (R4) |
| 5 | WP: LS B16 + FI Typ A 40A/30mA (eigener Stromkreis) | VDE-AR-E 2105-100 / VDE 0100-430 | ☐ neu einbauen (R4) + E-Box im Keller |
| 6 | Wallbox: LS C16/C25 + **FI Typ B** (Pflicht) | VDE 0127-1 / VDE 0100-534 | ☐ neu einbauen (R4) |
| 7 | Stufung: alle LS < Kuppelstelle/UV-Gruppen < Hauptschalter | VDE 0100-430 §542 | ☐ nach Einbau prüfen (alle Anlagen) |
| 8 | String-Spannungsfenster + MPPT-Parallelsummen (PV) | VDE 0100-712 §4 / VDE-AR-N 4105 | ☐ pro String/MPPT berechnen |
| 9 | DC-Sicherung je String / je Speicher-Unit („one per fuse") | VDE 0100-712 §4 / VDE 0100-430 | ☐ je String/Unit dimensionieren |
| 10 | DC-Kabel: `I_Z` (Dach-/Umgebungstemp.) ≥ 1,25 · I; DC/AC getrennt | VDE 0100-430 §542 / IEC 62548 | ☐ je String/Unit prüfen |
| 11 | AC-Kabel: `I_Z` nach Verlegeart + Temperatur ≥ I_N(LS) — alle 4 Zuleitungen | VDE 0100-430 §542 / VDE 0100-520 | ☐ Längen messen (WP ~15–25 m, WB 20–40 m) |
| 12 | PE-Anschlüsse: WR + Speicher (je Unit) + WP + Wallbox → HPA; Modulrahmen | VDE 0100-600 §542/§543 | ☐ alle neu anschließen + verifizieren |
| 13 | Erdungswiderstand gemessen (< 100 Ω / < 10 Ω bei BZA) | VDE 0100-534 / DIN EN 62305 | ☐ **vor Inbetriebnahme messen** |
| 14 | FI-Prüfung: Bestand (R3) + neue FIs (PV Typ B, WP Typ A, WB Typ B) | VDE 0100-534 / DIN VDE 0107-100 | ☐ bei Inbetriebnahme testen (alle) |
| 15 | Blitzschutz: DC-Ableiter Typ 2 an PV + Speicher (falls BZA) | DIN EN 62305-4 / VDE 0100-712 | ☐ prüfen (BZA vorhanden?) |
| 16 | Wallbox: Spannungsfall ≤ 3 % (Zuleitung H07V-U, außen) | VDE 0100-520 / DIN EN 62351 | ☐ Länge + Querschnitt prüfen |
| 17 | Inbetriebnahme-Protokoll (alle Anlagen) + Anmeldung PV beim Netzbetreiber | VDE-AR-N 4105 §8 / EnWG | ☐ **vor Einspeisung anmelden!** |
| 18 | Kommunikation: LAN/Modbus getrennt vom Starkstrom verlegt (>30 cm) | VDE 0100-520 §7.6 (EMV) | ☐ Verlegeweg prüfen |

---
*Erstellt: 2026-09-27 · Rolle: Elektromeister · Kombiniert aus STROMLAUFPLAN_PV.md,
STROMLAUFPLAN_WAERMEPUMPE.md, STROMLAUFPLAN_WALLBOX.md + Batteriespeicher (PV-Abschnitt G).
Dauerhafte Referenz für die Gesamtanlage. Bei Bestand-/Normänderungen: hier + Teilpläne aktualisieren.*
