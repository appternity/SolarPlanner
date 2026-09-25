import 'package:flutter/material.dart';

/// Modal that shows the hard-coded yield efficiency table (Mertens,
/// Photovoltaik-Lehrbuch 5. Aufl., S. 58) as an image.
Future<void> showEfficiencyTableDialog(BuildContext context) {
  return showDialog(
    context: context,
    builder: (_) => Dialog(
      insetPadding: const EdgeInsets.all(16),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.sizeOf(context).width * 0.92,
          maxHeight: MediaQuery.sizeOf(context).height * 0.85,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 8, 0),
              child: Row(
                children: [
                  Expanded(
                    child: Text('Ertrag nach Ausrichtung & Neigung',
                        style: Theme.of(context).textTheme.titleMedium),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),
            const Padding(
              padding: EdgeInsets.fromLTRB(16, 4, 16, 0),
              child: Text(
                'Jahresertrag in % eines Süd-Dachs mit optimaler Neigung. '
                'Zeile = Abweichung von Süden (0°=S, 90°=O/W, 180°=N), '
                'Spalte = Neigung.',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ),
            Flexible(
              child: Image.asset(
                'assets/effizienz/pv-module_ausrichtung_vs_neigung.png',
                fit: BoxFit.contain,
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
