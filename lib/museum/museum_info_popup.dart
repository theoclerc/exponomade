import 'package:exponomade/models/musee_model.dart';
import 'package:flutter/material.dart';

class MuseumInfoPopup extends StatelessWidget {
  final Musee musee;

  const MuseumInfoPopup({super.key, required this.musee});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(musee.nomMusee),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: musee.objets.map((objet) {
            return ListTile(
              title: Text(objet.nomObjet),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(objet.image),
                  Text(objet.descriptionObjet),
                  Text("De ${objet.chronologie}"),
                  Text("Raison de la migration: ${objet.raisons}"),
                  Text("Population: ${objet.population}"),
                ],
              ),
            );
          }).toList(),
        ),
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
