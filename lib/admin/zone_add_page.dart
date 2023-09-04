import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../database/db_connect.dart';
import '../models/zone_model.dart';

class ZoneAddPage extends StatefulWidget {
  @override
  _ZoneAddPageState createState() => _ZoneAddPageState();
}

class _ZoneAddPageState extends State<ZoneAddPage> {
  final _formKey = GlobalKey<FormState>();

  List<TextEditingController> _arriveeZoneLatitudeControllers = [];
  List<TextEditingController> _arriveeZoneLongitudeControllers = [];

  List<TextEditingController> _provenanceZoneLatitudeControllers = [];
  List<TextEditingController> _provenanceZoneLongitudeControllers = [];

  late TextEditingController _nomZoneController;
  late TextEditingController _fromChronologieController;
  late TextEditingController _toChronologieController;
  late TextEditingController _populationController;
  late TextEditingController _provenanceNomController;
  late TextEditingController _raisonsController;
  late TextEditingController _raisonsDescriptionController;

  @override
  void initState() {
    super.initState();

    _nomZoneController = TextEditingController();
    _fromChronologieController = TextEditingController();
    _toChronologieController = TextEditingController();
    _populationController = TextEditingController();
    _provenanceNomController = TextEditingController();
    _raisonsController = TextEditingController();
    _raisonsDescriptionController = TextEditingController();

    _addArriveeZoneCoordinate();
    _addProvenanceZoneCoordinate();
  }

  void _addArriveeZoneCoordinate() {
    _arriveeZoneLatitudeControllers.add(TextEditingController());
    _arriveeZoneLongitudeControllers.add(TextEditingController());
    setState(() {});
  }

  void _addProvenanceZoneCoordinate() {
    _provenanceZoneLatitudeControllers.add(TextEditingController());
    _provenanceZoneLongitudeControllers.add(TextEditingController());
    setState(() {});
  }

  final inputLabelStyle = TextStyle(
    fontWeight: FontWeight.bold, // Regular font weight
    fontSize: 16.0, // You can adjust this value to your preference
    color: Colors
        .grey[600], // Assuming this is the default color. Adjust as needed.
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Ajouter une zone'),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Zone Name Field
              TextFormField(
                controller: _nomZoneController,
                decoration: InputDecoration(labelText: 'Nom de la zone'),
                validator: (value) =>
                    value!.isEmpty ? 'Donnée manquante' : null,
              ),
              SizedBox(height: 16.0),

              // Chronologie Fields
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _fromChronologieController,
                      decoration: InputDecoration(labelText: 'Chronologie de'),
                      keyboardType: TextInputType.number,
                      validator: (value) =>
                          value!.isEmpty ? 'Donnée manquante' : null,
                    ),
                  ),
                  SizedBox(width: 16.0),
                  Expanded(
                    child: TextFormField(
                      controller: _toChronologieController,
                      decoration: InputDecoration(labelText: 'Jusqu\'à'),
                      keyboardType: TextInputType.number,
                      validator: (value) =>
                          value!.isEmpty ? 'Donnée manquante' : null,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16.0),

              // Population Field
              TextFormField(
                controller: _populationController,
                decoration: InputDecoration(labelText: 'Type de population'),
                validator: (value) =>
                    value!.isEmpty ? 'Donnée manquante' : null,
              ),
              SizedBox(height: 16.0),

              // Provenance Name Field
              TextFormField(
                controller: _provenanceNomController,
                decoration: InputDecoration(labelText: 'Nom provenance'),
                validator: (value) =>
                    value!.isEmpty ? 'Donnée manquante' : null,
              ),
              SizedBox(height: 16.0),

              // Raisons Fields
              TextFormField(
                controller: _raisonsController,
                decoration: InputDecoration(
                    labelText: 'Raisons (séparées par des virgules)'),
                validator: (value) =>
                    value!.isEmpty ? 'Donnée manquante' : null,
              ),
              SizedBox(height: 16.0),
              TextFormField(
                controller: _raisonsDescriptionController,
                decoration: InputDecoration(labelText: 'Description'),
                maxLines: 1,
                validator: (value) =>
                    value!.isEmpty ? 'Donnée manquante' : null,
              ),
              SizedBox(height: 16.0),

              // Arrivee Zone Coordinates
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Coordonnées de la zone d\'arrivée',
                          style: inputLabelStyle),
                      ...List.generate(
                        _arriveeZoneLatitudeControllers.length,
                        (index) => Column(
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: TextFormField(
                                    controller:
                                        _arriveeZoneLatitudeControllers[index],
                                    decoration:
                                        InputDecoration(labelText: 'Latitude'),
                                    keyboardType:
                                        TextInputType.numberWithOptions(
                                            decimal: true),
                                    validator: (value) => value!.isEmpty
                                        ? 'Donnée manquante'
                                        : null,
                                  ),
                                ),
                                SizedBox(width: 16.0),
                                Expanded(
                                  child: TextFormField(
                                    controller:
                                        _arriveeZoneLongitudeControllers[index],
                                    decoration:
                                        InputDecoration(labelText: 'Longitude'),
                                    keyboardType:
                                        TextInputType.numberWithOptions(
                                            decimal: true),
                                    validator: (value) => value!.isEmpty
                                        ? 'Donnée manquante'
                                        : null,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 8.0),
                      ElevatedButton(
                        onPressed: _addArriveeZoneCoordinate,
                        child: Text("Ajouter une autre coordonnée"),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 16.0),

              // Provenance Zone Coordinates
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Coordonnées de la zone de provenance',
                          style: inputLabelStyle),
                      ...List.generate(
                        _provenanceZoneLatitudeControllers.length,
                        (index) => Column(
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: TextFormField(
                                    controller:
                                        _provenanceZoneLatitudeControllers[
                                            index],
                                    decoration:
                                        InputDecoration(labelText: 'Latitude'),
                                    keyboardType:
                                        TextInputType.numberWithOptions(
                                            decimal: true),
                                    validator: (value) => value!.isEmpty
                                        ? 'Donnée manquante'
                                        : null,
                                  ),
                                ),
                                SizedBox(width: 16.0),
                                Expanded(
                                  child: TextFormField(
                                    controller:
                                        _provenanceZoneLongitudeControllers[
                                            index],
                                    decoration:
                                        InputDecoration(labelText: 'Longitude'),
                                    keyboardType:
                                        TextInputType.numberWithOptions(
                                            decimal: true),
                                    validator: (value) => value!.isEmpty
                                        ? 'Donnée manquante'
                                        : null,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 8.0),
                      ElevatedButton(
                        onPressed: _addProvenanceZoneCoordinate,
                        child: Text("Ajouter une autre coordonnée"),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 16.0),

              // Submit Button
              Center(
                child: ElevatedButton(
                  onPressed: _addZone,
                  child: Text("Envoyer"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _addZone() async {
    if (_formKey.currentState!.validate()) {
      List<GeoPoint> arriveeZoneList = List<GeoPoint>.generate(
          _arriveeZoneLatitudeControllers.length,
          (index) => GeoPoint(
                double.parse(_arriveeZoneLatitudeControllers[index].text),
                double.parse(_arriveeZoneLongitudeControllers[index].text),
              ));

      List<GeoPoint> provenanceZoneList = List<GeoPoint>.generate(
          _provenanceZoneLatitudeControllers.length,
          (index) => GeoPoint(
                double.parse(_provenanceZoneLatitudeControllers[index].text),
                double.parse(_provenanceZoneLongitudeControllers[index].text),
              ));

      // Create an instance of the DBconnect class
      DBconnect db = DBconnect();

      Zone newZone = Zone(
        nomZone: _nomZoneController.text,
        chronologieZone: {
          'from': int.parse(_fromChronologieController.text),
          'to': int.parse(_toChronologieController.text),
        },
        population: _populationController.text,
        provenanceNom: _provenanceNomController.text,
        raisons: _raisonsController.text.split(', ').toList(),
        raisonsDescription: _raisonsDescriptionController.text,
        arriveeZoneList: arriveeZoneList,
        provenanceZoneList: provenanceZoneList,
      );

      await db.addZone(newZone);

      Navigator.pop(context);
    }
  }

  @override
  void dispose() {
    _nomZoneController.dispose();
    _fromChronologieController.dispose();
    _toChronologieController.dispose();
    _populationController.dispose();
    _provenanceNomController.dispose();
    _raisonsController.dispose();
    _raisonsDescriptionController.dispose();

    // Dispose all controllers in the lists:
    _arriveeZoneLatitudeControllers
        .forEach((controller) => controller.dispose());
    _arriveeZoneLongitudeControllers
        .forEach((controller) => controller.dispose());
    _provenanceZoneLatitudeControllers
        .forEach((controller) => controller.dispose());
    _provenanceZoneLongitudeControllers
        .forEach((controller) => controller.dispose());

    super.dispose();
  }
}
