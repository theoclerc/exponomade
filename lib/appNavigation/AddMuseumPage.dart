import 'package:flutter/material.dart';
import '../models/musee_model.dart';
import '../database/db_connect.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../museum/objet.dart';
import '../utils/constants.dart';

class AddMuseumPage extends StatefulWidget {
  @override
  _AddMuseumPageState createState() => _AddMuseumPageState();
}

class _AddMuseumPageState extends State<AddMuseumPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _latitudeController = TextEditingController();
  final TextEditingController _longitudeController = TextEditingController();

  List<TextEditingController> _objectNameControllers = [];
  List<TextEditingController> _objectPopulationControllers = [];
  List<TextEditingController> _objectDescriptionControllers = [];
  List<TextEditingController> _objectImageControllers = [];
  List<Map<String, TextEditingController>> _objectChronologieControllers = [];
  List<TextEditingController> _objectReasonControllers = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Ajouter un musée"),
        backgroundColor: background,
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ListView(
          children: <Widget>[
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  children: [
                    TextField(
                      controller: _nameController,
                      decoration: InputDecoration(labelText: 'Nom du musée'),
                    ),
                    TextField(
                      controller: _latitudeController,
                      decoration: InputDecoration(labelText: 'Latitude'),
                    ),
                    TextField(
                      controller: _longitudeController,
                      decoration: InputDecoration(labelText: 'Longitude'),
                    ),
                  ],
                ),
              ),
            ),

            // Pour chaque objet ajouté au musée
            for (int i = 0; i < _objectNameControllers.length; i++)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text('Objet ${i + 1}',
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold)),
                        TextField(
                            controller: _objectNameControllers[i],
                            decoration:
                                InputDecoration(labelText: 'Nom de l\'objet')),
                        TextField(
                            controller: _objectPopulationControllers[i],
                            decoration:
                                InputDecoration(labelText: 'Population')),
                        TextField(
                            controller: _objectDescriptionControllers[i],
                            decoration:
                                InputDecoration(labelText: 'Description')),
                        TextField(
                            controller: _objectImageControllers[i],
                            decoration:
                                InputDecoration(labelText: 'Image URL')),
                        for (var entry
                            in _objectChronologieControllers[i].entries)
                          TextField(
                            controller: entry.value,
                            decoration: InputDecoration(
                                labelText:
                                    'Chronologie - ${entry.key == 'from' ? 'Date début' : 'Date fin'}'),
                          ),
                        TextField(
                          controller: _objectReasonControllers[i],
                          decoration: InputDecoration(
                              labelText: 'Raisons (séparées par des virgules)'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            Center(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: background,
                ),
                onPressed: _addObjectFields,
                child: Text("Ajouter un objet"),
              ),
            ),
            SizedBox(height: 8.0),
            Center(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: background,
                ),
                onPressed: _addMuseum,
                child: Text("Envoyer"),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _addObjectFields() {
    setState(() {
      _objectNameControllers.add(TextEditingController());
      _objectPopulationControllers.add(TextEditingController());
      _objectDescriptionControllers.add(TextEditingController());
      _objectImageControllers.add(TextEditingController());
      _objectChronologieControllers.add({
        'from': TextEditingController(),
        'to': TextEditingController(),
      });
      _objectReasonControllers.add(TextEditingController());
    });
  }

  void _addMuseum() {
    // Création de la liste des objets à partir des contrôleurs
    List<Objet> objetsList = [];
    for (int i = 0; i < _objectNameControllers.length; i++) {
      objetsList.add(
        Objet(
          nomObjet: _objectNameControllers[i].text,
          population: _objectPopulationControllers[i].text,
          descriptionObjet: _objectDescriptionControllers[i].text,
          image: _objectImageControllers[i].text,
          chronologie: {
            'from': _objectChronologieControllers[i]['from']!.text,
            'to': _objectChronologieControllers[i]['to']!.text,
          },
          raisons: _objectReasonControllers[i]
              .text
              .split(',')
              .map((reason) => reason.trim())
              .toList(),
        ),
      );
    }

    Musee newMusee = Musee(
      id: '', // Générez un ID ou laissez la DB le faire.
      nomMusee: _nameController.text,
      coord: LatLng(
        double.parse(_latitudeController.text),
        double.parse(_longitudeController.text),
      ),
      objets: objetsList, // Ajout de la liste des objets au musée
    );

    final db = DBconnect();
    db.addMusee(newMusee);
    Navigator.pop(context);
  }
}
