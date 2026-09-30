# Stromlaufplan PV-Anlage — Netzbetreiber → Solarmodule

<!-- Rolle: Elektromeister. Gültig für Systeme 8–25 kWp, dreiphasiger Netzanschluss (400/230 V).
     Basis: HAUSANSCHLUSSKASTEN_INVENTAR.md (Bestand) + VDE/DIN-Normen.
     Normen: DIN VDE 0100-443 (Überschutz), -534 (FI/Berührungsspannung), -712 (PV-DC),
            VDE-AR-N 4105 / DIN VDE 4110 (Netzeinspeisung), -600 (Erdung/PA).
     DC = Gleichstrom (Module → WR), AC = Wechselstrom (WR → Netz). Trennung strikt! -->

## 0. Systemübersicht (Blockschaltbild)

```
┌───────────────┐   AC 400/230V  ┌──────────────────────────────────────┐
│ NETZBETREIBER │◄══════════════►│        HAK (Bestand)                 │
│ Stadtwerke    │  3~ + PE       │ ┌────────────┐  ┌───────────────┐    │
│               │                │ │ Zähler     │  │ Hauptschalter │    │
└───────────────┘                │ │ AEGIS M132 │  │ (R1, 63 A?)   │    │
                                 │ └────┬───────┘  └──────┬────────┘    │
                                 │      │ bidirektional   │             │
                                 │ ┌────▼─────────────────▼────────┐    │
                                 │ │ KUPPELSTELLE (PV-Einspeisung) │    │
                                 │ │ LS 3P C25/C32 + FI Typ B*     │    │
                                 │ └────────────┬──────────────────┘    │
                                 │              │                       │
                                 │ ┌────────────▼─────────────────────┐ │
                                 │ │ SPEICHER-AC (optional, ≤ 20 kWh) │ │
                                 │ │ LS 3P C16/C25 (Stufung unter     │ │
                                 │ │ Kuppelstelle) + AC-Kabel         │ │
                                 │ └────────────┬─────────────────────┘ │
                                 └──────────────┼───────────────────────┘
                        ┌───────────────────────┴───────────────────────┐
                        │ AC (Wechselstrom)                             │
                        ▼                                               ▼
             ┌─────────────────────────────┐          ┌───────────────────────────┐
             │   WECHSELRICHTER (AC/DC)    │          │ BATTERIESPEICHER (opt.)   │
             │   8–25 kW, 3~, MPPT×2       │          │ AC-coupled, LFP           │
             └────┬───────────────────┬────┘          │ ≤ 20 kWh, bis 4 Units     │
                  │ DC (Gleichstrom)  │ PE            └────┬───────────┬──────────┘
                  │ 1000 V / 1500 V   ▼                    │ DC        │ PE
                  │            ┌──────────────┐            │ (je Unit) │
                  │            │ HPA / Erdung │◄───────────┴───────────┘
                  ▼            └──────────────┘
             ┌─────────────────────────────────┐
             │  DC-VERTEILER / STRING-SCHALTER │
             │  (je String: LS DC + Sicherung) │
             └────┬──────────┬──────────┬──────┘
                  │          │          │  DC (Gleichstrom)
                  ▼          ▼          ▼
             ┌────────┐ ┌────────┐ ┌────────┐
             │STRING 1│ │STRING 2│ │STRING n│   (je String:
             │n₁×Mod. │ │n₂×Mod. │ │nₙ×Mod. │    Module in Serie)
             └────────┘ └────────┘ └────────┘
                  │          │          │
                  ▼          ▼          ▼
             ┌─────────────────────────────────┐
             │  SOLARMODULE (Dach)             │
             │  Rahmen → Erdung (VDE 0100-600) │
             └─────────────────────────────────┘
```

\* FI Typ B an der Kuppelstelle: **empfohlen** (VDE-AR-N 4105 / Netzbetreiber-Vorgabe), keine harte VDE-Pflicht für die Einspeisung selbst.

---

## 1. Abschnitt A: Netzbetreiber → HAK (AC, Bestand)

| Komponente | Spezifikation | Norm / Bemerkung |
|---|---|---|
| Netzanschluss (Übergabepunkt) | 3~ + N + PE, 400/230 V, TN-C-S | DIN VDE 0100-700 (Anlagengestaltung) — **Bestand, nicht ändern** |
| Hauptabsicherung netzseitig | typ. 3×63 A (beim Netzbetreiber) | `maxFeedInKw` **erfragen** — begrenzt die PV-Anlagenleistung (VDE-AR-N 4105 §6) |
| **Bidirektionaler Zähler** AEGIS PLUS M132 (GLIEMATO) | 400 V, 5(60) A → max. 41,5 kW (3~), ePRM | Messung Bezug + Einspeisung; **keine zusätzliche Einspeise-Messung nötig** (VDE-AR-N 4105 §7) |
| Zähler → Kuppelstelle | Übergabe im HAK (Klappdeckel L2) | **Inhalt bei Öffnung dokumentieren** — Klemmenbelegung prüfen |

## 2. Abschnitt B: HAK → Wechselrichter (AC, neu)

| Komponente | Spezifikation | Norm / Bemerkung |
|---|---|---|
| **Kuppelstelle PV** (im HAK, freie Plätze R4) | LS 3P C25–C63 (je nach WR-Leistung, s. u.) + **FI Typ B 40–63 A / 30 mA** (empfohlen) | VDE-AR-N 4105 §6.3: Kuppelstelle mit allpoligem Schalter; FI Typ B für PV-DC-Fehlerströme (VDE 0100-534) |
| LS-Schalter AC (Einspeisung) | `I_N ≥ I_out(WR)`; `I_out = P_rated / (√3 · 400 V)` | **VDE 0100-443 §542**: `I_B ≤ I_N ≤ I_Z`. Beispiele: 8 kW → C16, 10 kW → C20, 15 kW → C32, 20 kW → C40, 25 kW → C50 |
| AC-Kabel WR ↔ HAK | Cu, 3×2,5 mm² (bis ~10 m) / 3×4 mm² (länger), NYM-J oder in Leitungsführungskanal | **VDE 0100-443**: `I_Z` nach Verlegeart + Temperatur korrigieren; DC- und AC-Kabel **trennen** (VDE 0100-712 §4) |
| PE-Anschluss WR | Wechselrichter-Gehäuse → HPA-Schiene (R5) mit ≥ 4 mm² Cu | **VDE 0100-600 §542**: Hauptpotentialausgleich — **Pflicht** |
| Klemmenleiste / PA im HAK | Bestands-HPA (R5) nutzen; PE-Hauptleiter, WR-Gehäuse, Modulrahmen-Erdung hier zusammenführen | VDE 0100-600 §542/§543 |

### AC-Leistungsklassen (8–25 kWp, 3~) — Dimensionierungstabelle

| WR-Leistung (AC) | `I_out` = P/(√3·400 V) | LS 3P (C-Char.) | AC-Kabel Cu (min., ≤10 m) | FI Typ B (empfohlen) |
|---|---|---|---|---|
| 8 kW | 11,5 A | C16 | 3×2,5 mm² | 40 A / 30 mA |
| 10 kW | 14,4 A | C20 | 3×2,5 mm² | 40 A / 30 mA |
| 15 kW | 21,7 A | C25 / C32 | 3×4 mm² | 63 A / 30 mA |
| 20 kW | 28,9 A | C32 / C40 | 3×6 mm² | 63 A / 30 mA |
| 25 kW | 36,1 A | C40 / C50 | 3×10 mm² | 63 A / 30 mA |

> **Hinweis:** Bei >15 kWp und/oder langer WR↔HAK-Strecke: **Unterverteilung „PV"** vorsehen (s. Abschnitt F).

## 3. Abschnitt C: Wechselrichter (AC/DC-Grenzstelle)

| Komponente | Spezifikation | Norm / Bemerkung |
|---|---|---|
| **Wechselrichter** (3~, 2× MPPT) | 8–25 kW AC, DC-Eingang: **1000 V** (bis ~15 kWp) oder **1500 V** (>15 kWp, z. B. Sungrow/GoodWe 25 kW) | **VDE-AR-N 4105 §6**: WR-Leistung ≤ `maxFeedInKw`; **VDE 0100-712 §4**: Systemspannungsklasse B (≤1500 V DC) |
| MPPT-Eingänge | 2× (MPPT1, MPPT2), je `maxInputVoltage`, `minInputVoltage`, `maxShortCircuitCurrentPerMpp` | String-Aufteilung: **Voc_cold ≤ min(1500 V, WR_max)** und **Voc_hot ≥ WR_min** (Startspannung) — Formeln in `docs/vde-norm-ideas.md` |
| DC-Eingangsschutz (im WR) | Integrierte DC-Schalter / -Sicherungen (herstellerspezifisch) | **VDE 0100-712 §4**: DC-Seite muss schaltbar/absicherbar sein |
| PE / Erdung WR-Gehäuse | → HPA (Abschnitt B) | **VDE 0100-600** — Pflicht, Klasse B |
| Kommunikation | LAN / WiFi → Monitoring (optional) | — |

### DC-Systemspannungsklassen (VDE 0100-712 §4)

| Klasse | Max. String-Voc (kalt) | Anwendung hier? |
|---|---|---|
| A | ≤ 60 V DC | Nein (nur Balkon-PV) |
| **B** | 60 V < Voc ≤ **1500 V DC** | **Ja — Zielklasse für 8–25 kWp** |
| C | > 1500 V DC | Nein (nur gewerblich, Zugangsbeschränkung) |

**String-Spannungsfenster (Pflichtprüfung, VDE 0100-712 / VDE-AR-N 4105):**
```
Voc_cold = n_Mod · Voc_STC · (1 + γ_Voc·(T_cell,cold − 25 °C))   ≤ min(1500 V, WR_maxInputVoltage)
Voc_hot  = n_Mod · Voc_STC · (1 + γ_Voc·(T_cell,hot  − 25 °C))   ≥ WR_minInputVoltage
```
- `T_cell,cold ≈ T_ambient,min` (z. B. −10 °C im Winter, Modul auf Schnee)
- `T_cell,hot  ≈ T_ambient,max + 30 K` (NOCT-Äquivalent, z. B. 25 + 30 = 55 °C)
- `γ_Voc` = Temperaturkoeffizient Voc (typ. −0,24…−0,35 %/K) — **pro Modul-Typ aus Datenblatt**

## 4. Abschnitt D: Wechselrichter → Module (DC, neu)

| Komponente | Spezifikation | Norm / Bemerkung |
|---|---|---|
| **DC-Verkabelung WR → Dach** | Cu, 4 mm² (bis ~15 A/String) / 6 mm² (>15 A), **PV-Dauerkabel** (z. B. H1Z2Z2-J, 1500 V), UV-beständig | **VDE 0100-443**: `I_B = 1,25 · Imp(String)` (PV-Dauerlast); `I_Z` nach Verlegeart + **Dach-Temperatur** korrigieren (−10…20 % bei 40–50 °C) |
| **DC-Verteiler / String-Schalter** (je MPPT oder je String) | DC-LS-Schalter 1000 V / 25 A (oder 1500 V) + **DC-Sicherung je String** (gG, > `I_sc` eines Strings) | **VDE 0100-712 §4**: „One string per fuse"; Sicherung auf **einen** String dimensioniert, nicht auf Parallelsumme |
| DC-Sicherung (je String) | `I_N(Sicherung) ≥ I_sc(String)`; gG-Charakteristik, 1000 V / 1500 V DC | **VDE 0100-443 §542**: `I_B ≤ I_N ≤ I_Z`; Kurzschluss-Schutz für nachgeschaltetes Kabel |
| **String-Aufbau** (Module in Serie) | `n_Mod` so wählen, dass Spannungsfenster (Abschnitt C) eingehalten; **gleicher Modul-Typ pro String** | **VDE 0100-712 §4**: gleiche Typen pro String; gemischte Strings auf einem MPPT → Warnung (Umladestrom) |
| **MPPT-Parallelisierung** | `n_strings(MPPT) · I_sc(String) ≤ WR_maxShortCircuitCurrentPerMpp` **und** `n_strings(MPPT) · Imp(String) ≤ WR_maxInputCurrentPerMpp` | **VDE-AR-N 4105 §6 / VDE 0100-712** — beide Summen prüfen (App: `autoAssignStrings` prüft nur Teilmenge!) |
| **Modulrahmen-Erdung** (Klasse B) | Rahmen → Schienen → WR-PE / HPA; **oder** dedizierter PE-Leiter ≥ 4 mm² Cu | **VDE 0100-600 §542/§543 + VDE 0100-712 §4**: Pflicht bei Klasse B, außer Modul Klasse II (doppelisoliert) |
| DC/AC-Trennung | DC-Kabel **nicht** mit AC-Kabel in einem Kanal (außer getrennte Abteile) | **VDE 0100-712 §4** — strikte Trennung |
| DC-Klemmen / MC4-Steckverbinder | IP67, passende Querschnitte (4/6 mm²), **nicht** mischen | IEC 62852 (MC4) — Praxisstandard |

### DC-Beispiel: 10 kWp-Anlage (2× MPPT, Modul ~450 Wp / Voc 37 V STC)

| Parameter | Wert |
|---|---|
| Module pro String (kalt, −10 °C) | `n = 32` → Voc_cold ≈ 32 · 37 · (1 + 0,003·(−10−25)) ≈ **469 V** ✓ (< 1000 V) |
| Voc_hot (55 °C) | ≈ 32 · 37 · (1 − 0,003·(55−25)) ≈ **408 V** ✓ (> WR_min, typ. 160–250 V) |
| Strings pro MPPT | 2 (parallel) → `2 · I_sc ≈ 2·13,5 = 27 A` ≤ WR_max (typ. 40–60 A) ✓ |
| DC-Kabel | 4 mm² Cu (I_Z ≈ 25–30 A > 1,25·Imp ≈ 16 A) ✓ |
| DC-Sicherung je String | gG 20 A / 1000 V (≥ I_sc = 13,5 A) ✓ |

## 5. Abschnitt E: Erdung & Potentialausgleich (quer durch alle Abschnitte)

| Komponente | Spezifikation | Norm / Bemerkung |
|---|---|---|
| **Fundamenterdung** (Bestand) | Widerstand messen: < 100 Ω (allg.) / **< 10 Ω** bei Blitzschutz | **VDE 0100-534 / DIN VDE 0855** — **vor PV-Anschluss messen!** |
| **HPA-Schiene im HAK** (R5, Bestand) | PE-Hauptleiter + WR-Gehäuse + Modulrahmen-Erdung + Metallinstallationen zusammenführen | **VDE 0100-600 §542** — Hauptpotentialausgleich |
| **Modulrahmen → Erdung** (Klasse B) | Schienen als natürlichen PE-Leiter nutzen **nur wenn** durchgehend & nicht demontierbar; sonst dedizierter Leiter ≥ 4 mm² Cu | **VDE 0100-600 §543 + VDE 0100-712** — bei Flachdach/Ballastmontage: Kontinuität prüfen! |
| **Blitzschutz** (falls vorhanden) | PV-Anlage in Blitzschutzzone → Ableiter an DC-Seite (Typ 2, 1000 V) | **DIN VDE 0855-1** — bei Blitzschutzanlage: DC-Ableiter vorsehen |

## 6. Abschnitt F: Unterverteilung „PV" (optional, bei >15 kWp oder langer Strecke)

**Wann nötig:**
- WR-Standort weit vom HAK entfernt (>10 m AC-Kabel) → Spannungsverlust & Kabelquerschnitt
- HAK hat **nicht** genug freie Plätze (siehe Inventar R4: Nummern 7–12, 17–23)
- Mehrere Wechselrichter (z. B. 2× 10 kW statt 1× 20 kW)

**Aufbau der UV „PV" (z. B. in Garage / Keller):**
```
HAK: LS 3P C40/C50 (PV-Gruppenschalter)
        │ AC 3×6/10 mm² Cu
        ▼
┌─────────────────────────────┐
│  UNTERVERTEILUNG „PV"       │
│ ┌─────────┐  ┌────────────┐ │
│ │WR1: LS  │  │WR2: LS     │ │
│ │3P C25   │  │3P C25      │ │
│ └─────────┘  └────────────┘ │
│ PE-Klemme (→ HPA im HAK)    │
└─────────────────────────────┘
```

| Komponente | Spezifikation | Norm / Bemerkung |
|---|---|---|
| UV-Gehäuse | IP40 (innen) / IP54 (außen), Hutschiene 1–2 Reihen | DIN VDE 0660 (Gehäuse) |
| PV-Gruppenschalter im HAK | LS 3P C40/C50 (Summe aller WR) | **VDE 0100-443**: Stufung — Gruppenschalter > Einzelschalter |
| WR-Einzelschalter in UV | LS 3P C25/C32 je WR (je nach Leistung) | **VDE 0100-443 §542**: `I_B ≤ I_N ≤ I_Z` |
| PE in UV | Klemme → zurück zur HPA im HAK (≥ 10 mm² Cu) | **VDE 0100-600 §543** |
| FI Typ B (optional in UV) | 63 A / 30 mA, wenn Netzbetreiber es verlangt | **VDE-AR-N 4105 / VDE 0100-534** — Netzbetreiber-Vorgabe prüfen |

## 7. Abschnitt G: Batteriespeicher (AC-coupled, optional)

**Aufbau (≤ 20 kWh, bis 4 Head-Units parallel):**
```
HAK/UV „PV": LS 3P C16/C25 (Speicher-AC, Stufung unter Kuppelstelle)
        │ AC 3×2,5–6 mm² Cu
        ▼
┌─────────────────────────────────────┐
│  BATTERIESPEICHER (AC-coupled, LFP) │
│ ┌──────────┐  ┌──────────┐         │
│ │ Head-Unit│  │ Head-Unit│  … bis 4│
│ │ ~5 kWh   │  │ ~5 kWh   │         │
│ └──────────┘  └──────────┘         │
│ DC-Verteiler: LS + Sicherung je Unit│
│ PE-Klemme (→ HPA im HAK)           │
└─────────────────────────────────────┘
```

| Komponente | Spezifikation | Norm / Bemerkung |
|---|---|---|
| **Batteriespeicher-Head-Unit** (AC-coupled, LFP) | je ~5 kWh; **bis 4 parallel**; eigener WR + DC-Seite pro Unit. Schutzart: IP20–43 (innen) / IP54+IK08 (außen, UV-beständig) | **IEC 62619** (Zellensicherheit, Temperaturüberwachung via BMS); VDE-AR-N 4105 |
| **DC-Verteiler / String-Schalter** | DC-LS 1000/1500 V + Sicherung **je Head-Unit** („One unit per fuse") | **VDE 0100-712 §4**: eine Sicherung pro String/Unit; DC-Klasse nach WR (1000 V ≤ ~15 kWp / 1500 V >~18 kWp) |
| **DC-Verkabelung WR → Head-Unit** | PV-Dauerkabel (H1Z2Z2-J, 4/6 mm²), je Unit separat; `I_Z ≥ 1,25 · I_Nenn(Unit)` | **VDE 0100-443**: Querschnitt nach Umgebungstemp. korrigieren (Garage ~30 °C, außen 40–50 °C → −10…20 %) |
| **LS-Schalter Speicher-AC** (HAK oder UV „PV“) | 3P C16/C25; `I_out = P_AC(Speicher) / (√3 · 400 V)`; Stufung **unter** PV-Kuppelstelle | **VDE 0100-443 §542**: `I_B ≤ I_N ≤ I_Z`. Beispiele: 6,4 kW → C16; 8 kW → C20; 12,5 kW → C32 |
| **AC-Kabel Speicher ↔ HAK/UV** | Cu, 3×2,5–6 mm² (längenabhängig); DC/AC getrennt verlegen | **VDE 0100-443**: `I_Z ≥ I_N`; **VDE 0100-712 §4**: strikte DC/AC-Trennung |
| **PE-Anschluss Speicher-Gehäuse** | ≥ 4 mm² Cu → HPA-Schiene (R5) — **Pflicht je Head-Unit** | **VDE 0100-600 §542**: Hauptpotentialausgleich; Schutzklasse II: dedizierter PE entfällt, FI Typ B bleibt Pflicht |
| **DC-Überspannungsschutz** (falls BZA) | Typ 2, 1000/1500 V an Speicher-DC — nur bei Blitzschutzanlage & Freifeld-Aufstellung | **DIN EN 62305-4**; VDE 0100-712 §4 — ohne BZA: Herstellerangaben prüfen |
| **Kommunikation / Monitoring** | LAN (Cat 6) Speicher ↔ Router; getrennt vom Starkstrom (> 30 cm); ePRM-Gateway an bidirektionalen Zähler (AEGIS M132) für PV-Überschussladen & Lastmanagement | IEC 61851-23; VDE 0100-520 §7.6 (EMV-Trennung); VDE-AR-N 4105 |

## 8. Normen-Checkliste (vor Inbetriebnahme)

| # | Prüfung | Norm | Status |
|---|---------|------|--------|
| 1 | `maxFeedInKw` beim Netzbetreiber erfragt & WR-Leistung ≤ Limit | VDE-AR-N 4105 §6 | ☐ offen |
| 2 | Zähler bidirektional (Bestand: ja, AEGIS M132) | VDE-AR-N 4105 §7 | ☑ erfüllt (Bestand) |
| 3 | Kuppelstelle mit allpoligem Schalter + FI Typ B (empfohlen) | VDE-AR-N 4105 §6.3 / VDE 0100-534 | ☐ neu einbauen |
| 4 | LS-Schalter AC: `I_N ≥ I_out(WR)`, Stufung eingehalten | VDE 0100-443 §542 | ☐ prüfen (je WR-Leistung) |
| 5 | AC-Kabel: `I_Z` nach Verlegeart + Temperatur ≥ `I_N(LS)` | VDE 0100-443 §542 | ☐ prüfen (Länge messen) |
| 6 | String-Spannungsfenster: Voc_cold ≤ min(1500, WR_max) **und** Voc_hot ≥ WR_min | VDE 0100-712 §4 / VDE-AR-N 4105 | ☐ pro String berechnen (T_min/T_max des Standorts!) |
| 7 | MPPT-Parallelsummen: `n·I_sc ≤ WR_max` **und** `n·Imp ≤ WR_maxInputCurrentPerMpp` | VDE-AR-N 4105 §6 / VDE 0100-712 | ☐ pro MPPT prüfen |
| 8 | DC-Sicherung je String: `I_N ≥ I_sc(String)`, gG, 1000/1500 V | VDE 0100-712 §4 / VDE 0100-443 | ☐ je String dimensionieren |
| 9 | DC-Kabel: `I_Z` (Dach-Temperatur!) ≥ `1,25 · Imp(String)` | VDE 0100-443 §542 / IEC 62548 | ☐ je String prüfen (Dach-Temp. −10…20 %) |
| 10 | DC/AC-Kabel getrennt verlegt | VDE 0100-712 §4 | ☐ Verlegeweg planen |
| 11 | Modulrahmen-Erdung (Klasse B) → HPA; Schienen-Kontinuität geprüft | VDE 0100-600 §542/§543 / VDE 0100-712 | ☐ vor Ort verifizieren |
| 12 | WR-Gehäuse-PE → HPA (≥ 4 mm² Cu) | VDE 0100-600 §542 | ☐ neu anschließen |
| 13 | Erdungswiderstand gemessen (< 100 Ω / < 10 Ω bei Blitzschutz) | VDE 0100-534 / DIN VDE 0855 | ☐ **vor Inbetriebnahme messen** |
| 14 | FI-Prüfung (Bestand L3, R3) + neuer FI Typ B: Prüfdatum dokumentiert | VDE 0100-534 / DIN VDE 0107-100 | ☐ bei Inbetriebnahme testen |
| 15 | Blitzschutz: DC-Ableiter (Typ 2) falls PV in Blitzschutzzone | DIN VDE 0855-1 | ☐ prüfen (Blitzschutzanlage vorhanden?) |
| 16 | Inbetriebnahme-Protokoll + Übergabe an Netzbetreiber (Anmeldung PV) | VDE-AR-N 4105 §8 / EnWG | ☐ **vor Einspeisung anmelden!** |
| 17 | Speicher: LS-Schalter AC, Stufung unter Kuppelstelle; `I_N ≥ I_out(Speicher)` | VDE 0100-443 §542 | ☐ nur bei Speicher (je AC-Leistung) |
| 18 | Speicher: DC-Sicherung je Head-Unit (gG, ≥ I_sc der Unit); „One unit per fuse" | VDE 0100-712 §4 / VDE 0100-443 | ☐ nur bei Speicher (je Unit dimensionieren) |
| 19 | Speicher: DC-Kabel `I_Z` (Umgebungstemp.) ≥ `1,25 · I_Nenn(Unit)`; DC/AC getrennt | VDE 0100-443 §542 / IEC 62548 | ☐ nur bei Speicher (je Unit prüfen) |
| 20 | Speicher: Gehäuse-PE je Head-Unit → HPA (≥ 4 mm² Cu); BMS-Funktionstest | VDE 0100-600 §542 / IEC 62619 | ☐ nur bei Speicher (vor Inbetriebnahme) |
| 21 | Speicher: DC-Ableiter Typ 2 (falls BZA + Freifeld) | DIN EN 62305-4 / VDE 0100-712 | ☐ nur bei Speicher + BZA prüfen |

## 9. Leistungsklassen-Übersicht (8–25 kWp) — Planungsmatrix

| Anlagenleistung | WR-Typ (Beispiele) | DC-Klasse | MPPTs | Strings/MPPT (typ.) | AC-LS im HAK | UV „PV" nötig? |
|---|---|---|---|---|---|---|
| **8 kWp** | 3~ 8 kW (z. B. GoodWe ET-8000, Sungrow SH8) | 1000 V DC | 2× | 2–3 (je ~450 Wp Modul: ~16–20 Mod./String) | C16/C20 | Nein (HAK reicht, s. Inventar R4) |
| **10 kWp** | 3~ 8–10 kW (GoodWe ET-9600, Fronius Primo 10) | 1000 V DC | 2× | 2–3 (~20 Mod./String) | C20/C25 | Nein (Grenze — HAK-Plätze prüfen) |
| **15 kWp** | 3~ 12–15 kW (GoodWe ET-15K, Sungrow SH10RT) | 1000 V DC | 2–3× | 3 (~25 Mod./String) | C32/C40 | **Empfohlen** (HAK-Plätze knapp) |
| **20 kWp** | 3~ 15–20 kW (Sungrow SH110, GoodWe ET-20K) | 1000 V DC (ggf. 1500 V) | 3–4× | 3 (~28 Mod./String) | C40/C50 | **Ja** (UV „PV" vorsehen, s. Abschnitt F) |
| **25 kWp** | 3~ 20–25 kW (Sungrow SH110, GoodWe ET-25K) | **1500 V DC** (Pflicht bei >~18 kWp mit 450-W-Modulen) | 3–4× | 3 (~32 Mod./String, Voc_cold prüfen!) | C50/C63 | **Ja** (UV „PV" + ggf. 2. WR) |

> **Kritischer Punkt bei >18 kWp:** Mit 450-W-Modulen (Voc ~37 V) und 1000-V-WR: max. ~26 Module/String (kalt). Bei 1500-V-WR: bis ~38 Module/String. **Immer Voc_cold am Standort-T_min berechnen!**

## 10. Offene Daten (müssen vor finaler Planung erfasst werden)

| # | Datenpunkt | Woher? |
|---|-----------|--------|
| 1 | `maxFeedInKw` (vertraglich) | Netzbetreiber (Stadtwerke) — **erfragen** |
| 2 | Nennstrom HAK-Hauptschalter (R1) | Foto/Ablesung am Gerät — **Inventar Lücken füllen** |
| 3 | Nennstrom + Typ der FIs (L3, R3) | Ablesung am Gerät — **Inventar Lücken füllen** |
| 4 | `T_ambient_min` / `T_ambient_max` am Standort | Wetterdaten (z. B. DWD Extremwerte) — **für Voc_cold/Voc_hot** |
| 5 | WR-Modell + Datenblatt (maxInputVoltage, minInputVoltage, maxShortCircuitCurrentPerMpp, maxInputCurrentPerMpp) | Hersteller — **für String-Validierung** |
| 6 | Modul-Typ + Datenblatt (Voc, Voc_TempCoeff, Isc, Imp) | Hersteller — **für String-Validierung** (App: `SolarModules`-Tabelle) |
| 7 | WR-Standort + Kabellängen (AC: WR↔HAK, DC: WR↔Dach) | Vor-Ort-Aufmaß — **für I_Z-Berechnung** |
| 8 | Erdungswiderstand (Fundamenterdung) | Messung vor Ort — **Pflicht vor Inbetriebnahme** |
| 9 | Blitzschutzanlage vorhanden? (Ja/Nein) | Vor Ort — **bestimmt DC-Ableiter-Pflicht** |
| 10 | Freie HAK-Plätze (R4: Nummern 7–12, 17–23) | Foto/Abzählung — **bestimmt UV-PV-Bedarf** |
| 11 | Speicher-Modell + Datenblatt (Nennkapazität, AC-Leistung, Nennstrom DC je Unit, Anzahl Head-Units) | Hersteller — **für Abschnitt G (DC-Sicherung, Querschnitt, LS-Stufung)** |
| 12 | Speicher-Aufstellort (innen IP40 / außen IP54) + Kabellängen (AC: Speicher↔HAK/UV, DC: WR↔Unit) | Vor-Ort-Aufmaß — **für I_Z-Berechnung & Schutzart** |

---
*Erstellt: 2026-09-27 · Rolle: Elektromeister · Gültig für 8–25 kWp, 3~ Netzanschluss.*
*Dieses Dokument ist die **dauerhafte Referenz** für alle PV-Planungen in SolarPlanner. Bei Änderungen an Bestand (HAK) oder Normen: hier aktualisieren.*
