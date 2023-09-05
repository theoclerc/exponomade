import 'package:flutter/material.dart';
import '../models/provenanceZone_model.dart';

class provenanceZoneInfoPopup extends StatelessWidget {
  final ProvenanceZone zone;

  const provenanceZoneInfoPopup({Key? key, required this.zone})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Center(
        child: Column(
          children: [
            Text('Zone de provenance',
                style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 10), // Un espace entre les deux textes
            Text(zone.provenanceNom,
                style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue)),
          ],
        ),
      ),
      content: SingleChildScrollView(
        child: ListBody(
          children: [
            Divider(color: Colors.black, height: 1), // Ligne supérieure
            Text('Raisons :',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            Divider(color: Colors.black, height: 1), // Ligne inférieure
            SizedBox(height: 10),
            ...zone.reasons
                .map((reason) => Padding(
                      padding: const EdgeInsets.only(
                          left: 20.0,
                          bottom:
                              8.0), // Un peu de padding pour aligner avec la puce
                      child: Row(
                        children: [
                          Text('• '),
                          Expanded(child: Text(reason)),
                        ],
                      ),
                    ))
                .toList(),
            Divider(color: Colors.black, height: 1), // Ligne supérieure
            Text('Description des raisons :',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            Divider(color: Colors.black, height: 1), // Ligne inférieure
            SizedBox(height: 10),
            ListTile(
              title: Text(zone.reasonsDescription, textAlign: TextAlign.center),
            ),
          ],
        ),
      ),
      actions: <Widget>[
        TextButton(
          style: TextButton.styleFrom(
            primary: Colors.white,
            backgroundColor: Colors.blue[400],
            onSurface: Colors.grey,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(20)),
            ),
          ),
          child: const Text('Fermer'),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ],
    );
  }
}
