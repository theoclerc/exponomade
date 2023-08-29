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
              title: Text("Nom: ${objet.nomObjet}"),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Image.network(
                    objet.image,
                    errorBuilder: (BuildContext context, Object exception,
                        StackTrace? stackTrace) {
                      // Affiche un message d'erreur ou une image de remplacement en cas d'erreur.
                      return const Text(
                          'Erreur lors du chargement de l\'image');
                    },
                    width: 300,
                  ),
                  Text("Description: ${objet.descriptionObjet}"),
                  Text(
                      "De ${objet.chronologie['from']} à ${objet.chronologie['to']}"),
                  Text("Raison de la migration: ${objet.raisons.join(", ")}"),
                  Text("Populations: ${objet.population}"),
                ],
              ),
            );
          }).toList(),
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
