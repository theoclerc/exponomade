import 'package:flutter/material.dart';
import 'arriveZone.dart';

class arriveZoneInfoPopup extends StatelessWidget {
  final arriveZone zone;

  const arriveZoneInfoPopup({Key? key, required this.zone}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(zone.name),
      content: SingleChildScrollView( // Ajouter un widget SingleChildScrollView
        child: Column(
          children: <Widget>[
            ListTile(
              title: Text('From: ${zone.from.toString()}'),
            ),
            ListTile(
              title: Text('To: ${zone.to.toString()}'),
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
