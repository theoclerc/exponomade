import 'package:flutter/material.dart';
import 'arriveZone.dart';

class arriveZoneInfoPopup extends StatelessWidget {
  final arriveZone zone;

  arriveZoneInfoPopup({required this.zone});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(zone.name),
      content: ListView(
        children: <Widget>[
          ListTile(
            title: Text('From: ${zone.from.toString()}'),
          ),
          ListTile(
            title: Text('To: ${zone.to.toString()}'),
          ),
        ],
      ),
      actions: <Widget>[
        TextButton(
          child: Text('Close'),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ],
    );
  }
}
