import 'package:flutter/material.dart';
import '../models/musee_model.dart';
import '../database/db_connect.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../models/objet_model.dart';
import '../utils/constants.dart';

class AddMuseumPage extends StatefulWidget {
  @override
  _AddMuseumPageState createState() => _AddMuseumPageState();
}

class _AddMuseumPageState extends State<AddMuseumPage> {
  // Controllers for capturing museum details.
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _latitudeController = TextEditingController();
  final TextEditingController _longitudeController = TextEditingController();

  // Lists of controllers for capturing details of multiple objects.
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
                  // Fields to fill in when adding a museum.
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

            // For each object added to the museum.
            for (int i = 0; i < _objectNameControllers.length; i++)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      // Fields to fill in when adding an object.
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
            // Button to add a new object.
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
            // Button to save the changes.
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

  // Function to add fields for a new object.
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

  // Function to add a new museum with objects.
  void _addMuseum() {
    // Create a list of objects from the controllers.
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

    // Create an new museum with new objects.
    Musee newMusee = Musee(
      // Generate an ID or let the DB handle it.
      id: '', 
      nomMusee: _nameController.text,
      coord: LatLng(
        double.parse(_latitudeController.text),
        double.parse(_longitudeController.text),
      ),
      // Add the list of objects to the museum.
      objets: objetsList,
    );

    // Add the museum in the database and navigate back.
    final db = DBconnect();
    db.addMusee(newMusee);
    Navigator.pop(context);
  }
}
