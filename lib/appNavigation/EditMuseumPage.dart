import 'package:flutter/material.dart';
import '../models/musee_model.dart';
import '../database/db_connect.dart';
import '../museum/objet.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class EditMuseumPage extends StatefulWidget {
  final Musee musee;

  EditMuseumPage({required this.musee});

  @override
  _EditMuseumPageState createState() => _EditMuseumPageState();
}

class _EditMuseumPageState extends State<EditMuseumPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _latitudeController = TextEditingController();
  final TextEditingController _longitudeController = TextEditingController();

  List<TextEditingController> _objectNameControllers = [];
  List<TextEditingController> _objectPopulationControllers = [];
  List<TextEditingController> _objectDescriptionControllers = [];
  List<TextEditingController> _objectImageControllers = [];
  List<Map<String, TextEditingController>> _objectChronologieControllers = [];
  List<List<TextEditingController>> _objectRaisonsControllers = [];

  @override
  void initState() {
    super.initState();
    _nameController.text = widget.musee.nomMusee;
    _latitudeController.text = widget.musee.coord.latitude.toString();
    _longitudeController.text = widget.musee.coord.longitude.toString();

    for (var obj in widget.musee.objets) {
      _objectNameControllers.add(TextEditingController(text: obj.nomObjet));
      _objectPopulationControllers.add(TextEditingController(text: obj.population));
      _objectDescriptionControllers.add(TextEditingController(text: obj.descriptionObjet));
      _objectImageControllers.add(TextEditingController(text: obj.image));
      _objectRaisonsControllers.add(obj.raisons.map((raison) => TextEditingController(text: raison)).toList());

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
        title: Text("Modifier le Musée"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ListView(
          children: <Widget>[
            TextField(controller: _nameController, decoration: InputDecoration(labelText: 'Nom du Musée')),
            TextField(controller: _latitudeController, decoration: InputDecoration(labelText: 'Latitude')),
            TextField(controller: _longitudeController, decoration: InputDecoration(labelText: 'Longitude')),

            for (int i = 0; i < widget.musee.objets.length; i++)
              Column(
                children: <Widget>[
                  Text('Objet ${i + 1}'),
                  TextField(controller: _objectNameControllers[i], decoration: InputDecoration(labelText: 'Nom de l\'objet')),
                  TextField(controller: _objectPopulationControllers[i], decoration: InputDecoration(labelText: 'Population')),
                  TextField(controller: _objectDescriptionControllers[i], decoration: InputDecoration(labelText: 'Description')),
                  TextField(controller: _objectImageControllers[i], decoration: InputDecoration(labelText: 'Image URL')),
                  
                  for (var entry in _objectChronologieControllers[i].entries)
                    TextField(controller: entry.value, decoration: InputDecoration(labelText: 'Chronologie - ${entry.key}')),
                  
                  for (var controller in _objectRaisonsControllers[i])
                    TextField(controller: controller, decoration: InputDecoration(labelText: 'Raison')),
                ],
              ),

            ElevatedButton(
              onPressed: () {
                // Construction de la liste des objets
                List<Objet> updatedObjets = [];
                for (int i = 0; i < widget.musee.objets.length; i++) {
                  updatedObjets.add(Objet(
                    nomObjet: _objectNameControllers[i].text,
                    population: _objectPopulationControllers[i].text,
                    descriptionObjet: _objectDescriptionControllers[i].text,
                    image: _objectImageControllers[i].text,
                    raisons: _objectRaisonsControllers[i].map((controller) => controller.text).toList(),
                    chronologie: _objectChronologieControllers[i].map((key, controller) => MapEntry(key, controller.text)),
                  ));
                }

                Musee updatedMusee = Musee(
                  id: widget.musee.id,
                  nomMusee: _nameController.text,
                  coord: LatLng(
                    double.parse(_latitudeController.text),
                    double.parse(_longitudeController.text),
                  ),
                  objets: updatedObjets,
                );

                final db = DBconnect();
                db.updateMusee(updatedMusee);
                Navigator.pop(context);
              },
              child: Text("Sauvegarder"),
            )
          ],
        ),
      ),
    );
  }
}
