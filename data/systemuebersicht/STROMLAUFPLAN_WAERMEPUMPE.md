# Stromlaufplan Wärmepumpe — Netzbetreiber → VWL 115/7.1 A

<!-- Rolle: Elektromeister. Gültig für dreiphasigen Netzanschluss (400/230 V, TN-C-S).
     Basis: HAUSANSCHLUSSKASTEN_INVENTAR.md (Bestand) + VDE/DIN-Normen.
     Normen: DIN VDE 0100-430 (Überschutz), -520 (Leitungen), 0100-430/530 (LS/FI),
            VDE 0100-600 (Erdung/PA), VDE 0125 / DIN VDE 0105-100 (Prüfung),
            VDE-AR-E 2105-100 (WP-Anlage), GEG §72.
     WICHTIG: Separater Stromlaufplan — PV-Anlage wird NICHT berücksichtigt.
     AC = Wechselstrom (HAK → WP), keine DC-Komponenten in diesem Plan. -->

**Anlage:** Vaillant aroTHERM pro VWL 115/7.1 A
**Elektrik:** 3~/400 V/50 Hz, Inverter-Kompressor (R290), max. Leistungsaufnahme ~4,36 kW
**Standort WP:** Keller (Technikraum), Aufstellung auf Stellfüßen, IPX4

---

## Übersicht — Stromlauf (Textform)

```
┌───────────────┐   AC 400/230V     ┌───────────────────────────────────────┐
│ NETZBETREIBER │══════════════════►│         HAK (Bestand)                 │
│ Stadtwerke    │  3~ + PE          │ ┌───────────┐   ┌───────────────┐     │
│ (3×63 A?)     │                   │ │Zähler     │   │Hauptschalter  │     │
│               │                   │ │AEGIS M132 │   │(R1, 63 A C?)  │     │
└───────────────┘                   │ └─────┬─────┘   └───────┬───────┘     │
                                    │       │                 │             │
                                    │ ┌─────▼─────────────────▼─────────┐   │
                                    │ │  HAK-Hutschiene (Bestand)       │   │
                                    │ │  Reihen R2/R3: LS Endstromkreise│   │
                                    │ └─────────────┬───────────────────┘   │
                                    │               │                       │
                                    │ ┌─────────────▼───────────────────┐   │
                                    │ │  NEU: WP-Stromkreis (freie Pl.) │   │
                                    │ │  LS 3P B16 + FI Typ A 40A/30mA  │   │
                                    │ └─────────────┬───────────────────┘   │
                                    │               │                       │
                                    └───────────────┼───────────────────────┘
                                                    │ AC (Wechselstrom)
                                                    │ 3×6 mm² Cu + PE 4 mm² (NYM-J)
                                                    │ Länge: ~15–25 m (HAK Keller → WP)
                                                    ▼
                                    ┌───────────────────────────────┐
                                    │  ZWISCHENSCHRANK / E-BOX WP   │
                                    │  (im Keller, neben der WP)    │
                                    │ ┌─────────┐  ┌──────────────┐ │
                                    │ │Trennsch.│→ │  WP VWL      │ │
                                    │ │3P B16   │  │  115/7.1 A   │ │
                                    │ └─────────┘  │  (Inverter)  │ │
                                    │              └──────┬───────┘ │
                                    │                     │         │
                                    └─────────────────────┼─────────┘
                                                          │ PE (4 mm² Cu)
                                                          ▼
                                    ┌───────────────────────────────┐
                                    │  HPA / Erdung (R5 im HAK)     │
                                    │  WP-Gehäuse → PE-Klemme       │
                                    └───────────────────────────────┘
 
Kommunikation (optional, getrennt vom Starkstrom):
                                    ┌───────────────────────┐
                                    │  vocu / SmartHome     │◄── Modbus RTU (2×0,75 mm²)
                                    │  Gateway              │    oder M-Bus (2×0,75 mm²)
                                    └───────────┬───────────┘
                                                │ (getrennt verlegen, >30 cm Abstand)
                                    ┌───────────▼───────────┐
                                    │  WP VWL (Modbus/M-Bus)│
                                    └───────────────────────┘
```

---

## 1. Abschnitt A: Netzbetreiber → HAK (AC, Bestand)

| Komponente | Spezifikation | Norm / Bemerkung |
|---|---|---|
| **Netzanschluss** (netztseitig) | 3×63 A, 50 Hz, TN-C-S (Annahme — vor Ort verifizieren) | VDE 0100-704; Netzbetreiber (Stadtwerke) |
| **Zähler** AEGIS PLUS M132 (GLIEMATO) | 400 V, 5(60) A, bidirektional, ePRM | DIN EN 50470-1; Smart-Meter-Gateway (GEG §63) |
| **Hauptschalter / LS-Hauptabsicherung** (R1 im HAK) | 3P, vermutlich C63 A — **Nennstrom ablesen!** | VDE 0100-430; bestimmt verfügbare Restkapazität |
| **Übergabepunkt** (L2, Klappdeckel) | Klemmenblock Zähler → Hausinstallation — **Inhalt dokumentieren** | VDE 0100-704 §5.3 |

> ⚠️ **Offen:** Nennstrom des Hauptschalters (R1) ablesen. Bei 63 A: verfügbarer Reststrom nach Abzug der bestehenden Endstromkreise bestimmt, ob die WP direkt am HAK angeschlossen werden kann oder ein Unterverteiler nötig ist.

---

## 2. Abschnitt B: HAK → Wärmepumpe (AC, neu)

### 2.1 Stromkreis im HAK (freie Plätze R4: Nr. 7–12, 17–23)

| Komponente | Spezifikation | Norm / Bemerkung |
|---|---|---|
| **LS-Schalter WP** (im HAK) | 3P, **B16 A**, B-Charakteristik (Inverter-Kompressor → weicher Anlauf) | **VDE 0100-430 §542**: `I_B ≤ I_N ≤ I_Z`. `I_B = 4360 W / (√3 × 400 V) ≈ 6,3 A` → B16 ausreichend (Faktor ~2,5 für Inverter) |
| **FI-Schutzschalter WP** (im HAK, optional empfohlen) | 3P+N, **40 A / 30 mA**, Typ A (WP hat keine DC-Komponente) | **VDE 0100-430**: FI nicht zwingend bei reinem Drehstrom ohne Berührungsrisiko, aber **empfohlen** (Keller = feucht); Typ A reicht (kein DC) |
| **Hutschiene-Platz** | 2 Module (LS + FI) = ~4 HE; freie Plätze R4 vorhanden | — |

> **Hinweis:** Bei Inverter-Kompressoren (VWL 115/7.1 A) ist die B-Charakteristik ausreichend, da der Anlaufstrom durch den Frequenzumrichter begrenzt wird. Bei Direktanlauf-Kompressoren wäre C-Charakteristik erforderlich (VDE 0100-430 Anhang).

### 2.2 Leitung HAK → WP (Keller)

| Komponente | Spezifikation | Norm / Bemerkung |
|---|---|---|
| **Zuleitung WP** (Starkstrom) | **NYM-J 5×6 mm² Cu** (3L + N + PE), in Leitungsführungskanal oder direktverlegt | **VDE 0100-520**: `I_Z ≥ I_N = 16 A`; 5×6 mm² Cu → `I_Z ≈ 32–40 A` (je nach Verlegeart) — ausreichend mit Reserve |
| **Leitungslänge** | ~15–25 m (HAK Keller → WP-Standort im selben Raum oder angrenzend) | Spannungsfall: `ΔU < 2 %` (VDE 0100-520 §7.4) — bei 6 mm² und < 30 m: unkritisch |
| **PE-Leiter** | 4 mm² Cu (im NYM-J enthalten) | VDE 0100-534 §7.2: PE ≥ 4 mm² bei L > 16 mm²; hier 6 mm² → PE = 4 mm² ausreichend |
| **Verlegung** | Getrennt von Kommunikationskabeln (> 30 cm Abstand oder in getrennten Kanälen) | VDE 0100-520 §7.6; EMV-Trennung |

### 2.3 ZwischenSchrank / E-Box an der WP (optional, empfohlen)

| Komponente | Spezifikation | Norm / Bemerkung |
|---|---|---|
| **Trennschalter WP** (lokal) | 3P, B16 A, mit Sichtkontakt (Sichttrennung) — **Pflicht** | **VDE 0105-100 §4.2**: Sichtbare Trennstelle am Betriebsmittel; **VDE-AR-E 2105-100**: WP muss örtlich abschaltbar sein |
| **Sicherung / LS (lokal)** | 3P, B16 A (redundant mit HAK-LS) — optional | VDE 0100-430; vereinfacht Wartung (WP abschalten ohne HAK zu öffnen) |
| **Klemmenleiste** | Für PE-Anschluss WP-Gehäuse + ggf. Kommunikationskabel | VDE 0100-600 §542 (PA) |
| **Aufstellung** | IPX4, an Wand neben WP; Zugang für Wartung frei halten (≥ 0,8 m) | VDE-AR-E 2105-100; Herstellerangabe Vaillant |

> **Hinweis:** Der lokale Trennschalter ist bei 3~/400 V WP **Pflicht** (VDE-AR-E 2105-100 §7.4). Er ermöglicht die Sichttrennung ohne den HAK öffnen zu müssen — wichtig für SHK-Wartung.

### 2.4 Erdung / Potentialausgleich (HPA)

| Komponente | Spezifikation | Norm / Bemerkung |
|---|---|---|
| **PE-Anschluss WP-Gehäuse** | 4 mm² Cu, von E-Box/Trennschalter → HPA-Schiene (R5 im HAK) | **VDE 0100-600 §542**: Hauptpotentialausgleich — **Pflicht** |
| **HPA-Schiene (Bestand R5)** | Vorhanden im HAK; WP-PE hier anschließen | VDE 0100-600 §542/§543 |
| **Fundamenterdung** | Widerstand < 100 Ω (bzw. < 10 Ω bei Blitzschutz) — **vor Inbetriebnahme messen** | VDE 0100-534; DIN EN 62305 (Blitzschutz) |
| **Metallinstallationen** (Rohre, Rahmen) | Alle leitfähigen Teile im Keller → HPA-Schiene (PE ≥ 4 mm² Cu) | VDE 0100-600 §543; **Pflicht** bei WP im Keller |

> ⚠️ **Wichtig:** Die WP (R290, 136 kg) steht im Keller. Alle metallenen Heizungsrohre (Cu/Edelstahl), der Pufferspeicher-Rahmen und ggf. die FBH-Verteiler-Traverse müssen über den HPA mit dem PE verbunden sein (VDE 0100-600).

### 2.4 Hydraulikstation VWZ MEH 97-7 (vormontierte Inneneinheit)

Die aroTHERM pro wird mit vormontierter Hydraulikstation geliefert. Elektrisch ist die VWZ MEH über denselben Stromkreis wie die WP versorgt (kein separater LS nötig). Die Hydraulikstation enthält:

| Komponente | Spezifikation | Norm / Bemerkung |
|---|---|---|
| **Heizkreispumpe** (vormontiert) | Zirkulationspumpe im Primärkreis; EEI ≤ 0,23 | DIN EN ISO 5149 |
| **Umschaltventil** (Heizung ↔ WW) | Regelt den Wechsel zwischen Heiz- und Warmwasserbetrieb | Herstellerangabe |
| **Sicherheitsgruppe** (SV + MAG) | Sicherheitsventil 3 bar + Membranausdehnungsgefäß (10 L) | DIN EN 12828 |
| **Heizstab** (Zusatzheizung) | Bis zu 8,5 kW; für Spitzenlast / Frostschutz | VDE-AR-E 2105-100 |
| **VR 940 Gateway + HMI** | Internet-Gateway (Ethernet) + Bedien-Display; Modbus/M-Bus zur WP | — |
| **Anschlüsse** | Heizung: 1"; Wärmequelle: G 1¼" | Herstellerangabe |
| **Abmessungen / Gewicht** | 777 × 440 × 384 mm; ca. 32 kg | — |

> **Hinweis:** Bei Verwendung der VWZ MEH entfallen die separaten Komponenten:
> Heizungspumpe WP-Seite, Rückflussverhinderer, Schmutzfänger, Durchflusswächter,
> Sicherheitsventil und Membranausdehnungsgefäß. Details: `hydraulischer-fluss.md`, Variante B.

---

## 3. Abschnitt C: Kommunikation (getrennt vom Starkstrom)

| Komponente | Spezifikation | Norm / Bemerkung |
|---|---|---|
| **Modbus RTU Kabel** (WP/Hydraulikstation ↔ vocu/Gateway) | 2×0,75 mm² Cu (A/B), geschirmt (Stiftschirm), max. 30 m | VDE 0834; Herstellerangabe Vaillant (Modbus RTU, 9600 Baud) |
| **M-Bus Kabel** (WP/Hydraulikstation ↔ vocu, alternativ) | 2×0,75 mm² Cu, ungeschirmt ausreichend (M-Bus ist robust) | EN 13757-2; M-Bus (M-Bus 4) |
| **VR 940 Gateway** (in VWZ MEH integriert) | Internet-Gateway + HMI-Display; Ethernet-Anschluss; Modbus/M-Bus-Kommunikation zur WP | **Hinweis:** Bei Verwendung der Hydraulikstation VWZ MEH ist das VR 940 bereits integriert — kein separates Gateway nötig |
| **vocu / SmartHome-Gateway** (optional, zusätzlich) | Vaillant vocu (oder vergleichbar); Ethernet + WLAN; M-Bus- und Modbus-Anschluss | — |
| **Verlegung** | Getrennt von NYM-J (> 30 cm Abstand); in separatem Kabelkanal oder mit Trennwand | VDE 0100-520 §7.6; EMV-Trennung |
| **Spannungsversorgung vocu** | 230 V/1~, LS B6–B10 A (eigener Stromkreis oder bestehender Steckdosenkreis) | VDE 0100-430; **nicht** im WP-Stromkreis (Störungsentkopplung) |

> **Hinweis:** Kommunikationskabel dürfen **nicht** mit dem Starkstrom in derselben Leitungsführung verlegt werden (VDE 0100-520 §7.6). Bei paralleler Verlegung: Mindestabstand 30 cm oder Trennwand (Metall) zwischen den Kanälen.

---

## 4. Dimensionierungstabelle — WP-Stromkreis (Zusammenfassung)

| Parameter | Wert | Quelle / Berechnung |
|---|---|---|
| WP-Nennleistung (elektrisch) | 4,36 kW (A7/W35, max.) | Datenblatt VWL 115/7.1 A |
| Bemessungsstrom `I_B` | 4360 / (√3 × 400) ≈ **6,3 A** | VDE 0100-520 §7.4 |
| LS-Schalter (HAK) | **3P B16 A** | VDE 0100-430: `I_B ≤ I_N`; B für Inverter |
| FI-Schutzschalter (HAK) | **3P+N 40 A / 30 mA Typ A** (empfohlen) | VDE 0100-430; Keller = feucht → FI empfohlen |
| Trennschalter (lokal an WP) | **3P B16 A**, mit Sichtkontakt | VDE-AR-E 2105-100 §7.4; **Pflicht** |
| Zuleitung (HAK → WP) | **NYM-J 5×6 mm² Cu** (~15–25 m) | VDE 0100-520: `I_Z ≥ I_N = 16 A` |
| PE-Leiter (WP-Gehäuse → HPA) | **4 mm² Cu** | VDE 0100-534 §7.2; VDE 0100-600 |
| Kommunikationskabel (Modbus/M-Bus) | **2×0,75 mm² Cu**, geschirmt (Modbus) / ungesch. (M-Bus) | VDE 0834; EN 13757-2 |
| Spannungsfall (Zuleitung) | < 2 % (bei 6 mm², < 30 m: unkritisch) | VDE 0100-520 §7.4 |

---

## 5. Prüfung & Dokumentation (vor Inbetriebnahme)

| Schritt | Norm / Anforderung |
|---|---|
| **Schutzleiterwiderstand** (PE-Strecke HAK → WP) | VDE 0125-1 / DIN VDE 0105-100: `R_PE × I_d ≤ U_a` (z. B. 30 mA FI: `R_PE < 167 Ω`) |
| **Isolationswiderstand** (L/N/PE → Erde) | VDE 0125-1: ≥ 1 MΩ (bei 400 V); Messung mit 500 V DC |
| **FI-Prüfung** (Testknopf + Messung) | VDE 0125-1: Auslösestrom ≤ 30 mA, Auslösezeit < 400 ms (Typ A) |
| **HPA-Prüfung** (Kontinuität WP-Gehäuse → HPA-Schiene) | VDE 0105-100: Widerstand < 0,2 Ω |
| **Erdungswiderstand messen** (Fundamenterdung) | VDE 0100-534: < 100 Ω (bzw. < 10 Ω bei Blitzschutz) |
| **Prüfprotokoll** (alle Messwerte dokumentieren) | VDE 0125-1; **Pflicht** — Abnahme durch Elektroinstallateur |
| **Inbetriebnahme-Protokoll WP** (Sollwerte, JAZ) | VDE-AR-E 2105-100; Herstellerangaben Vaillant |
| **Gebäudeenergiebuch** (GEG §72) | Digitale Erfassung: WP-Typ, Leistung, JAZ, Installationsdatum — **Pflicht seit 01.01.2026** |
| **Abnahmeprotokoll** (Elektro + SHK) | VDE 0105-100; beide Gewerke signieren |

---

## 6. Offene Punkte (vor Baubeginn klären)

- [ ] **Nennstrom des Hauptschalters (R1)** ablesen → bestimmt, ob WP direkt am HAK angeschlossen werden kann
- [ ] **Bestehende Endstromkreise (R2/R3)** inventarisieren → Restkapazität des HAK berechnen
- [ ] **Inhalt des Klappdeckels (L2)** dokumentieren → Übergabepunkt Zähler → Haus
- [ ] **Kennzeichnung des 2P-FI (L3)** ablesen: Nennstrom, FI-Typ, Prüfdatum
- [ ] **Kennzeichnung des 3P-FI (R3, Nr. 24)** ablesen: dito
- [ ] **Erdungswiderstand messen** (Fundamenterdung) — Voraussetzung für WP-Erdung
- [ ] **Leitungsweg HAK → WP** planen (Länge, Verlegeart) → Kabelquerschnitt final bestimmen
- [ ] **WP-Standort im Keller** festlegen → IPX4-Aufstellung, Zugang für Wartung (≥ 0,8 m), Lüftung (R290)
- [ ] **Kommunikationsweg** planen: vocu-Standort, Modbus/M-Bus-Kabellänge
- [ ] **Netzspannung & Phasenzuordnung** vor Ort verifizieren (400/230 V, 3~)

---

## 7. Normen-Referenzen (Zusammenfassung)

| Norm | Anwendung in diesem Stromlaufplan |
|---|---|
| **DIN VDE 0100-430** | Überspannungsschutz: LS-Schalter (B16), FI Typ A (40A/30mA) |
| **DIN VDE 0100-520** | Leitungen: NYM-J 5×6 mm², Querschnittswahl, Spannungsfall |
| **DIN VDE 0100-534** | Schutz durch FI: PE-Leiter ≥ 4 mm², Erdungswiderstand < 100 Ω |
| **DIN VDE 0100-600** | Erdung & Potentialausgleich: HPA-Schiene, WP-Gehäuse → PE |
| **DIN VDE 0125-1 / VDE 0105-100** | Elektrische Prüfung: Schutzleiterwiderstand, Isolationswiderstand, FI-Test |
| **VDE-AR-E 2105-100** | WP-Anlage: Trennschalter (Pflicht), Inbetriebnahme, JAZ-Messung |
| **VDE 0100-738** | Schutzart: IPX4 (Keller, feucht) — Aufstellung der WP |
| **GEG §72** | Gebäudeenergiebuch: digitale Erfassung der WP-Daten (Pflicht seit 01.01.2026) |
| **VDE 0834** | Kommunikationskabel: Modbus RTU (geschirmt), M-Bus |
| **EN 13757-2** | M-Bus: Kabel, Topologie (Bus), max. 10 m pro Segment |
