import 'package:flutter/material.dart';
import '../models/arriveZone_model.dart';

// This custom widget displays information about a final zone in a popup dialog.
class arriveZoneInfoPopup extends StatelessWidget {
  final arriveZone zone;

  const arriveZoneInfoPopup({Key? key, required this.zone}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      titlePadding: EdgeInsets.all(16.0),
      title: Column(
        children: [
          Container(
            padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 15.0),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.blueGrey[300]!, width: 2),
              borderRadius: BorderRadius.circular(12.0),
            ),
            child: Column(
              children: [
                // Title for the final zone.
                Text(
                  'Zone d\'arrivée :',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.blue[600],
                    fontSize: 16.0,
                  ),
                  textAlign: TextAlign.center,
                ),
                // Space between the two texts.
                SizedBox(height: 8.0),
                Text(
                  zone.name,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.blue[600],
                    fontSize: 18.0,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ],
      ),
      contentPadding: EdgeInsets.all(20.0),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Divider(
              color: Colors.blueGrey[300],
              thickness: 2.0,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12.0),
              // Subtitle for migration.
              child: Text(
                'Époque de l\'immigration :',
                style: TextStyle(
                  color: Colors.blueGrey[600],
                  fontSize: 16.0,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            Divider(
              color: Colors.blueGrey[300],
              thickness: 2.0,
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 6.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'De : ',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.blueGrey[800],
                    ),
                  ),
                  // Display zone "from" attribute.
                  Text(zone.from.toString()),
                ],
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'À : ',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.blueGrey[800],
                  ),
                ),
                // Display zone "to" attribute.
                Text(zone.to.toString()),
              ],
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
