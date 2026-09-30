# Komponenten-Katalog

**Anlage:** Vaillant aroTHERM pro VWL 115/7.1 A (11,5 kW) + PV-Anlage (8–25 kWp) + Batteriespeicher (≤ 20 kWh, bis 4 Head-Units) + Wallbox (IC-CPD, 3,7–22 kW)
**Quellen:** `data/normen/waermepumpe-normen-uebersicht.md` (Kap. 5), `STROMLAUFPLAN_PV.md`, `STROMLAUFPLAN_WALLBOX.md`

> **Klassifizierung:** `Hydraulisch`, `Elektrik` (aktuell) · `Kommunikation` *(teilweise — Wallbox, optional)*
> **Min/Max:** Berechnungsformeln mit Referenzen auf Parameter und andere Komponenten

---

## 0. Identifier-System

### Format
```
{Klasse}.{Unterklassifizierung}.{Name}
 3 Zeichen   3 Zeichen           max. 21 Zeichen
```

**Gesamtlänge:** max. **29 Zeichen** (3 + 1 Punkt + 3 + 1 Punkt + 21)

### Abkürzungen — Klasse (3 Zeichen)

| ID | Klasse |
|----|--------|
| `HYD` | Hydraulisch |
| `ELE` | Elektrik |
| `KOM` | Kommunikation *(geplant)* |

### Abkürzungen — Unterklassifizierung (3 Zeichen)

| ID | Unterklassifizierung |
|----|---------------------|
| `KAL` | Kaltwasser (Trinkwasser-Kaltleitung) |
| `WAR` | Warmwasser (Trinkwasser-Warmleitung, Boiler, Zirkulation) |
| `HEI` | Heizung (WP, Heizkreis, Puffer, FBH) |

### Parameter
```
PARAM_{Name}
 5 Zeichen + _ + max. 23 Zeichen
```

### Abgeleitete Größen (Dimensionierung)
```
CALC_{Name}
 5 Zeichen + _ + max. 23 Zeichen
```

---

## 1. Haushaltsparameter (Eingabewerte)

Diese Parameter beschreiben das konkrete Gebäude/Haushalt und dienen als Eingabe für die
Berechnung der Komponentenanzahlen.

| ID | Name | Typ | Beschreibung | Beispielwert |
|----|------|-----|-------------|:---:|
| `PARAM_Personen` | Personen im Haushalt | int (1–8) | Anzahl der dauerhaft wohnenden Personen; bestimmt HW-Bedarf und Boiler-Größe | 4 |
| `PARAM_Etagen` | Anzahl Wohnetagen (EG + OG) | int (1–4) | Geschosse mit beheizten Wohnräumen; bestimmt Verteiler- und Zirkulationsanzahl | 2 |
| `PARAM_Keller` | Keller vorhanden? | bool (0/1) | 1 = beheizter Keller mit Sanitäranlagen, 0 = kein Keller / unbeheizt | 1 |
| `PARAM_Baeder` | Anzahl Bäder (mit HW) | int (1–6) | Räume mit Mischbatterie-Dusche/Wanne; bestimmt HW-Abnahmestellen | 2 |
| `PARAM_Kuechen` | Küchen mit Spülbecken | int (1–2) | Anzahl Küchenbereiche mit Mischbatterie + Geschirrspüler | 1 |
| `PARAM_FBH_Zonen` | FBH-Zonen (Schleifen) | int (1–20) | Anzahl Fußbodenheizung-Schleifen; 1 Zone ≈ 1 Raum oder Teilraum | 4 |
| `PARAM_Radiatoren` | Radiatoren-Kreise vorhanden? | bool (0/1) | 1 = zusätzlich zu FBH auch Radiatoren-Heizkreis; beeinflusst Puffer/PWT | 0 |
| `PARAM_Garten` | Außenwasseranschluss (Garten) | bool (0/1) | 1 = Gartenbewässerung mit eigenem Absperrventil + RFV | 1 |
| `PARAM_WP_KW` | WP-Nennleistung (kW) | float | Heizleistung der Wärmepumpe bei A7/W35; bestimmt Puffer- und Pumpenauslegung | 10.25 |
| `PARAM_HW_Schleife_m` | HW-Leitungslänge (m) | int (0–50) | Summe der Warmwasser-Leitungsstrecke; > 15 m → Zirkulationspumpe erforderlich | 28 |
| `PARAM_PV_kWp` | PV-Anlagenleistung (kWp) | float (0–25) | Nennleistung der PV-Anlage; 0 = keine PV. Bestimmt WR-Größe, Kuppelstelle, UV-Bedarf | 10 |
| `PARAM_PV_Strings` | Anzahl PV-Strings | int (2–8) | Gesamtzahl der Strings (alle MPPTs zusammen); bestimmt DC-Sicherungen und Kabelanzahl | 4 |
| `PARAM_WB_kW` | Wallbox-Ladeleistung (kW) | float (0–22) | Nennladeleistung der Wallbox; 0 = keine Wallbox. Bestimmt LS/FI/Querschnitt (s. Dimensionierungstabelle) | 11 |
| `PARAM_WB_Aussen` | Wallbox außen (Freifeld)? | bool (0/1) | 1 = Aufstellung im Freien → IP65, UV-beständig; 0 = Garage (IP54) | 1 |
| `PARAM_WB_Komm` | Wallbox-Kommunikation gewünscht? | bool (0/1) | 1 = LAN/WLAN + ggf. OCPP für Smart Charging / PV-Überschussladen; 0 = nur lokale Bedienung | 1 |
| `PARAM_WB_Ueberschuss` | PV-Überschussladen gewünscht? | bool (0/1) | 1 = Wallbox liest Einspeisung am bidirektionalen Zähler (AEGIS M132, Bestand); erfordert `PARAM_PV_kWp > 0` | 0 |
| `PARAM_BZA` | Blitzschutzanlage vorhanden? | bool (0/1) | 1 = BZA → Überspannungsschutz Typ 2 an der Wallbox-Zuleitung; Erdungswiderstand < 10 Ω | 0 |
| `PARAM_WB_Leitung_m` | Leitungslänge HAK → Wallbox (m) | int (5–60) | Zuleitungsstrecke; > 25 m bei ≥ 3×16 A → Spannungsfallprüfung zwingend, ggf. Querschnitt erhöhen | 30 |
| `PARAM_BAT_kWh` | Batteriespeicher-Nennkapazität (kWh) | float (0–20) | Gesamtkapazität aller Head-Units; 0 = kein Speicher. AC-Gleichstromspeicher (LFP) typ. 5–20 kWh | 10 |
| `PARAM_BAT_Units` | Anzahl Head-Units (Module) | int (1–4) | Anzahl parallel geschalteter Speicher-Head-Units (je ~5 kWh); bestimmt DC-Leitungen und PE-Anschlüsse | 2 |
| `PARAM_BAT_DC_A` | Nennstrom pro Head-Unit (A DC) | float (20–60) | Lade-/Entladestrom einer Head-Unit am DC-Bus (typ. 48–60 V × P_DC); bestimmt Querschnitt der DC-Zuleitung | 45 |
| `PARAM_BAT_AC_kW` | AC-Leistung Speicher (kW) | float (0–12,5) | Summe der Wechselrichter-Leistung aller Head-Units; bestimmt AC-Kabel und LS-Stufung | 6.4 |
| `PARAM_BAT_Aussen` | Speicher außen (Freifeld)? | bool (0/1) | 1 = Aufstellung im Freien → IP54/IP65, UV-beständig; 0 = Garage/Werkstatt (IP20–43) | 1 |

---

## 2. Komponenten

| ID | Klasse | Unterklassifizierung | Name (lang) | Norm | Min (Formel) | Max (Formel) |
|----|--------|---------------------|-------------|------|:---:|:---:|
| `HYD.KAL.Hausanschluss` | Hydraulisch | Kaltwasser | Hauswasseranschluss (Trinkwasser) | DIN 1986-100 | `1` | `1 + PARAM_Garten` |
| `HYD.KAL.Zaehler_Absperrung` | Hydraulisch | Kaltwasser | Zähler / Absperrventil (Wasserzähler) | DIN 1986-100 | `1` | `1 + PARAM_Garten` |
| `HYD.KAL.KW_Verteiler` | Hydraulisch | Kaltwasser | Kaltwasser-Verteiler (Hauptleitung) | DIN 1986-100 | `1` | `PARAM_Etagen + PARAM_Keller` |
| `HYD.WAR.Boiler_TWW` | Hydraulisch | Warmwasser | Warmwasser-Boiler (Trinkwasser) | DIN EN 13203 | `1` | `1 + (PARAM_Etagen > 2 ? 1 : 0)` |
| `HYD.WAR.HW_Verteiler` | Hydraulisch | Warmwasser | Warmwasser-Verteiler (HW-Hauptleitung) | DIN 1986-100 | `1` | `PARAM_Etagen + PARAM_Keller` |
| `HYD.WAR.Zirkulationspumpe` | Hydraulisch | Warmwasser | Zirkulationspumpe (HW-Schleife) | EEI ≤ 0,23; EU-Ökodesign (EU) 206/2012 | `PARAM_HW_Schleife_m > 15 ? 1 : 0` | `PARAM_Etagen + PARAM_Keller` |
| `HYD.HEI.Waermepumpe` | Hydraulisch | Heizung | Wärmepumpe (aroTHERM pro VWL 115/7.1 A) | VDE-AR-E 2105-100; DIN EN 14521-1 | `1` | `2` |
| `HYD.HEI.Pumpe_WP_Seite` | Hydraulisch | Heizung | Heizungspumpe WP-Seite (Primärkreis) | DIN EN ISO 5149; EEI ≤ 0,23 | `HYD.HEI.Waermepumpe` | `HYD.HEI.Waermepumpe` |
| `HYD.HEI.Rueckflussverhinderer` | Hydraulisch | Heizung | Rückflussverhinderer (WP-Seite) | VDE-AR-E 2105-100 | `HYD.HEI.Waermepumpe` | `HYD.HEI.Waermepumpe + PARAM_Garten` |
| `HYD.HEI.Schmutzfanger_Filter` | Hydraulisch | Heizung | Filter / Schmutzfänger (≤ 2 mm) | DIN 1986-100 | `HYD.HEI.Waermepumpe` | `HYD.HEI.Waermepumpe + PARAM_Garten` |
| `HYD.HEI.Durchflusswaechter` | Hydraulisch | Heizung | Durchflusswächter (Mindestumlauf) | VDE-AR-E 2105-100 | `HYD.HEI.Waermepumpe` | `HYD.HEI.Waermepumpe` |
| `HYD.HEI.Pufferspeicher` | Hydraulisch | Heizung | Pufferspeicher (Heizpuffer) | DIN EN 12897 | `PARAM_Radiatoren ? 1 : (PARAM_FBH_Zonen > 6 ? 1 : 0)` | `HYD.HEI.Waermepumpe + PARAM_Radiatoren` |
| `HYD.HEI.Plattenwaermetauscher` | Hydraulisch | Heizung | Plattenwärmetauscher (Systemtrennung) | DIN EN 12897 | `HYD.HEI.Pufferspeicher` | `HYD.HEI.Pufferspeicher` |
| `HYD.HEI.Sicherheitsventil_3bar` | Hydraulisch | Heizung | Sicherheitsventil (3 bar) | DIN EN 12828 | `HYD.HEI.Waermepumpe` | `HYD.HEI.Waermepumpe + PARAM_Radiatoren + (HYD.HEI.Pufferspeicher > 0 ? 1 : 0)` |
| `HYD.HEI.Membranausdehnungsgefaess` | Hydraulisch | Heizung | Membranausdehnungsgefäß (vorgepresst) | DIN EN 12828 | `HYD.HEI.Waermepumpe` | `HYD.HEI.Sicherheitsventil_3bar` |
| `HYD.HEI.Entluftungsventil_auto` | Hydraulisch | Heizung | Entlüftungsventil (automatisch) | DIN EN 12828 | `HYD.HEI.Waermepumpe` | `HYD.HEI.Sicherheitsventil_3bar + ceil(PARAM_FBH_Zonen / 4)` |
| `HYD.HEI.Pumpe_Heizkreis` | Hydraulisch | Heizung | Heizungspumpe Heizkreis (Sekundärseite) | DIN EN ISO 5149; EEI ≤ 0,23 | `HYD.HEI.Waermepumpe` | `HYD.HEI.Waermepumpe + PARAM_Radiatoren` |
| `HYD.HEI.Absperrventil_Vorlauf` | Hydraulisch | Heizung | Absperrventil Vorlauf (Heizkreis) | DIN 1986-100 | `2 × HYD.HEI.Pumpe_Heizkreis` | `2 × (HYD.HEI.Waermepumpe + PARAM_Radiatoren)` |
| `HYD.HEI.Absperrventil_Ruecklauf` | Hydraulisch | Heizung | Absperrventil Rücklauf (Heizkreis) | DIN 1986-100 | `2 × HYD.HEI.Pumpe_Heizkreis` | `2 × (HYD.HEI.Waermepumpe + PARAM_Radiatoren)` |
| `HYD.HEI.FBH_Verteiler` | Hydraulisch | Heizung | Verteiler (Fußbodenheizung, n-Wege) | — | `1` | `PARAM_Etagen + PARAM_Keller` |
| `HYD.HEI.FBH_Schleife` | Hydraulisch | Heizung | Fußbodenheizung-Schleife (PEX-Rohr) | VDI 2034; DIN EN ISO 10555 | `PARAM_FBH_Zonen` | `PARAM_FBH_Zonen × 2` |
| `HYD.WAR.Mischbatterie` | Hydraulisch | Warmwasser | Mischbatterie (KW + HW) | DIN EN 813 / DIN EN 215 | `PARAM_Baeder + PARAM_Kuechen` | `(PARAM_Baeder + PARAM_Kuechen) × (PARAM_Etagen + PARAM_Keller)` |
| `HYD.KAL.Verbraucher_nur_KW` | Hydraulisch | Kaltwasser | Kaltwasser-Verbraucher (GSP, WM, etc.) | DIN 1986-100 | `PARAM_Kuechen + PARAM_Keller` | `(PARAM_Baeder + PARAM_Kuechen) × 2 + PARAM_Garten` |
| `HYD.KAL.RFV_Gartenanschluss` | Hydraulisch | Kaltwasser | Rückflussverhinderer Garten (Trinkwasserschutz) | DIN 1986-100; DVGW W274 | `PARAM_Garten` | `PARAM_Garten × 3` |
| `HYD.HEI.Zuleitung_Fuellwasser` | Hydraulisch | Heizung | Zuleitung Wärmepumpe (Füllwasser, nur KW) | DIN 1986-100 | `HYD.HEI.Waermepumpe` | `HYD.HEI.Waermepumpe + PARAM_Radiatoren` |
| `ELE.STK.LS_Schalter_WP` | Elektrik | Starkstrom | LS-Schalter WP (3P B16 A, HAK) | VDE 0100-430 §542: `I_B ≤ I_N` | `HYD.HEI.Waermepumpe` | `= LS_Schalter_WP (1:1)` |
| `ELE.STK.FI_Schutzschalter` | Elektrik | Starkstrom | FI-Schutzschalter WP (3P+N 40 A/30 mA Typ A, HAK) | VDE 0100-430; empfohlen (Keller = feucht) | `HYD.HEI.Waermepumpe` | `= LS_Schalter_WP (1:1)` |
| `ELE.STK.Zuleitung_Starkstrom` | Elektrik | Starkstrom | Zuleitung WP (NYM-J 5×6 mm² Cu, ~15–25 m) | VDE 0100-520: `I_Z ≥ I_N = 16 A` | `HYD.HEI.Waermepumpe` | `= LS_Schalter_WP (1:1)` |
| `ELE.SCH.Trennschalter` | Elektrik | Schaltschrank/Verteiler | Trennschalter WP lokal (3P B16 A, Sichtkontakt) — **Pflicht** | VDE-AR-E 2105-100 §7.4; VDE 0105-100 | `HYD.HEI.Waermepumpe` | `= LS_Schalter_WP (1:1)` |
| `ELE.SCH.Klemmenleiste` | Elektrik | Schaltschrank/Verteiler | Klemmenleiste (E-Box WP: PE-Anschluss + Kommunikation) | VDE 0100-600 §542 (PA) | `HYD.HEI.Waermepumpe` | `= LS_Schalter_WP (1:1)` |
| `ELE.ERD.PE_Anschluss` | Elektrik | Erdung/Potentialausgleich | PE-Anschluss WP-Gehäuse (4 mm² Cu → HPA-Schiene R5) | VDE 0100-600 §542 — **Pflicht** | `HYD.HEI.Waermepumpe` | `= LS_Schalter_WP (1:1)` |
| `ELE.ERD.HPA_Anschluss` | Elektrik | Erdung/Potentialausgleich | HPA-Anschluss (metallene Installationen Keller → Schiene) | VDE 0100-600 §543 — **Pflicht** bei WP im Keller | `1` | `PARAM_Etagen + PARAM_Keller` |
| `ELE.STK.Kuppelstelle_PV` | Elektrik | Starkstrom | Kuppelstelle PV (LS 3P C-Char, HAK) — allpoliger Schalter | VDE-AR-N 4105 §6.3; VDE 0100-443 §542 | `PARAM_PV_kWp > 0 ? 1 : 0` | `= Kuppelstelle_PV (1:1)` |
| `ELE.STK.FI_TypB_PV` | Elektrik | Starkstrom | FI Typ B PV (40–63 A / 30 mA, HAK) — für DC-Fehlerströme | VDE-AR-N 4105 §6.3; VDE 0100-534 — empfohlen | `PARAM_PV_kWp > 0 ? 1 : 0` | `= Kuppelstelle_PV (1:1)` |
| `ELE.STK.Zuleitung_AC_PV` | Elektrik | Starkstrom | AC-Kabel WR ↔ HAK (3×2,5–10 mm² Cu, längenabhängig) | VDE 0100-443: `I_Z ≥ I_N`; DC/AC trennen (VDE 0100-712 §4) | `PARAM_PV_kWp > 0 ? 1 : 0` | `= Kuppelstelle_PV (1:1)` |
| `ELE.SCH.Wechselrichter_PV` | Elektrik | Schaltschrank/Verteiler | Wechselrichter 3~ (8–25 kW, MPPT×2, DC-Eingang 1000/1500 V) | VDE-AR-N 4105 §6; VDE 0100-712 §4 (Klasse B) | `PARAM_PV_kWp > 0 ? 1 : 0` | `ceil(PARAM_PV_kWp / 25)` |
| `ELE.SCH.DC_Verteiler_PV` | Elektrik | Schaltschrank/Verteiler | DC-Verteiler / String-Schalter (DC-LS 1000/1500 V + Sicherung je String) | VDE 0100-712 §4: „One string per fuse" | `PARAM_PV_kWp > 0 ? 1 : 0` | `= Wechselrichter_PV (1:1)` |
| `ELE.SCH.DC_Sicherung_String` | Elektrik | Schaltschrank/Verteiler | DC-Sicherung je String (gG, ≥ I_sc(String), 1000/1500 V) | VDE 0100-443 §542; VDE 0100-712 §4 | `PARAM_PV_Strings` | `= DC_Verteiler_PV × 2` |
| `ELE.STK.Zuleitung_DC_PV` | Elektrik | Starkstrom | DC-Verkabelung WR → Dach (PV-Dauerkabel 4/6 mm², H1Z2Z2-J) | VDE 0100-443: `I_Z ≥ 1,25 · Imp(String)`; Dach-Temp. korrigieren | `PARAM_PV_Strings` | `= DC_Sicherung_String (1:1)` |
| `ELE.ERD.PE_Anschluss_WR` | Elektrik | Erdung/Potentialausgleich | PE-Anschluss WR-Gehäuse (≥ 4 mm² Cu → HPA-Schiene) | VDE 0100-600 §542 — **Pflicht** | `= Wechselrichter_PV` | `= Wechselrichter_PV (1:1)` |
| `ELE.ERD.Modulrahmen_Erdung` | Elektrik | Erdung/Potentialausgleich | Modulrahmen-Erdung (Schienen-Kontinuität oder dedizierter PE ≥ 4 mm²) | VDE 0100-600 §543; VDE 0100-712 §4 — **Pflicht** Klasse B | `PARAM_PV_kWp > 0 ? 1 : 0` | `= Wechselrichter_PV (pro WR-Gruppe)` |
| `ELE.SCH.UV_PV` | Elektrik | Schaltschrank/Verteiler | Unterverteilung „PV" (IP40/54, PV-Gruppenschalter C40/C50 + WR-Einzelschalter) | VDE 0100-443 (Stufung); DIN VDE 0660 | `PARAM_PV_kWp > 15 ? 1 : 0` | `ceil(PARAM_PV_kWp / 20)` |
| `ELE.STK.LS_Schalter_WB` | Elektrik | Starkstrom | LS-Schalter Wallbox (3P C-Char, HAK) — **C-Charakteristik Pflicht** für Ladeeinrichtungen | VDE 0127-1; VDE 0100-430 §542: `I_B ≤ I_N ≤ I_Z` | `PARAM_WB_kW > 0 ? 1 : 0` | `= LS_Schalter_WB (1:1)` |
| `ELE.STK.FI_TypB_WB` | Elektrik | Starkstrom | FI Typ B Wallbox (40–63 A / 30 mA, HAK) — **Pflicht** (DC-Fehlerströme des EV; interner RCD-Watchdog ersetzt ihn nicht) | VDE 0127-1; VDE 0100-534 | `PARAM_WB_kW > 0 ? 1 : 0` | `= LS_Schalter_WB (1:1)` |
| `ELE.STK.Zuleitung_AC_WB` | Elektrik | Starkstrom | Zuleitung HAK → Wallbox (H07V-U 5G, Cu; außen in Schutzrohr/LWK) — Querschnitt nach Ladeleistung & Länge | VDE 0100-520: `I_Z ≥ I_N`, Spannungsfall ≤ 3 % | `PARAM_WB_kW > 0 ? 1 : 0` | `= LS_Schalter_WB (1:1)` |
| `ELE.STK.UESS_Typ2_Zuleitung` | Elektrik | Starkstrom | Überspannungsschutz Typ 2 an Wallbox-Zuleitung (falls BZA) — bei Aufstellung im Freien prüfen | DIN EN 62305-4; VDE 0100-443 | `PARAM_BZA ? (PARAM_WB_kW > 0 ? 1 : 0) : 0` | `= UESS_Typ2_Zuleitung (1:1)` |
| `ELE.SCH.Wallbox` | Elektrik | Schaltschrank/Verteiler | Wallbox (IC-CPD, Typ 2; IP54/IP65) — einstellbar 6–32 A/Phase, inkl. RCD-Watchdog + Messung | VDE 0127-1; IEC 61851-1 | `PARAM_WB_kW > 0 ? 1 : 0` | `2` |
| `ELE.SCH.LAE_Ladekabel` | Elektrik | Schaltschrank/Verteiler | Ladeanschlusseinheit (Typ 2-Stecker, Mode 3; integriertes Ladekabel ~5 m) | DIN VDE 0127-3 / IEC 62196-2; IEC 61851-23 | `= Wallbox` | `= Wallbox (1:1)` |
| `ELE.ERD.PE_Anschluss_WB` | Elektrik | Erdung/Potentialausgleich | PE-Anschluss Wallbox (4–10 mm² Cu → HPA-Schiene) — **Pflicht** bei Schutzklasse I; Klasse II: entfällt, FI Typ B bleibt Pflicht | VDE 0100-600 §542 — **Pflicht** | `PARAM_WB_kW > 0 ? 1 : 0` | `= Wallbox (1:1)` |
| `ELE.ERD.Fundamenterdung` | Elektrik | Erdung/Potentialausgleich | Fundamenterdung prüfen/messen (Bestand) — < 100 Ω, bei BZA < 10 Ω; **vor Inbetriebnahme messen** | VDE 0100-534; DIN EN 62305 | `PARAM_WB_kW > 0 ? 1 : 0` | `= Fundamenterdung (1:1)` |
| `KOM.NET.LAN_Wallbox` | Kommunikation | Netzwerk | LAN-Kabel Wallbox ↔ Router (Cat 6, ≤ 100 m) oder WLAN-Modul — getrennt vom Starkstrom verlegen (> 30 cm) | IEC 61851-23; VDE 0100-520 §7.6 (EMV-Trennung) | `PARAM_WB_Komm ? 1 : 0` | `= LAN_Wallbox (1:1)` |
| `KOM.GW.OCPP_Anbindung` | Kommunikation | Gateway/SmartHome | OCPP 1.6/2.0-Anbindung (Cloud, Lastmanagement) — nur bei Bedarf | IEC 61851-23 / OCPP | `PARAM_WB_Komm ? (PARAM_WB_Ueberschuss ? 1 : 0) : 0` | `= OCPP_Anbindung (1:1)` |
| `KOM.GW.SmartMeter_PV` | Kommunikation | Gateway/SmartHome | PV-Überschussladen: Wallbox liest Einspeisung am bidirektionalen Zähler (AEGIS M132, Bestand) | VDE-AR-N 4105; Herstellerangabe (ePRM-Gateway) | `PARAM_WB_Ueberschuss ? 1 : 0` | `= SmartMeter_PV (1:1)` |
| `ELE.SCH.Batterie_HeadUnit` | Elektrik | Schaltschrank/Verteiler | Batteriespeicher-Head-Unit (AC-coupled, LFP; je ~5 kWh) — **bis 4 parallel**, eigene WR-/DC-Teile pro Unit | IEC 62619 (Zellensicherheit); VDE-AR-N 4105 | `PARAM_BAT_kWh > 0 ? PARAM_BAT_Units : 0` | `4` |
| `ELE.SCH.Batterie_DC_Verteiler` | Elektrik | Schaltschrank/Verteiler | DC-Verteilung / String-Schalter (DC-LS 1000/1500 V + Sicherung je Head-Unit) | VDE 0100-712 §4: „One unit per fuse" | `PARAM_BAT_kWh > 0 ? 1 : 0` | `= Batterie_HeadUnit (je Unit einpolig)` |
| `ELE.STK.Zuleitung_DC_BAT` | Elektrik | Starkstrom | DC-Verkabelung WR → Head-Unit (PV-Dauerkabel 4/6 mm², H1Z2Z2-J) — je Head-Unit separat | VDE 0100-443: `I_Z ≥ 1,25 · PARAM_BAT_DC_A`; Dach-/Umgebungstemp. korrigieren | `PARAM_BAT_kWh > 0 ? PARAM_BAT_Units : 0` | `= Batterie_DC_Verteiler × PARAM_BAT_Units` |
| `ELE.STK.LS_Schalter_AC_BAT` | Elektrik | Starkstrom | LS-Schalter Speicher-AC (3P C16/C25, HAK oder UV „PV“) — Stufung unter Kuppelstelle | VDE 0100-443 §542: `I_B ≤ I_N ≤ I_Z`; `I_out = PARAM_BAT_AC_kW / (√3·400 V)` | `PARAM_BAT_kWh > 0 ? 1 : 0` | `= LS_Schalter_AC_BAT (1:1)` |
| `ELE.STK.Zuleitung_AC_BAT` | Elektrik | Starkstrom | AC-Kabel Speicher ↔ HAK/UV (3×2,5–6 mm² Cu) — längenabhängig | VDE 0100-443: `I_Z ≥ I_N`; DC/AC trennen (VDE 0100-712 §4) | `PARAM_BAT_kWh > 0 ? 1 : 0` | `= LS_Schalter_AC_BAT (1:1)` |
| `ELE.ERD.PE_Anschluss_BAT` | Elektrik | Erdung/Potentialausgleich | PE-Anschluss Speicher-Gehäuse (≥ 4 mm² Cu → HPA-Schiene) — **Pflicht** je Head-Unit | VDE 0100-600 §542 — **Pflicht** | `PARAM_BAT_kWh > 0 ? PARAM_BAT_Units : 0` | `= Batterie_HeadUnit (1:1)` |
| `ELE.SCH.UESS_DC_BAT` | Elektrik | Schaltschrank/Verteiler | DC-Überspannungsschutz (Typ 2, 1000/1500 V) an Speicher-DC — falls BZA / PV im Blitzschutzzone | DIN EN 62305-4; VDE 0100-712 §4 | `PARAM_BZA ? (PARAM_BAT_kWh > 0 ? 1 : 0) : 0` | `= UESS_DC_BAT (1:1)` |
| `KOM.NET.LAN_Batterie` | Kommunikation | Netzwerk | LAN-Kabel Speicher ↔ Router (Cat 6) — für Monitoring, Smart Charging & PV-Überschussladen; getrennt vom Starkstrom verlegen (> 30 cm) | IEC 61851-23; VDE 0100-520 §7.6 (EMV-Trennung) | `PARAM_BAT_kWh > 0 ? 1 : 0` | `= LAN_Batterie (1:1)` |
| `KOM.GW.BMS_Gateway` | Kommunikation | Gateway/SmartHome | BMS-Gateway / Smart-Meter-Anbindung (ePRM an AEGIS M132, Bestand) — für PV-Überschussladen & Lastmanagement | VDE-AR-N 4105; Herstellerangabe (ePRM-Gateway) | `PARAM_BAT_kWh > 0 ? 1 : 0` | `= BMS_Gateway (1:1)` |

---

## 3. Formel-Erklärung & Abhängigkeiten

### Legende
- **Parameter:** `PARAM_*` (aus §1) — Eingabewerte des Haushalts
- **Komponenten:** `HYD.*` (aus §2) — Referenz auf die ID einer anderen Komponente
- `? :` = ternärer Operator (Bedingung ? Wert-wahr : Wert-falsch)
- `ceil()` = aufrunden (ganzzahlige Division nach oben)

### Detaillierte Formeln & Begründung

| ID | Min-Formel | Max-Formel | Begründung |
|----|-----------|-----------|------------|
| `HYD.KAL.Hausanschluss` | `1` | `1 + PARAM_Garten` | Ein Haus = 1 Anschluss; bei separatem Garten-Zähler: +1 |
| `HYD.KAL.Zaehler_Absperrung` | `1` | `1 + PARAM_Garten` | Pro Wasserzähler ein Absperrventil; max. Haus + Garten |
| `HYD.KAL.KW_Verteiler` | `1` | `PARAM_Etagen + PARAM_Keller` | Pro Etage ein Verteilerpunkt; bei großer Distanz (Keller ↔ OG) mehrere |
| `HYD.WAR.Boiler_TWW` | `1` | `1 + (PARAM_Etagen > 2 ? 1 : 0)` | Bei > 2 Etagen ggf. zweiter Boiler/Durchlauferhitzer für OG-Trennung |
| `HYD.WAR.HW_Verteiler` | `1` | `PARAM_Etagen + PARAM_Keller` | Analog KW_Verteiler; pro Etage ein HW-Verteilerpunkt |
| `HYD.WAR.Zirkulationspumpe` | `PARAM_HW_Schleife_m > 15 ? 1 : 0` | `PARAM_Etagen + PARAM_Keller` | Pflicht ab > 15 m HW-Leitung (DIN EN 12847); max. eine pro Etage |
| `HYD.HEI.Waermepumpe` | `1` | `2` | Max. 2: Zweitanlage oder WP + Solarunterstützung als separate Einheit |
| `HYD.HEI.Hydraulikstation` | `= Waermepumpe` | `= Waermepumpe` | Vormontierte Inneneinheit der WP (z. B. Vaillant VWZ MEH 97-7): enthält Umschaltventil, Heizkreispumpe, Sicherheitsgruppe (Sicherheitsventil + MAG), Heizstab, VR 940 Gateway. **Ersetzt** separate `Pumpe_Heizkreis`, `Sicherheitsventil_3bar`, `Membranausdehnungsgefaess` — diese Komponenten sind dann in der Hydraulikstation integriert und werden nicht zusätzlich gezählt |
| `HYD.HEI.Pumpe_WP_Seite` | `= Waermepumpe` | `= Waermepumpe` | 1:1 — pro Wärmepumpe genau eine Primärkreis-Pumpe |
| `HYD.HEI.Rueckflussverhinderer` | `= Waermepumpe` | `Waermepumpe + PARAM_Garten` | Pro WP-Kreislauf einer; Garten-RFV separat in `HYD.KAL.RFV_Gartenanschluss` |
| `HYD.HEI.Schmutzfanger_Filter` | `= Waermepumpe` | `Waermepumpe + PARAM_Garten` | Pro Kreislauf ein Schmutzfänger; max. WP + Garten + Technikraum |
| `HYD.HEI.Durchflusswaechter` | `= Waermepumpe` | `= Waermepumpe` | 1:1 — pro WP ein Durchflusswächter (Mindestumlauf-Schutz) |
| `HYD.HEI.Pufferspeicher` | `PARAM_Radiatoren ? 1 : (PARAM_FBH_Zonen > 6 ? 1 : 0)` | `Waermepumpe + PARAM_Radiatoren` | Pflicht bei Radiatoren (Systemtrennung) oder > 6 FBH-Zonen; max. pro WP + Radiatoren-Kreis |
| `HYD.HEI.Plattenwaermetauscher` | `= Pufferspeicher` | `= Pufferspeicher` | 1:1 — Plattenwärmetauscher nur bei Systemtrennung (Puffer vorhanden) |
| `HYD.HEI.Sicherheitsventil_3bar` | `(Waermepumpe - Hydraulikstation) + (PARAM_Radiatoren ? 1 : 0) + (Pufferspeicher > 0 ? 1 : 0)` | `Waermepumpe + PARAM_Radiatoren + (Pufferspeicher > 0 ? 1 : 0)` | Pro Heizkreis eine Sicherheitsgruppe; Puffer = eigener Kreis. **Hinweis:** Bei Hydraulikstation (VWZ MEH) ist das Sicherheitsventil bereits integriert → nicht zusätzlich zählen |
| `HYD.HEI.Membranausdehnungsgefaess` | `(Waermepumpe - Hydraulikstation) + (PARAM_Radiatoren ? 1 : 0) + (Pufferspeicher > 0 ? 1 : 0)` | `= Sicherheitsventil_3bar` | 1:1 mit Sicherheitsventil — pro Sicherheitsgruppe ein MAG. **Hinweis:** Bei Hydraulikstation (VWZ MEH) ist das MAG (10 L) bereits integriert → nicht zusätzlich zählen |
| `HYD.HEI.Entluftungsventil_auto` | `(Waermepumpe - Hydraulikstation) + (PARAM_Radiatoren ? 1 : 0) + ceil(PARAM_FBH_Zonen / 4)` | `Sicherheitsventil_3bar + ceil(PARAM_FBH_Zonen / 4)` | Pro Sicherheitsgruppe einer; zusätzlich pro ~4 FBH-Schleifen (höchster Punkt je Verteiler) |
| `HYD.HEI.Pumpe_Heizkreis` | `(Waermepumpe - Hydraulikstation) + (PARAM_Radiatoren ? 1 : 0)` | `Waermepumpe + PARAM_Radiatoren` | Pro Heizkreis eine Sekundärpumpe; max. FBH-Kreis + Radiatoren-Kreis. **Hinweis:** Bei Hydraulikstation (VWZ MEH) ist die Heizkreispumpe bereits integriert → nicht zusätzlich zählen |
| `HYD.HEI.Absperrventil_Vorlauf` | `2 × Pumpe_Heizkreis` | `2 × (Waermepumpe + PARAM_Radiatoren)` | Pro Heizkreis: 1 VL-Absperrung an WP/Puffer + 1 am Verteiler |
| `HYD.HEI.Absperrventil_Ruecklauf` | `2 × Pumpe_Heizkreis` | `2 × (Waermepumpe + PARAM_Radiatoren)` | Analog Vorlauf für Rücklaufseite |
| `HYD.HEI.FBH_Verteiler` | `1` | `PARAM_Etagen + PARAM_Keller` | Pro Etage ein FBH-Verteiler (z. B. EG + OG); Keller nur bei beheiztem Kellergeschoss |
| `HYD.HEI.FBH_Schleife` | `PARAM_FBH_Zonen` | `PARAM_FBH_Zonen × 2` | Min = geplante Zonen; Max = doppelte Anzahl (z. B. bei Umrüstung/Erweiterung) |
| `HYD.WAR.Mischbatterie` | `PARAM_Baeder + PARAM_Kuechen` | `(PARAM_Baeder + PARAM_Kuechen) × (PARAM_Etagen + PARAM_Keller)` | Min = 1 pro Bad/Küche; Max = wenn jede Etage eigene Bäder hat |
| `HYD.KAL.Verbraucher_nur_KW` | `PARAM_Kuechen + PARAM_Keller` | `(PARAM_Baeder + PARAM_Kuechen) × 2 + PARAM_Garten` | Min: GSP (Küche) + WM (Keller); Max: pro Bad/Küche max. 2 Geräte + Garten |
| `HYD.KAL.RFV_Gartenanschluss` | `PARAM_Garten` | `PARAM_Garten × 3` | Pflicht bei Gartenanschluss; max. 2–3 (Garten, Pool, Brunnen) |
| `HYD.HEI.Zuleitung_Fuellwasser` | `= Waermepumpe` | `Waermepumpe + PARAM_Radiatoren` | Pro WP ein Füllwasser-Anschluss; max. +1 bei Solar/Radiatoren-Kreis |
| `ELE.STK.LS_Schalter_WP` | `= Waermepumpe` | `= LS_Schalter_WP (1:1)` | Pro WP ein Endstromkreis im HAK; B-Charakteristik für Inverter-Kompressor (weicher Anlauf) |
| `ELE.STK.FI_Schutzschalter` | `= Waermepumpe` | `= LS_Schalter_WP (1:1)` | FI nicht zwingend bei reinem Drehstrom, aber empfohlen (Keller = feucht); Typ A reicht (kein DC) |
| `ELE.STK.Zuleitung_Starkstrom` | `= Waermepumpe` | `= LS_Schalter_WP (1:1)` | Pro WP eine Zuleitung HAK → WP; Querschnitt nach `I_Z ≥ I_N` (VDE 0100-520) |
| `ELE.SCH.Trennschalter` | `= Waermepumpe` | `= LS_Schalter_WP (1:1)` | Sichtbare Trennstelle am Betriebsmittel — **Pflicht** bei 3~/400 V (VDE-AR-E 2105-100 §7.4) |
| `ELE.SCH.Klemmenleiste` | `= Waermepumpe` | `= LS_Schalter_WP (1:1)` | Pro WP eine E-Box mit Klemmenleiste für PE + Kommunikation |
| `ELE.ERD.PE_Anschluss` | `= Waermepumpe` | `= LS_Schalter_WP (1:1)` | Pro WP ein PE-Anschluss an HPA-Schiene — **Pflicht** (VDE 0100-600 §542) |
| `ELE.ERD.HPA_Anschluss` | `1` | `PARAM_Etagen + PARAM_Keller` | HPA-Schiene (Bestand); alle metallenen Installationen im Keller anschließen — **Pflicht** bei WP im Keller |
| `ELE.STK.Kuppelstelle_PV` | `PARAM_PV_kWp > 0 ? 1 : 0` | `= Kuppelstelle_PV (1:1)` | Pro PV-Anlage eine Kuppelstelle im HAK; LS nach `I_out(WR) = P/(√3·400 V)` (VDE-AR-N 4105 §6.3) |
| `ELE.STK.FI_TypB_PV` | `PARAM_PV_kWp > 0 ? 1 : 0` | `= Kuppelstelle_PV (1:1)` | FI Typ B für PV-DC-Fehlerströme; empfohlen durch Netzbetreiber (VDE 0100-534) |
| `ELE.STK.Zuleitung_AC_PV` | `PARAM_PV_kWp > 0 ? 1 : 0` | `= Kuppelstelle_PV (1:1)` | Pro WR eine AC-Zuleitung; Querschnitt längenabhängig (VDE 0100-443) |
| `ELE.SCH.Wechselrichter_PV` | `PARAM_PV_kWp > 0 ? 1 : 0` | `ceil(PARAM_PV_kWp / 25)` | Min: 1 WR; Max: bei >20 kWp ggf. 2. WR (z. B. 15+10 kW) |
| `ELE.SCH.DC_Verteiler_PV` | `PARAM_PV_kWp > 0 ? 1 : 0` | `= Wechselrichter_PV (1:1)` | Pro WR ein DC-Verteiler mit String-Schaltern |
| `ELE.SCH.DC_Sicherung_String` | `PARAM_PV_Strings` | `= DC_Verteiler_PV × 2` | Min: 1 je String; Max: bei Parallelisierung auf MPPT bis zu 2× Strings pro Sicherungsgruppe |
| `ELE.STK.Zuleitung_DC_PV` | `PARAM_PV_Strings` | `= DC_Sicherung_String (1:1)` | Pro String ein PV-Dauerkabel; Querschnitt nach `I_Z ≥ 1,25·Imp` + Dach-Temp. |
| `ELE.ERD.PE_Anschluss_WR` | `= Wechselrichter_PV` | `= Wechselrichter_PV (1:1)` | Pro WR ein PE-Anschluss an HPA — **Pflicht** (VDE 0100-600 §542) |
| `ELE.ERD.Modulrahmen_Erdung` | `PARAM_PV_kWp > 0 ? 1 : 0` | `= Wechselrichter_PV (pro WR-Gruppe)` | Pro Dachfläche/WR-Gruppe eine Rahmen-Erdung; Schienen-Kontinuität prüfen (VDE 0100-712) |
| `ELE.SCH.UV_PV` | `PARAM_PV_kWp > 15 ? 1 : 0` | `ceil(PARAM_PV_kWp / 20)` | UV „PV" ab ~15 kWp (HAK-Plätze knapp); bei 20+ kWp Pflicht |
| `ELE.STK.LS_Schalter_WB` | `PARAM_WB_kW > 0 ? 1 : 0` | `= LS_Schalter_WB (1:1)` | Pro Wallbox ein Endstromkreis im HAK; **C-Charakteristik Pflicht** (Wechselrichter im EV → hohe Einschaltströme). Dimensionierung: 3,7/11 kW → C20/C25; 18 kW → C32; 22 kW → C40/C50 (VDE 0127-1: `I_B ≤ I_N`) |
| `ELE.STK.FI_TypB_WB` | `PARAM_WB_kW > 0 ? 1 : 0` | `= LS_Schalter_WB (1:1)` | **Pflicht** für IC-CPD: FI Typ B gegen AC-/DC-Berührungsströme (Gleichrichter im EV). Der interne RCD-Watchdog der Wallbox schützt nur das Ladekabel und ersetzt den Gebäudeschutz nicht (VDE 0127-1) |
| `ELE.STK.Zuleitung_AC_WB` | `PARAM_WB_kW > 0 ? 1 : 0` | `= LS_Schalter_WB (1:1)` | Außenverlegung: H07V-U in Schutzrohr/LWK. Querschnitt nach Ladeleistung & `PARAM_WB_Leitung_m`: ≤16 A → 5G×6 mm²; 25 A → 5G×10 mm²; 32 A → 5G×16 mm². Bei >25 m und ≥3×16 A: Spannungsfall ≤ 3 % zwingend prüfen (VDE 0100-520) |
| `ELE.STK.UESS_Typ2_Zuleitung` | `PARAM_BZA ? (PARAM_WB_kW > 0 ? 1 : 0) : 0` | `= UESS_Typ2_Zuleitung (1:1)` | Überspannungsschutz Typ 2 nur bei vorhandener BZA und Wallbox im Freifeld (DIN EN 62305-4); ohne BZA: Herstellerangaben prüfen |
| `ELE.SCH.Wallbox` | `PARAM_WB_kW > 0 ? 1 : 0` | `2` | Min: 1 Gerät; Max: 2 (z. B. Garage + Außenwand). Schutzart nach Aufstellort: IP54 (Garage) / IP65 + IK08 (Freifeld); Montagehöhe 120–145 cm |
| `ELE.SCH.LAE_Ladekabel` | `= Wallbox` | `= Wallbox (1:1)` | 1 LAE pro Wallbox; Typ 2, Mode 3, integriertes Kabel ~5 m (IEC 62196-2). Vor Inbetriebnahme: Kontinuität + Isolationswiderstand prüfen (IEC 61851-23) |
| `ELE.ERD.PE_Anschluss_WB` | `PARAM_WB_kW > 0 ? 1 : 0` | `= Wallbox (1:1)` | Pro Wallbox ein PE-Anschluss an HPA-Schiene — **Pflicht** bei Klasse I (VDE 0100-600 §542). Bei Schutzklasse II entfällt der dedizierte PE, FI Typ B bleibt Pflicht |
| `ELE.ERD.Fundamenterdung` | `PARAM_WB_kW > 0 ? 1 : 0` | `= Fundamenterdung (1:1)` | Bestand prüfen/messen **vor Inbetriebnahme**: < 100 Ω (allg.), < 10 Ω bei BZA. Bei Aufstellung im Freien: Metallteile in Nähe (Tor, Rahmen) → HPA führen |
| `KOM.NET.LAN_Wallbox` | `PARAM_WB_Komm ? 1 : 0` | `= LAN_Wallbox (1:1)` | Ohne WLAN-Empfang am Aufstellort: festen LAN-Anschluss verwenden. Getrennt von H07V-U verlegen (> 30 cm Abstand, VDE 0100-520 §7.6) |
| `KOM.GW.OCPP_Anbindung` | `PARAM_WB_Komm ? (PARAM_WB_Ueberschuss ? 1 : 0) : 0` | `= OCPP_Anbindung (1:1)` | Nur bei Bedarf (Fleet, Abrechnung, Fernüberwachung); IEC 61851-23 / OCPP 1.6–2.0 |
| `KOM.GW.SmartMeter_PV` | `PARAM_WB_Ueberschuss ? 1 : 0` | `= SmartMeter_PV (1:1)` | Wallbox liest Bezugs-/Einspeisemessung des bidirektionalen Zählers (AEGIS M132, Bestand) über ePRM-Gateway/LAN — keine zusätzliche Messung nötig (VDE-AR-N 4105) |
| `ELE.SCH.Batterie_HeadUnit` | `PARAM_BAT_kWh > 0 ? PARAM_BAT_Units : 0` | `4` | AC-coupled LFP-Speicher; **bis 4 Head-Units parallel** (je ~5 kWh, eigener WR + DC-Seite). Schutzart nach Aufstellort: IP20–43 (innen) / IP54+IK08 (außen, UV-beständig). IEC 62619: Zellensicherheit + Temperaturüberwachung (BMS) |
| `ELE.SCH.Batterie_DC_Verteiler` | `PARAM_BAT_kWh > 0 ? 1 : 0` | `= Batterie_HeadUnit (je Unit einpolig)` | Pro Head-Unit eine DC-Leitung mit eigenem LS + Sicherung („One unit per fuse“, VDE 0100-712 §4); DC-Klasse nach WR: 1000 V (≤ ~15 kWp) / 1500 V (>~18 kWp) |
| `ELE.STK.Zuleitung_DC_BAT` | `PARAM_BAT_kWh > 0 ? PARAM_BAT_Units : 0` | `= Batterie_DC_Verteiler × PARAM_BAT_Units` | Pro Head-Unit ein PV-Dauerkabel (H1Z2Z2-J, 4/6 mm²); Querschnitt nach `I_Z ≥ 1,25 · PARAM_BAT_DC_A` + Umgebungstemp. (Garage ~30 °C, außen 40–50 °C → −10…20 %) |
| `ELE.STK.LS_Schalter_AC_BAT` | `PARAM_BAT_kWh > 0 ? 1 : 0` | `= LS_Schalter_AC_BAT (1:1)` | Pro Speicheranlage ein AC-Endstromkreis im HAK/UV; Stufung **unter** der PV-Kuppelstelle (VDE 0100-443 §542). Beispiele: 6,4 kW → C16; 8 kW → C20; 12,5 kW → C32 |
| `ELE.STK.Zuleitung_AC_BAT` | `PARAM_BAT_kWh > 0 ? 1 : 0` | `= LS_Schalter_AC_BAT (1:1)` | AC-Kabel Speicher ↔ HAK/UV; Querschnitt nach `I_Z ≥ I_N` (VDE 0100-443), DC/AC getrennt verlegen (VDE 0100-712 §4) |
| `ELE.ERD.PE_Anschluss_BAT` | `PARAM_BAT_kWh > 0 ? PARAM_BAT_Units : 0` | `= Batterie_HeadUnit (1:1)` | Pro Head-Unit ein PE-Anschluss an HPA-Schiene — **Pflicht** (VDE 0100-600 §542); bei Schutzklasse II-Gerät entfällt dedizierter PE, FI Typ B bleibt Pflicht |
| `ELE.SCH.UESS_DC_BAT` | `PARAM_BZA ? (PARAM_BAT_kWh > 0 ? 1 : 0) : 0` | `= UESS_DC_BAT (1:1)` | DC-Überspannungsschutz Typ 2 (1000/1500 V) nur bei BZA und Speicher im Freifeld (DIN EN 62305-4); ohne BZA: Herstellerangaben prüfen |
| `KOM.NET.LAN_Batterie` | `PARAM_BAT_kWh > 0 ? 1 : 0` | `= LAN_Batterie (1:1)` | Monitoring + Smart Charging; ohne WLAN-Empfang am Aufstellort: festen LAN-Anschluss verwenden. Getrennt von H07V-U / PV-Dauerkabeln verlegen (> 30 cm, VDE 0100-520 §7.6) |
| `KOM.GW.BMS_Gateway` | `PARAM_BAT_kWh > 0 ? 1 : 0` | `= BMS_Gateway (1:1)` | Speicher liest Bezugs-/Einspeisemessung des bidirektionalen Zählers (AEGIS M132, Bestand) über ePRM-Gateway/LAN — für PV-Überschussladen & Lastmanagement (VDE-AR-N 4105) |

---

## 4. Abgeleitete Größen (Dimensionierung)

Diese Werte werden aus Parameter + Komponenten berechnet und bestimmen die **Größe**
einer einzelnen Komponente (nicht deren Anzahl).

| ID | Name | Formel | Einheit | Beschreibung |
|----|------|--------|---------|-------------|
| `CALC_Boiler_Volumen` | Boiler-Volumen | `PARAM_Personen × 50 + PARAM_Baeder × 30` | l | Faustformel: ~50 l/Person + 30 l/Bad (DIN EN 13203) |
| `CALC_Puffer_Volumen` | Puffer-Volumen | `PARAM_Radiatoren ? PARAM_WP_KW × 15 : (HYD.HEI.Pufferspeicher > 0 ? PARAM_WP_KW × 7 : 0)` | l | Systemtrennung: ~15 l/kW; Direktanbindung mit Puffer: ~7 l/kW (DIN EN 12897) |
| `CALC_Heizkreis_Fuellmenge` | Heizkreis-Füllmenge (gesamt) | `HYD.HEI.FBH_Schleife × 15 + CALC_Puffer_Volumen` | l | ~15 l pro FBH-Schleife (Ø 8 m², PEX 16×2) + Pufferinhalt |
| `CALC_MAG_Volumen` | MAG-Nennvolumen | `ceil(CALC_Heizkreis_Fuellmenge × 0.1)` | l | ~10 % der Heizkreis-Füllmenge (DIN EN 12828) |
| `CALC_Vorlauf_Temp` | Vorlauftemperatur (Soll) | `PARAM_Radiatoren ? 50 : 35` | °C | FBH: 35–40 °C; Radiatoren: 50–60 °C (VDE-AR-E 2105-100) |
| `CALC_Min_Durchfluss` | Mindestumlauf WP (m³/h) | `PARAM_WP_KW × 0.25` | m³/h | Faustformel: ~2–3 m³/h bei 10 kW (Herstellerangabe maßgeblich) |

---

## 5. Abhängigkeitsgraph (vereinfacht)

```
PARAM_Personen, PARAM_Etagen, PARAM_Keller, PARAM_Baeder, PARAM_Kuechen,
PARAM_FBH_Zonen, PARAM_Radiatoren, PARAM_Garten, PARAM_WP_KW, PARAM_HW_Schleife_m
    │
    ├──→ HYD.KAL.Hausanschluss → HYD.KAL.Zaehler_Absperrung
    │         └──→ HYD.KAL.KW_Verteiler (× Etagen+Keller)
    │                 ├──→ HYD.KAL.Verbraucher_nur_KW (GSP, WM)
    │                 ├──→ HYD.KAL.RFV_Gartenanschluss (GARTEN)
    │                 └──→ HYD.WAR.Boiler_TWW (Größe: CALC_Boiler_Volumen)
    │                         └──→ HYD.WAR.HW_Verteiler (× Etagen+Keller)
    │                                 ├──→ HYD.WAR.Zirkulationspumpe (HW_Schleife_m > 15)
    │                                 └──→ HYD.WAR.Mischbatterie (Baeder + Kuechen)
    │
    ├──→ HYD.HEI.Waermepumpe ──┬──→ HYD.HEI.Pumpe_WP_Seite
    │                           ├──→ HYD.HEI.Rueckflussverhinderer
    │                           ├──→ HYD.HEI.Schmutzfanger_Filter
    │                           ├──→ HYD.HEI.Durchflusswaechter
    │                           ├──→ HYD.HEI.Zuleitung_Fuellwasser (KW-Anschluss)
    │                           └──→ HYD.HEI.Pufferspeicher (RADIO, FBH_Zonen)
    │                                   └──→ HYD.HEI.Plattenwaermetauscher (1:1)
    │
    ├──→ HYD.HEI.Sicherheitsventil_3bar (pro Heizkreis)
    │         ├──→ HYD.HEI.Membranausdehnungsgefaess (1:1, Größe: CALC_MAG_Volumen)
    │         └──→ HYD.HEI.Entluftungsventil_auto (+ pro 4 FBH-Schleifen)
    │
    ├──→ HYD.HEI.Pumpe_Heizkreis (pro Heizkreis)
    │         ├──→ HYD.HEI.Absperrventil_Vorlauf (2×)
    │         ├──→ HYD.HEI.Absperrventil_Ruecklauf (2×)
    │         └──→ HYD.HEI.FBH_Verteiler (pro Etage)
    │                 └──→ HYD.HEI.FBH_Schleife (PARAM_FBH_Zonen)
    │
    └──→ CALC_* (abgeleitete Größen: Boiler_Volumen, Puffer_Volumen,
                 Heizkreis_Fuellmenge, MAG_Volumen, Vorlauf_Temp, Min_Durchfluss)

PARAM_WB_kW, PARAM_WB_Aussen, PARAM_BZA, PARAM_WB_Leitung_m
    │
    ├──→ ELE.STK.LS_Schalter_WB ──┬──→ ELE.STK.FI_TypB_WB (1:1, Pflicht)
    │                             ├──→ ELE.STK.Zuleitung_AC_WB (H07V-U, außen)
    │                             └──→ ELE.STK.UESS_Typ2_Zuleitung (nur bei BZA)
    │
    ├──→ ELE.SCH.Wallbox ──┬──→ ELE.SCH.LAE_Ladekabel (1:1, Typ 2)
    │                      └──→ ELE.ERD.PE_Anschluss_WB (Klasse I, → HPA)
    │
    ├──→ ELE.ERD.Fundamenterdung (Bestand, messen: < 100 Ω / BZA < 10 Ω)
    │
    └──→ PARAM_WB_Komm / PARAM_WB_Ueberschuss
              ├──→ KOM.NET.LAN_Wallbox (getrennt vom Starkstrom)
              ├──→ KOM.GW.OCPP_Anbindung (optional)
              └──→ KOM.GW.SmartMeter_PV (nur mit PARAM_PV_kWp > 0)

PARAM_BAT_kWh, PARAM_BAT_Units (1–4), PARAM_BAT_DC_A, PARAM_BAT_AC_kW
    │
    ├──→ ELE.SCH.Batterie_HeadUnit (× PARAM_BAT_Units, AC-coupled LFP)
    │         ├──→ ELE.SCH.Batterie_DC_Verteiler (DC-LS + Sicherung je Unit)
    │         ├──→ ELE.STK.Zuleitung_DC_BAT (PV-Dauerkabel je Unit)
    │         ├──→ ELE.ERD.PE_Anschluss_BAT (je Unit, → HPA)
    │         └──→ ELE.SCH.UESS_DC_BAT (nur bei BZA)
    │
    ├──→ ELE.STK.LS_Schalter_AC_BAT (Stufung unter PV-Kuppelstelle)
    │         └──→ ELE.STK.Zuleitung_AC_BAT (AC-Kabel, DC/AC getrennt)
    │
    └──→ KOM.NET.LAN_Batterie (Monitoring, getrennt vom Starkstrom)
              └──→ KOM.GW.BMS_Gateway (PV-Überschussladen, ePRM an AEGIS M132)
```

---

## 6. Geplante Erweiterungen (nicht implementiert)

| Klasse | Abkürzung | Beispiel-Komponenten | ID-Beispiele |
|--------|-----------|---------------------|--------------|
| **Elektrik** | `ELE` | LS-Schalter, FI (Typ A/B), Trennschalter, HPA-Anschluss, WR, DC-Verteiler, UV | `ELE.STK.LS_Schalter_WP`, `ELE.SCH.Wechselrichter_PV` | *(implementiert — siehe §2)*
| **Kommunikation** | `KOM` | Modbus-Kabel, M-Bus, SmartHome-Gateway, WLAN-Modul, OCPP | `KOM.BUS.Modbus_Kabel`, `KOM.GW.Vaillant_vocu` |

> **Hinweis:** Die Klasse `ELE` (Elektrik) ist implementiert — siehe §2, Unterklassifizierungen
> `STK` (Starkstrom), `SCH` (Schaltschrank/Verteiler) und `ERD` (Erdung/Potentialausgleich).
> Komponenten werden über den Namenszusatz getrennt: `_WP` (Wärmepumpe), `_PV` (Photovoltaik),
> `_WB` (Wallbox) und `_BAT` (Batteriespeicher).
> Die Klasse `KOM` ist **teilweise** implementiert: Wallbox- und Speicher-Kommunikation
> (`LAN_Wallbox`, `OCPP_Anbindung`, `SmartMeter_PV`, `LAN_Batterie`, `BMS_Gateway`) ist vorhanden;
> WP-seitige Kommunikation (Modbus, vocu) bleibt geplant.

| ID | Unterklassifizierung |
|----|---------------------|
| `STK` | Starkstrom (LS, FI, Leitung, HPA) |
| `SCH` | Schaltschrank / Verteiler (Trennschalter, Sicherungen) |
| `Erd` | Erdung / Potentialausgleich (HPA, PE-Leiter) |

| ID | Unterklassifizierung |
|----|---------------------|
| `STK` | Starkstrom (LS, FI, Leitung, HPA) |
| `SCH` | Schaltschrank / Verteiler (Trennschalter, Sicherungen) |
| `Erd` | Erdung / Potentialausgleich (HPA, PE-Leiter) |

### Unterklassifizierungen (Kommunikation)

| ID | Unterklassifizierung |
|----|---------------------|
| `NET` | Netzwerk (LAN/WLAN-Kabel, -Modul) — *implementiert: `KOM.NET.LAN_Wallbox`* |
| `GW`  | Gateway / SmartHome (vocu, OCPP-Cloud, ePRM-Smart-Meter) — *teilweise implementiert: `KOM.GW.OCPP_Anbindung`, `KOM.GW.SmartMeter_PV`* |
| `BUS` | Feldbus (Modbus RTU/TCP, M-Bus) — *geplant* |

### Dimensionierungstabelle Wallbox-Stromkreis (aus `STROMLAUFPLAN_WALLBOX.md`)

| Ladeleistung (`PARAM_WB_kW`) | `I_B` / Phase | LS 3P (C-Char.) | FI Typ B (Pflicht) | Zuleitung H07V-U Cu (`I_Z ≥ I_N`) | PE (min.) |
|---|---|---|---|---|---|
| **3,7 kW** (1×16 A) | 16 A | C20 / C25¹ | 40 A / 30 mA Typ B | 5G × 6 mm² (`I_Z ≈ 27–34 A`) | 4 mm² |
| **11 kW** (3×16 A) | 16 A/Ph. | C20 / C25¹ | 40 A / 30 mA Typ B | 5G × 6 mm² (`I_Z ≈ 27–34 A`) | 4 mm² |
| **18 kW** (3×25 A) | 25 A/Ph. | C32 | 40 A / 30 mA Typ B | 5G × 10 mm² (`I_Z ≈ 48–62 A`) | 10 mm² |
| **22 kW** (3×32 A) | 32 A/Ph. | C40² / C50² | **63 A** / 30 mA Typ B | 5G × 16 mm² (`I_Z ≈ 72–93 A`) | 16 mm² |

¹ **C-Charakteristik:** Auslösefaktor ~5–10× → bei C20: max. einstellbarer Ladestrom 13 A; bei C25: max. 16 A.
**Immer die Wallbox auf ≤ LS-Nennstrom einrichten** (VDE 0127-1).
² Bei 3×32 A: `P = √3 · 400 V · 32 A ≈ 22,2 kW`; LS C50 wenn Restkapazität des HAK es hergibt.

> **Offene Punkte (Bestand, s. `HAUSANSCHLUSSKASTEN_INVENTAR.md`):** Nennstrom des HAK-Hauptschalters (R1)
> ablesen → bestimmt maximale Ladeleistung; Restkapazität nach Abzug der Endstromkreise R2/R3 prüfen.
> Faustformel: `I_verfügbar = I_Haupt − Σ I_B(Endstromkreise)` — der Wallbox-LS darf die Restkapazität
> nicht dauerhaft übersteigen.
