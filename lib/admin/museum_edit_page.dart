import 'package:flutter/material.dart';
import '../models/musee_model.dart';
import '../database/db_connect.dart';
import '../models/objet_model.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../utils/constants.dart';

class EditMuseumPage extends StatefulWidget {
  final Musee musee;

  EditMuseumPage({required this.musee});

  @override
  _EditMuseumPageState createState() => _EditMuseumPageState();
}

class _EditMuseumPageState extends State<EditMuseumPage> {
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
  List<List<TextEditingController>> _objectRaisonsControllers = [];

  @override
  void initState() {
    super.initState();

    // Initialize controllers with existing museum data.
    _nameController.text = widget.musee.nomMusee;
    _latitudeController.text = widget.musee.coord.latitude.toString();
    _longitudeController.text = widget.musee.coord.longitude.toString();

    // Initialize controllers for each object.
    for (var obj in widget.musee.objets) {
      _objectNameControllers.add(TextEditingController(text: obj.nomObjet));
      _objectPopulationControllers.add(TextEditingController(text: obj.population));
      _objectDescriptionControllers.add(TextEditingController(text: obj.descriptionObjet));
      _objectImageControllers.add(TextEditingController(text: obj.image));

      // Initialize controllers for object reasons.
      _objectRaisonsControllers.add(obj.raisons.map((raison) => TextEditingController(text: raison)).toList());

      // Initialize controllers for object chronology.
      var chronologieMap = Map<String, TextEditingController>();
      obj.chronologie.forEach((key, value) {
        chronologieMap[key] = TextEditingController(text: value);
      });
      _objectChronologieControllers.add(chronologieMap);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Modifier le musée"),
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
                  // Fields to modify when editing a museum.
                  children: [
                    TextField(
                        controller: _nameController,
                        decoration: InputDecoration(labelText: 'Nom du musée')),
                    TextField(
                        controller: _latitudeController,
                        decoration: InputDecoration(labelText: 'Latitude')),
                    TextField(
                        controller: _longitudeController,
                        decoration: InputDecoration(labelText: 'Longitude')),
                  ],
                ),
              ),
            ),

            // For each object of the museum.
            for (int i = 0; i < _objectNameControllers.length; i++)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      // Fields to modify when editing an object.
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
                                    'Chronologie - ${entry.key == 'from' ? 'Date début' : (entry.key == 'to' ? 'Date fin' : entry.key)}'),
                          ),
                        for (var controller in _objectRaisonsControllers[i])
                          TextField(
                              controller: controller,
                              decoration: InputDecoration(
                                  labelText:
                                      'Raisons (séparées par des virgules)')),
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
                onPressed: () {
                  setState(() {
                    _objectNameControllers.add(TextEditingController());
                    _objectPopulationControllers.add(TextEditingController());
                    _objectDescriptionControllers.add(TextEditingController());
                    _objectImageControllers.add(TextEditingController());
                    _objectRaisonsControllers.add([TextEditingController()]);
                    _objectChronologieControllers.add({
                      'from': TextEditingController(),
                      'to': TextEditingController(),
                    });
                  });
                },
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
                onPressed: _saveMuseum,
                child: Text("Sauvegarder"),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Function to save the museum.
  void _saveMuseum() {
    // Create a list of updated objects from the controllers
    List<Objet> updatedObjets = [];
    for (int i = 0; i < _objectNameControllers.length; i++) {
      updatedObjets.add(Objet(
        nomObjet: _objectNameControllers[i].text,
        population: _objectPopulationControllers[i].text,
        descriptionObjet: _objectDescriptionControllers[i].text,
        image: _objectImageControllers[i].text,
        raisons: _objectRaisonsControllers[i]
            .map((controller) => controller.text)
            .toList(),
        chronologie: _objectChronologieControllers[i]
            .map((key, controller) => MapEntry(key, controller.text)),
      ));
    }

    // Create an updated museum with updated objects.
    Musee updatedMusee = Musee(
      id: widget.musee.id,
      nomMusee: _nameController.text,
      coord: LatLng(
        double.parse(_latitudeController.text),
        double.parse(_longitudeController.text),
      ),
      // Update the list of objects to the museum.
      objets: updatedObjets,
    );

    // Update the museum in the database and navigate back.
    final db = DBconnect();
    db.updateMusee(updatedMusee);
    Navigator.pop(context);
  }
}
