# Stromlaufplan Wallbox — Netzbetreiber → Ladestation (AC, 7–22 kW)

<!-- Rolle: Elektromeister. Gültig für stationäre Wallboxen (IC-CPD, Typ 2) an dreiphasigem
     Netzanschluss (400/230 V, TN-C-S), Ladeleistung 1×16 A (3,7 kW) bis 3×32 A (22 kW).
     Basis: HAUSANSCHLUSSKASTEN_INVENTAR.md (Bestand) + VDE/DIN-Normen.
     Normen: DIN VDE 0100-430 (Überschutz), -520 (Leitungen), -534 (FI/Berührungsspannung),
            VDE 0127-1 (Ladeeinrichtungen, ersetzt IEC 61851-1), DIN VDE 0127-3 (Typ 2/CCS),
            VDE 0100-600 (Erdung/PA), DIN EN 62351-1/-2 (Prüfung, Ladeinfrastruktur),
            VDE 0105-100 (Prüfung), IEC 61851-23 / OCPP (Kommunikation, optional).
     WICHTIG: Separater Stromlaufplan — PV-Anlage und Wärmepumpe werden NICHT berücksichtigt.
     AC = Wechselstrom (HAK → Wallbox), keine DC-Komponenten in diesem Plan
     (DC-Ladung CCS/CHAOCS ist kein Bestandteil dieser Planung). -->

## 0. Systemübersicht (Blockschaltbild)

```
┌───────────────┐   AC 400/230V     ┌───────────────────────────────────┐
│ NETZBETREIBER │══════════════════►│         HAK (Bestand)             │
│ Stadtwerke    │  3~ + N + PE      │ ┌────────────┐  ┌───────────────┐ │
│ (3×63 A?)     │                   │ │ Zähler     │  │ Hauptschalter │ │
│               │                   │ │ AEGIS M132 │  │ (R1, 63 A?)   │ │
└───────────────┘                   │ └─────┬──────┘  └───────┬───────┘ │
                                    │       │                 │         │
                                    │ ┌─────▼─────────────────▼───────┐ │
                                    │ │  HAK-Hutschiene (Bestand)     │ │
                                    │ └─────────────┬─────────────────┘ │
                                    │               │                   │
                                    │ ┌─────────────▼─────────────────┐ │
                                    │ │  NEU: Wallbox-Stromkreis      │ │
                                    │ │  (freie Pl. R4)               │ │
                                    │ │  LS 3P C16/C25 + FI Typ B     │ │
                                    │ └─────────────┬─────────────────┘ │
                                    └───────────────┼───────────────────┘
                                                    │ AC (Wechselstrom)
                                                    │ 5G × 6/10 mm² Cu (H07V-U)
                                                    │ Länge: ~20–40 m (HAK → Garage/Wand)
                                                    ▼
                                    ┌───────────────────────────────┐
                                    │   WALLBOX (IC-CPD, Typ 2)     │
                                    │   IP54/IP65, außen            │
                                    │   7 / 11 / 22 kW              │
                                    └──────┬─────────────────┬──────┘
                                           │ PE (4–10 mm²)   │ Ladekabel Typ 2
                                           ▼                 ▼ (3–5 m, im Gerät)
                                    ┌──────────────┐   ┌─────────────────┐
                                    │ HPA / Erdung │   │ ELEKTROFAHRZEUG │
                                    │ (R5 im HAK)  │   │ (Typ 2-Stecker, │
                                    └──────────────┘   │  Mode 3)        │
                                                       └─────────────────┘

Kommunikation (optional, getrennt vom Starkstrom):
                                    ┌───────────────────────┐
                                    │ LAN / WLAN / OCPP     │◄── Smart Charging,
                                    │ (Wallbox ↔ Router)    │    PV-Überschussladen
                                    └───────────┬───────────┘
                                                │ (getrennt verlegen, >30 cm Abstand)
                                    ┌───────────▼───────────┐
                                    │  Wallbox (Ethernet/   │
                                    │  WLAN, OCPP optional) │
                                    └───────────────────────┘
```

> **Hinweis:** Die Wallbox ist eine **Ladeeinrichtung der Kategorie IC-CPD** (VDE 0127-1).
> Sie enthält intern bereits: RCD-Watchdog (DC-Fehlerstromüberwachung), Leistungsmessung
> und ggf. RCD Typ A — der **zusätzliche FI Typ B** auf Gebäudeseite ist trotzdem
> Pflicht (s. Abschnitt 2, Begründung dort).

---

## 1. Abschnitt A: Netzbetreiber → HAK (AC, Bestand)

| Komponente | Spezifikation | Norm / Bemerkung |
|---|---|---|
| **Netzanschluss** (netzseitig) | 3×63 A, 50 Hz, TN-C-S (Annahme — vor Ort verifizieren) | VDE 0100-704; Netzbetreiber (Stadtwerke) |
| **Zähler** AEGIS PLUS M132 (GLIEMATO) | 400 V, 5(60) A, bidirektional, ePRM | DIN EN 50470-1; **wichtig für PV-Überschussladen** — Wallbox kann die Bezugs-/Einspeisemessung des Zählers über LAN/Smart-Meter-Gateway auslesen |
| **Hauptschalter / LS-Hauptabsicherung** (R1 im HAK) | 3P, vermutlich C63 A — **Nennstrom ablesen!** | VDE 0100-430; bestimmt verfügbare Restkapazität für den Wallbox-Kreis |
| **Übergabepunkt** (L2, Klappdeckel) | Klemmenblock Zähler → Hausinstallation — **Inhalt dokumentieren** | VDE 0100-704 §5.3 |

> ⚠️ **Offen:** Nennstrom des Hauptschalters (R1) ablesen. Bei 63 A: verfügbarer Reststrom nach Abzug der bestehenden Endstromkreise (R2/R3) bestimmt die maximal mögliche Ladeleistung. Faustformel: `I_verfügbar = I_Haupt − Σ I_B(Endstromkreise)`; der Wallbox-LS darf die Restkapazität nicht dauerhaft übersteigen.

---

## 2. Abschnitt B: HAK → Wallbox (AC, neu)

### 2.1 Stromkreis im HAK (freie Plätze R4: Nr. 7–12, 17–23)

| Komponente | Spezifikation | Norm / Bemerkung |
|---|---|---|
| **LS-Schalter Wallbox** (im HAK) | 3P, **C16 / C25 A**, C-Charakteristik (Wechselrichter im Fahrzeug → hohe Einschaltströme, C statt B) | **VDE 0100-430 §542**: `I_B ≤ I_N ≤ I_Z`. `I_B` = eingestellte Ladestromstärke (s. Dimensionierungstabelle). C-Charakteristik: **Pflicht** für Ladeeinrichtungen (VDE 0127-1) |
| **FI-Schutzschalter Wallbox** (im HAK) — **Pflicht** | 3P+N, **40 A / 30 mA**, **Typ B** (oder Typ A + separater DC-Überschussstrom-Schutz) | **VDE 0127-1 / VDE 0100-534**: Ladeeinrichtungen erzeugen DC-Fehlerströme (Gleichrichter im Fahrzeug, PV-Überschuss). FI Typ A erkennt diese **nicht** zuverlässig → **FI Typ B ist Pflicht für IC-CPD**. Alternativ: FI Typ A + DC-RCD (DC-Fehlerstromüberwachung nach VDE 0127-1 §…) — in der Praxis: **einfach Typ B einbauen** |
| Hutschiene-Platz | 2 Module (LS + FI) = ~4 HE; freie Plätze R4 vorhanden | — s. Inventar |

> **Warum FI Typ B (und nicht nur der interne RCD-Watchdog)?**
> Der im Wallbox-Gehäuse integrierte DC-Fehlerstromüberwacher (RCD-Watchdog) schützt nur gegen
> **DC-Überschussströme im Ladekabel** und ersetzt **nicht** den Berührungsschutz auf
> Gebäudeseite (VDE 0127-1). Der **FI Typ B im HAK** ist der vorgeschriebene
> Schutz gegen AC- und DC-Berührungsströme auf der Zuleitungsseite — **Pflicht, keine Empfehlung**.

### 2.2 Leitung HAK → Wallbox (Garage / Außenwand)

| Komponente | Spezifikation | Norm / Bemerkung |
|---|---|---|
| **Zuleitung Wallbox** (Starkstrom) | **H07V-U 5G × 6 mm² Cu** (3L + N + PE) für ≤16 A / **5G × 10 mm² Cu** für 32 A, in Schutzrohr (außen) / Leitungsführungskanal | **VDE 0100-520**: `I_Z ≥ I_N`. Außenverlegung: **H07V-U** (nicht NYM-J!) in Schutzrohr oder Leitungsführungskanal; `I_Z` nach Verlegeart + Umgebungstemperatur korrigieren (Sommer, Garage ~35 °C) |
| **Leitungslänge** | typ. 20–40 m (HAK Keller → Garage/Außenwand) | **Spannungsfall: `ΔU ≤ 3 %`** (VDE 0100-520 §7.4, Endstromkreise) — bei 3×16 A und >25 m: **zwingend prüfen**, ggf. auf 10 mm² gehen |
| **PE-Leiter** | 4 mm² Cu (bei L ≤ 16 mm²) / **10 mm² Cu** (bei L = 25/35 mm²) | VDE 0100-534 §7.2 (PE-Tabelle); bei H07V-U 5G-Adern immer mitverlegt |
| **Verlegung außen** | Schutzrohr (PE/Alu) oder LWK, Wanddurchführung mit Dichtmanschette | VDE 0100-520; Schutzart der Durchführung mind. IP44 |
| **Trennung** | Getrennt von Kommunikationskabeln (> 30 cm Abstand oder getrennte Kanäle) | VDE 0100-520 §7.6; EMV-Trennung |

### 2.3 Wallbox (Ladeeinrichtung, außen)

| Komponente | Spezifikation | Norm / Bemerkung |
|---|---|---|
| **Wallbox** (IC-CPD, Typ 2) | 1×16 A (3,7 kW), 3×16 A (11 kW) oder **3×32 A (22 kW)**; einstellbar 6–32 A/Phase | **VDE 0127-1** (Ladeeinrichtungen), IEC 61851-1; Schutzklasse II **oder** Klasse I mit PE-Anschluss |
| **Ladeanschlusseinheit (LAE)** | Typ 2-Stecker, Mode 3, **integriertes Ladekabel** (typ. 5 m) oder Aufrollsystem | **DIN VDE 0127-3 / IEC 62196-2** (Typ 2), IEC 61851-23 |
| **Eingangsstrom einstellbar** | 6–32 A/Phase (in Schritten, z. B. 8/10/13/16/20/25/32 A) | VDE 0127-1: **Einstellung ≤ LS-Nennstrom** — bei C16: max. 13 A einstellen (C-Char., Auslösefaktor); bei C25: max. 16 A (C-Char.) |
| **RCD-Watchdog** (im Gerät) | DC-Fehlerstromüberwachung, Auslösung bei > 6 mA DC im Ladekreis (Kabel) | VDE 0127-1 — **ersetzt nicht** den FI Typ B (s. o.) |
| **Integrierte Messung** | Energiezähler (Bezug/Einspeisung, klassifiziert) | VDE 0127-1; für Abrechnung / PV-Überschussladen |
| **Schutzart** (außen) | mind. **IP54**, bei Aufstellung im Freien empfohlen IP65; IK08 (mechanischer Schutz) | VDE 0127-1 / Herstellerangabe; Aufstellungsort: Garage (IP54) vs. Außenwand (IP65, UV-beständig) |
| **Montagehöhe** | 120–145 cm (Steckerbuchse) über Boden, Zugang frei | Herstellerangabe; ergonomische Montage |
| **PE-Anschluss Wallbox** (Klasse I) | 4–10 mm² Cu → HPA-Schiene (R5 im HAK) | **VDE 0100-600 §542** — Pflicht (Klasse I); bei Schutzklasse II entfällt PE, FI Typ B bleibt Pflicht |

### 2.4 Erdung & Potentialausgleich (quer durch alle Abschnitte)

| Komponente | Spezifikation | Norm / Bemerkung |
|---|---|---|
| **Fundamenterdung** (Bestand) | Widerstand messen: < 100 Ω (allg.) / **< 10 Ω** bei Blitzschutz | VDE 0100-534 / DIN EN 62305 — **vor Inbetriebnahme messen** |
| **HPA-Schiene im HAK** (R5, Bestand) | PE-Hauptleiter + Wallbox-PE + Metallinstallationen zusammenführen | **VDE 0100-600 §542** — Hauptpotentialausgleich |
| **Garagenboden / Fundament** (bei Außenwand) | Bei Aufstellung im Freien: Erdung des Gebäudes prüfen; Metallteile in der Nähe (Tor, Rahmen) → HPA | VDE 0100-600 §543 — Fremdleitungen |
| **Blitzschutz** (falls vorhanden) | Wallbox im Freifeld nahe Blitzschutzanlage → Überspannungsschutz Typ 2 an Zuleitung | DIN EN 62305-4 — prüfen, ob Blitzschutzanlage vorhanden ist |

> ⚠️ **Wichtig:** Die Wallbox steht außen (Garage/Außenwand). Der PE-Weg über die
> H07V-U-Zuleitung muss **ununterbrochen** sein; bei Schutzklasse II-Gerät entfällt der
> dedizierte PE-Anschluss, aber der **FI Typ B bleibt Pflicht** (DC-Fehlerströme des
> Fahrzeugs).

---

## 3. Abschnitt C: Kommunikation (getrennt vom Starkstrom) — optional

| Komponente | Spezifikation | Norm / Bemerkung |
|---|---|---|
| **LAN-Kabel** (Wallbox ↔ Router) | Cat 6, max. 100 m; oder WLAN (2,4/5 GHz) | IEC 61851-23 / OCPP; Herstellerangabe (z. B. Gem: LAN + WLAN) |
| **OCPP / Cloud-Anbindung** (optional) | OCPP 1.6/2.0, Lastmanagement, Fernwartung | IEC 61851-23 — nur wenn gewünscht (Fleet, Abrechnung) |
| **PV-Überschussladen** (optional) | Wallbox liest Einspeisung aus: Smart-Meter-Gateway des AEGIS M132 (Bestand) / LAN-Spannungsmessung an der Kuppelstelle | **VDE-AR-N 4105 / Herstellerangabe**; keine zusätzliche Messung nötig, wenn bidirektionaler Zähler vorhanden (Bestand: ja) |
| **Verlegung** | Getrennt von H07V-U (> 30 cm Abstand oder getrennte Kanäle) | VDE 0100-520 §7.6; EMV-Trennung |

> **Hinweis:** Kommunikation ist für die Grundfunktion der Wallbox **nicht** erforderlich —
> nur für Smart Charging (PV-Überschuss, Zeitfenster) und Fernüberwachung. Ohne Router-/WLAN-Empfang
> am Aufstellort: auf **festen LAN-Anschluss** zurückgreifen.

---

## 4. Dimensionierungstabelle — Wallbox-Stromkreis (Zusammenfassung)

| Ladeleistung | `I_B` / Phase | LS 3P (C-Char.) | FI Typ B (Pflicht) | Zuleitung H07V-U Cu (`I_Z` ≥ `I_N`) | PE (min.) |
|---|---|---|---|---|---|
| **3,7 kW** (1×16 A) | 16 A | C20 / C25¹ | 40 A / 30 mA Typ B | 5G × 6 mm² (`I_Z ≈ 27–34 A`) | 4 mm² |
| **11 kW** (3×16 A) | 16 A/Ph. | C20 / C25¹ | 40 A / 30 mA Typ B | 5G × 6 mm² (`I_Z ≈ 27–34 A`) | 4 mm² |
| **18 kW** (3×25 A) | 25 A/Ph. | C32 | 40 A / 30 mA Typ B | 5G × 10 mm² (`I_Z ≈ 48–62 A`) | 10 mm² |
| **22 kW** (3×32 A) | 32 A/Ph. | C40² / C50² | **63 A** / 30 mA Typ B | 5G × 16 mm² (`I_Z ≈ 72–93 A`) | 16 mm² |

¹ **C-Charakteristik:** Auslösefaktor ~5–10× → bei C20: max. einstellbarer Ladestrom 13 A (C-Char., `I_N/1,5`); bei C25: max. 16 A. **Immer die Wallbox auf ≤ LS-Nennstrom einrichten** (VDE 0127-1).
² Bei 3×32 A: `P = √3 · 400 V · 32 A ≈ 22,2 kW`; LS C50 wenn Restkapazität des HAK es hergibt.

> **Spannungsfall-Prüfung (Pflicht, VDE 0100-520 §7.4):**
> `ΔU % = (√3 · I_B · L_mitte · ρ) / A · 100` (Cu: `ρ ≈ 0,023 Ω·mm²/m`)
> Beispiel: 16 A/Phase, 30 m, 6 mm² → `ΔU ≈ (1,73·16·30·0,023)/6 · 100 ≈ **3 %**` → **Grenzwert erreicht,
> bei > 25 m auf 10 mm² gehen.**

---

## 5. Prüfung & Dokumentation (vor Inbetriebnahme) — DIN EN 62351

| Schritt | Norm / Anforderung |
|---|---|
| **Schutzleiterwiderstand** (PE-Strecke HAK → Wallbox) | VDE 0125-1 / DIN EN 62351-1: `R_PE × I_d ≤ U_a` (FI 30 mA → `R_PE < 167 Ω`) |
| **Isolationswiderstand** (L/N/PE → Erde) | VDE 0125-1: ≥ 1 MΩ (bei 400 V); Messung mit 500 V DC |
| **FI-Prüfung** (Typ B: AC + DC-Fehlerstrom) | VDE 0125-1 / DIN EN 61008: AC-Auslösestrom ≤ 30 mA, Auslösezeit < 400 ms; **DC-Fehlerstromprüfung** (Typ B: 6 mA DC) |
| **RCD-Watchdog-Prüfung** (Wallbox intern, DC im Ladekabel) | VDE 0127-1: Auslösung bei > 6 mA DC — Hersteller-Selbsttest / Prüfprotokoll |
| **HPA-Prüfung** (Kontinuität Wallbox-Gehäuse → HPA-Schiene) | VDE 0125-1: Widerstand < 0,2 Ω (Klasse I) |
| **Erdungswiderstand messen** (Fundamenterdung) | VDE 0100-534: < 100 Ω (bzw. < 10 Ω bei Blitzschutz) |
| **Ladekabel-Prüfung** (Typ 2, 5 m) | IEC 61851-23: Kontinuität, Isolationswiderstand — **Pflicht vor Inbetriebnahme** |
| **Prüfprotokoll** (alle Messwerte dokumentieren) | DIN EN 62351-1; **Pflicht** — Abnahme durch Elektroinstallateur |
| **Inbetriebnahme-Protokoll Wallbox** (eingestellter Strom, Ladeleistung) | VDE 0127-1; Herstellerangaben (z. B. Gem, Trydan) |
| **Abnahmeprotokoll** (Elektro + ggf. Kfz) | VDE 0125-1; signiert durch Installateur + Auftraggeber |

---

## 6. Offene Punkte (vor Baubeginn klären)

- [ ] **Nennstrom des Hauptschalters (R1)** ablesen → bestimmt maximale Ladeleistung
- [ ] **Bestehende Endstromkreise (R2/R3)** inventarisieren → Restkapazität des HAK berechnen
- [ ] **Inhalt des Klappdeckels (L2)** dokumentieren → Übergabepunkt Zähler → Hausinstallation
- [ ] **Kennzeichnung der FIs (L3, R3)** ablesen: Nennstrom, FI-Typ, Prüfdatum
- [ ] **Erdungswiderstand messen** (Fundamenterdung) — Voraussetzung für Wallbox-Erdung
- [ ] **Leitungsweg HAK → Aufstellort** planen (Länge, Verlegeart: Schutzrohr/LWK) → Kabelquerschnitt final bestimmen
- [ ] **Aufstellort festlegen**: Garage (IP54) oder Außenwand (IP65, UV); Montagehöhe 120–145 cm
- [ ] **Ladeleistung wählen**: 3,7 / 11 / 22 kW — abhängig von Restkapazität des HAK und Fahrzeug (max. Ladeleistung des EV!)
- [ ] **Kommunikation**: LAN-/WLAN-Empfang am Aufstellort prüfen; OCPP gewünscht?
- [ ] **PV-Überschussladen** gewünscht? → Smart-Meter-Anbindung an AEGIS M132 (Bestand)
- [ ] **Netzspannung & Phasenzuordnung** vor Ort verifizieren (400/230 V, 3~)
- [ ] **Blitzschutzanlage vorhanden?** (Ja/Nein) → bestimmt Überspannungsschutz-Pflicht an Zuleitung

---

## 7. Normen-Referenzen (Zusammenfassung)

| Norm | Anwendung in diesem Stromlaufplan |
|---|---|
| **DIN VDE 0127-1** | Ladeeinrichtungen (IC-CPD): FI Typ B Pflicht, LS C-Charakteristik, RCD-Watchdog, Einstellgrenzen |
| **DIN VDE 0127-3 / IEC 62196-2** | Ladeanschlusseinheit: Typ 2-Stecker, Mode 3, Ladekabel |
| **IEC 61851-1 / -23** | Ladeinfrastruktur: Konformitätsbewertung, Kommunikation (OCPP) |
| **DIN VDE 0100-430** | Überspannungsschutz: LS-Schalter (C16–C50), FI Typ B |
| **DIN VDE 0100-520** | Leitungen: H07V-U, Querschnittswahl, Spannungsfall ≤ 3 % |
| **DIN VDE 0100-534** | Schutz durch FI: PE-Leiter, Erdungswiderstand < 100 Ω, DC-Fehlerströme |
| **DIN VDE 0100-600** | Erdung & Potentialausgleich: HPA-Schiene, Wallbox-Gehäuse → PE (Klasse I) |
| **DIN VDE 0125-1 / DIN EN 62351-1** | Elektrische Prüfung: Schutzleiterwiderstand, Isolationswiderstand, FI-Test (AC+DC) |
| **DIN EN 62305** | Blitzschutz: Überspannungsschutz Typ 2 an Zuleitung (falls BZA vorhanden) |
| **IEC 61851-23 / OCPP** | Kommunikation: LAN/WLAN, Lastmanagement, Fernüberwachung (optional) |
| **VDE-AR-N 4105** | PV-Überschussladen: Anbindung an bidirektionalen Zähler (Bestand AEGIS M132) |
