import 'package:flutter/material.dart';
import 'provenanceZone.dart';

class provenanceZoneInfoPopup extends StatelessWidget {
  final ProvenanceZone zone;

  const provenanceZoneInfoPopup({super.key, required this.zone});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(zone.provenanceNom),
      content: ListView.builder(
        itemCount: zone.reasons.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(zone.reasons[index]),
          );
        },
      ),
      actions: <Widget>[
        TextButton(
          child: const Text('Close'),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ],
    );
  }
}
