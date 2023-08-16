import 'package:flutter/material.dart';
import 'provenanceZone.dart';

class provenanceZoneInfoPopup extends StatelessWidget {
  final ProvenanceZone zone;

  const provenanceZoneInfoPopup({Key? key, required this.zone}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(zone.provenanceNom),
      content: SingleChildScrollView(
        child: ListBody(
          children: [
            ...zone.reasons.map((reason) => ListTile(title: Text(reason))).toList(),
            ListTile(
              title: Text(zone.reasonsDescription),
            ),
          ],
        ),
      ),
      actions: <Widget>[
        TextButton(
          child: const Text('Close'),
          onPressed: () {
            Navigator.of(context).pop(); // Fermeture du dialogue
          },
        ),
      ],
    );
  }
}
