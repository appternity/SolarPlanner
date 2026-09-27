# Hausanschlusskasten — Bestandsaufnahme

<!-- Quelle: data/systemuebersicht/Hausanschlusskasten.jpg (Foto vom 2026-09-27)
     Rolle: Elektromeister — Bestandsaufnahme vor PV-Einplanung.
     Dieses Inventar ist die Basis für stromlaufplan.md (Stromlaufplan Netzbetreiber → Module). -->

## 1. Systemtyp & Netzanschluss

| Merkmal | Befund |
|---|---|
| Netzbetreiber / Messstellenbetreiber | **Stadtwerke** (Aufkleber „Stromverbrauch im Blick — mit Ihrem modernen Stromzähler") |
| Zählersystem | **GLIEMATO** (Smart-Meter-Gateway, ePRM-fähig) |
| Zählermodell | **AEGIS PLUS M132** (bidirektional, 400 V / 5(60) A — Typbezeichnung am Gerät) |
| Zählernummer (lesbar) | `12PA00 0618 3740` (Barcode: DE-DE52E74D) |
| Zählerstand auf Foto | 009001 kWh (Stand: Aufnahmezeitpunkt) |
| Zählerart | **Bidirektional** → Einspeisung ist bereits zählerseitig abgerechnet (Einspeisevergütung / Netzeinspeisung möglich) |
| Netzspannung | 400/230 V, TN-C-S (Standard DE) — **Annahme**, durch Elektriker vor Ort bestätigen |
| Hauptabsicherung (HAK) | **Nicht im Bild** — liegt netzseitig beim Netzbetreiber (typisch 3×63 A, 50 Hz). Für die PV-Planung: `maxFeedInKw` beim Netzbetreiber erfragen! |

## 2. Komponenten im HAK (von links nach rechts, oben nach unten)

### Linke Klappe
| # | Komponente | Typ / Kennzeichnung | Funktion |
|---|-----------|---------------------|----------|
| L1 | **Bidirektionaler Stromzähler** AEGIS PLUS M132 (GLIEMATO) | 400 V, 5(60) A, ePRM | Messung Bezug + Einspeisung; Kommunikation an Stadtwerke (Smart Meter) |
| L2 | **Klappdeckel / Abdeckung** unter dem Zähler (verschlossen) | — | Verdeckt: vermutlich Klemmenblock / Übergabepunkt (Übergabe Zähler → Hausinstallation). **Inhalt bei Öffnung dokumentieren!** |
| L3 | Untere Klappe: **2-poliger FI-Schutzschalter** (transparent, links) | 2P, vermutlich 40 A / 30 mA Typ A (Kennzeichnung nicht lesbar) | FI-Schutz für einen Endstromkreis (vermutlich Altbau-Kreis oder E-Box). **Prüfdatum & Nennstrom ablesen!** |
| L4 | Untere Klappe: **leere Hutschiene** (rechts neben FI) | —| Reserve für weitere Schalter |

### Rechte Klappe
| # | Komponente | Typ / Kennzeichnung | Funktion |
|---|-----------|---------------------|----------|
| R1 | **Hauptschalter / LS-Hauptabsicherung** (oben, 3-polig) | vermutlich 63 A C-Charakteristik (Kennzeichnung nicht lesbar) | Gesamtabschaltung Hausinstallation. **Nennstrom ablesen — bestimmt den verfügbaren Platz für PV-Einspeisung!** |
| R2 | **Reihe 1: 6× LS-Schalter** (Nummern 1–6) | 2P/3P, je 10–25 A (nicht lesbar) | Endstromkreise Hausinstallation (Beleuchtung, Steckdosen etc.) |
| R3 | **Reihe 2: 4× LS-Schalter** (Nummern 13–16) + **1× FI rechts (Nr. 24)** | LS: 10–32 A; FI: vermutlich 63 A / 30 mA | Weitere Endstromkreise + FI-Gruppe. **Nummernlücken (7–12, 17–23) = freie Plätze!** |
| R4 | **Freie Hutschiene-Plätze** (Nummern 7–12, 17–23) | — | **Reserve für PV-Komponenten** (Wechselrichter-Einspeiseschalter, FI Typ B für Wallbox etc.) |
| R5 | **PE-Klemmenleiste / Potentialausgleich** (schwarze Klemme, Mitte unten) | HPA-Schiene | Hauptpotentialausgleich: PE-Hauptleiter, Metallinstallationen. **PV-Wechselrichter + Modulrahmen müssen hier angeschlossen werden (VDE 0100-600)!** |
| R6 | **Erdung / Fundamenterdung-Anschluss** (unten) | — | Verbindung zur Gebäudeerdung. Widerstand < 100 Ω (bzw. < 10 Ω bei Blitzschutz) — **vor PV-Anschluss messen!** |

## 3. Befunde & offene Punkte (MUST vor PV-Anschluss klären)

- [ ] **Nennstrom des Hauptschalters (R1)** ablesen → bestimmt max. Einspeiseleistung
- [ ] **Nennstrom des Zähleranschlusses** (5(60) A = 41,5 kW dreiphasig — i.d.R. ausreichend für ≤ 25 kWp)
- [ ] **`maxFeedInKw` beim Netzbetreiber (Stadtwerke) erfragen** — vertraglich vereinbarte Einspeisung
- [ ] **Inhalt des Klappdeckels (L2)** dokumentieren — Übergabepunkt Zähler → Haus
- [ ] **Kennzeichnung des 2P-FI (L3)** ablesen: Nennstrom, FI-Typ (A/B), Prüfdatum
- [ ] **Kennzeichnung des 3P-FI (R3, Nr. 24)** ablesen: dito
- [ ] **Erdungswiderstand messen** (Fundamenterdung) — Voraussetzung für PV-Erdung
- [ ] **Freie Hutschiene-Plätze zählen** (R4) → PV-Komponenten einplanbar?
- [ ] **Netzspannung & Phasenzuordnung** vor Ort verifizieren (400/230 V, 3~)

## 4. Konsequenzen für die PV-Planung (→ stromlaufplan.md)

1. **Zähler ist bidirektional** → keine zusätzliche Einspeise-Messung nötig; PV speist direkt ein.
2. **HAK hat freie Plätze** → Wechselrichter-Einspeiseschalter (LS 3P) + ggf. FI Typ B für Wallbox passen hinein; **sonst Unterverteilung „PV" vorsehen**.
3. **HPA-Schiene vorhanden** → Wechselrichter-PE + Modulrahmen-Erdung (VDE 0100-600) direkt anschließbar.
4. **Erdung muss verifiziert sein** → Fundamenterdungswiderstand messen, ggf. Erdspieß nachrüsten (VDE 0100-534 / Blitzschutz).
5. **Gleichstromseite (Module → Wechselrichter)** ist im HAK **nicht** untergebracht — DC-Verkabelung verläuft vom Dach zur Wechselrichter-Standort (Garage/Wand), AC-Kabel dann in den HAK.
