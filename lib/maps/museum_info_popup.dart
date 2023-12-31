import 'package:exponomade/models/musee_model.dart';
import 'package:flutter/material.dart';

// This widget displays a popup dialog with information about a museum.
class MuseumInfoPopup extends StatelessWidget {
  final Musee musee;

  const MuseumInfoPopup({Key? key, required this.musee}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        constraints: BoxConstraints(maxWidth: 600),
        child: AlertDialog(
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
                    Text(
                      'Musée :',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.blue[600],
                        fontSize: 16.0,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 8.0),
                    // Display museum name.
                    Text(
                      musee.nomMusee,
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
              children: musee.objets.map((objet) {
                return Column(
                  children: <Widget>[
                    Divider(
                      color: Colors.blueGrey[300],
                      thickness: 2.0,
                    ),
                    // Displaying museum objects.
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12.0),
                      child: ListTile(
                        title: Text(
                          "Objet: ${objet.nomObjet}",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.blueGrey[600],
                            fontSize: 16.0,
                          ),
                        ),
                      ),
                    ),
                    Divider(
                      color: Colors.blueGrey[300],
                      thickness: 2.0,
                    ),
                    // Display object information.
                    ListTile(
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Display the object's image with error handling.
                          Image.network(
                            objet.image,
                            errorBuilder: (BuildContext context, Object exception, StackTrace? stackTrace) {
                              return Text(
                                'Erreur lors du chargement de l\'image',
                                style: TextStyle(color: Colors.red, fontStyle: FontStyle.italic),
                              );
                            },
                            width: 300,
                          ),
                          SizedBox(height: 6.0),
                          Text(
                            "Description:",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          SizedBox(height: 6.0), // Additional line break
                          Text(objet.descriptionObjet),
                          SizedBox(height: 6.0),
                          Row(
                            children: [
                              Text(
                                "De ",
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              Text("${objet.chronologie['from']}"),
                            ],
                          ),
                          Row(
                            children: [
                              Text(
                                "à ",
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              Text("${objet.chronologie['to']}"),
                            ],
                          ),
                          SizedBox(height: 6.0),
                          Text(
                            "Raison de la migration:",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text(objet.raisons.join(", ")),
                          SizedBox(height: 6.0),
                          Text(
                            "Populations:",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text(objet.population),
                        ],
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
          ),
          actions: <Widget>[
            // Close button to dismiss the dialog.
            TextButton(
              style: TextButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: Colors.blue[400],
                disabledForegroundColor: Colors.grey.withOpacity(0.38),
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
        ),
      ),
    );
  }
}
