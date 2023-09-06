import 'package:flutter/material.dart';
import '../models/provenanceZone_model.dart';

// This custom widget displays information about a provenance zone in a popup dialog.
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
            // Title for the provenance zone.
            Text('Zone de provenance', 
                style: TextStyle(fontWeight: FontWeight.bold)),
            // Space between the two texts.
            SizedBox(height: 10), 
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
            Divider(color: Colors.black, height: 1),
            // Subtitle for reasons.
            Text('Raisons :', 
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            // Horizontal divider line.
            Divider(color: Colors.black, height: 1), 
            // Vertical spacing.
            SizedBox(height: 10), 
            ...zone.reasons
                .map((reason) => Padding(
                      padding: const EdgeInsets.only(
                          left: 20.0,
                          // Left padding for aligning with the bullet.
                          bottom:
                              8.0), 
                      child: Row(
                        children: [
                          Text('• '),
                           // Display the reason.
                          Expanded(child: Text(reason)),
                        ],
                      ),
                    ))
                .toList(),
             // Horizontal divider line.
            Divider(color: Colors.black, height: 1),
             // Subtitle for reason descriptions.
            Text('Description des raisons :',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            // Horizontal divider line.
            Divider(color: Colors.black, height: 1),
             // Vertical spacing.
            SizedBox(height: 10),
            ListTile(
               // Display reason descriptions.
              title: Text(zone.reasonsDescription, textAlign: TextAlign.center),
            ),
          ],
        ),
      ),
      actions: <Widget>[
        TextButton(
          style: TextButton.styleFrom(
            foregroundColor: Colors.white, backgroundColor: Colors.blue[400], disabledForegroundColor: Colors.grey.withOpacity(0.38),
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(20)),
            ),
          ),
           // Button text for closing the popup.
          child: const Text('Fermer'),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ],
    );
  }
}
