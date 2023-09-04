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

  final TextEditingController _objectNameController = TextEditingController();
  final TextEditingController _objectPopulationController =
      TextEditingController();
  final TextEditingController _objectDescriptionController =
      TextEditingController();
  final TextEditingController _objectImageController = TextEditingController();
  final TextEditingController _objectRaisonController = TextEditingController();
  final Map<String, TextEditingController> _objectChronologieControllers = {
    'from': TextEditingController(),
    'to': TextEditingController(),
  };

  List<Objet> objets = [];

  void _addObject() {
    Objet newObjet = Objet(
      nomObjet: _objectNameController.text,
      population: _objectPopulationController.text,
      descriptionObjet: _objectDescriptionController.text,
      image: _objectImageController.text,
      raisons: [_objectRaisonController.text],
      chronologie: _objectChronologieControllers
          .map((key, controller) => MapEntry(key, controller.text)),
    );

    setState(() {
      objets.add(newObjet);
      _objectNameController.clear();
      _objectPopulationController.clear();
      _objectDescriptionController.clear();
      _objectImageController.clear();
      _objectRaisonController.clear();
      _objectChronologieControllers
          .forEach((key, controller) => controller.clear());
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: background,
        title: Text("Ajouter un musée"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: <Widget>[
            Card(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
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
            SizedBox(height: 16.0),
            Text('Ajouter un objet au musée',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    TextField(
                        controller: _objectNameController,
                        decoration:
                            InputDecoration(labelText: 'Nom de l\'objet')),
                    TextField(
                        controller: _objectPopulationController,
                        decoration: InputDecoration(labelText: 'Population')),
                    TextField(
                        controller: _objectDescriptionController,
                        decoration: InputDecoration(labelText: 'Description')),
                    TextField(
                        controller: _objectImageController,
                        decoration: InputDecoration(labelText: 'Image URL')),
                    for (var entry in _objectChronologieControllers.entries)
                      TextField(
                          controller: entry.value,
                          decoration: InputDecoration(
                              labelText: 'Chronologie - ${entry.key}')),
                    TextField(
                        controller: _objectRaisonController,
                        decoration: InputDecoration(labelText: 'Raison')),
                  ],
                ),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: background,
              ),
              onPressed: _addObject,
              child: Text("Ajouter cet objet au musée"),
            ),
            ...objets.map((obj) => ListTile(title: Text(obj.nomObjet))),
            SizedBox(height: 10.0),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: background,
              ),
              onPressed: () {
                Musee newMusee = Musee(
                  id: '', // Générez un ID ou laissez la DB le faire.
                  nomMusee: _nameController.text,
                  coord: LatLng(
                    double.parse(_latitudeController.text),
                    double.parse(_longitudeController.text),
                  ),
                  objets: objets,
                );

                final db = DBconnect();
                db.addMusee(newMusee);
                Navigator.pop(context);
              },
              child: Text("Ajouter le musée complet"),
            )
          ],
        ),
      ),
    );
  }
}
