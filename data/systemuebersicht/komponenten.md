# Komponenten-Katalog

**Anlage:** Vaillant aroTHERM pro VWL 115/7.1 A (11,5 kW)
**Quelle:** `data/normen/waermepumpe-normen-uebersicht.md`, Kapitel 5

> **Klassifizierung:** `Hydraulisch` (aktuell) · `Elektrik`, `Kommunikation` (geplant)
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
| `ELE` | Elektrik *(geplant)* |
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

---

## 2. Hydraulische Komponenten

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
```

---

## 6. Geplante Erweiterungen (nicht implementiert)

| Klasse | Abkürzung | Beispiel-Komponenten | ID-Beispiele |
|--------|-----------|---------------------|--------------|
| **Elektrik** | `ELE` | LS-Schalter, FI-Schutzschalter, Trennschalter, HPA-Anschluss | `ELE.STK.Leitungsschutzschalter`, `ELE.SCH.FI_Schaltgeraet_TypA` |
| **Kommunikation** | `KOM` | Modbus-Kabel, M-Bus, SmartHome-Gateway, WLAN-Modul | `KOM.BUS.Modbus_Kabel`, `KOM.GW.Vaillant_vocu` |

### Geplante Unterklassifizierungen (Elektrik)

| ID | Unterklassifizierung |
|----|---------------------|
| `STK` | Starkstrom (LS, FI, Leitung, HPA) |
| `SCH` | Schaltschrank / Verteiler (Trennschalter, Sicherungen) |
| `Erd` | Erdung / Potentialausgleich (HPA, PE-Leiter) |

### Geplante Unterklassifizierungen (Kommunikation)

| ID | Unterklassifizierung |
|----|---------------------|
| `BUS` | Feldbus (Modbus RTU/TCP, M-Bus) |
| `GW`  | Gateway / SmartHome (vocu, WLAN, Ethernet) |
