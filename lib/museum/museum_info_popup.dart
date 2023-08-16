import 'package:exponomade/models/musee_model.dart';
import 'package:exponomade/museum/museum.dart';
import 'package:flutter/material.dart';

class MuseumInfoPopup extends StatelessWidget {
  final Museum musee;

  const MuseumInfoPopup({super.key, required this.musee});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(musee.name),
      content: ListView.builder(
        itemCount: musee.objects.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(musee.objects[index]),
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
