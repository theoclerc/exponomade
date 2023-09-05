import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../database/db_connect.dart';
import '../models/zone_model.dart';
import '../utils/constants.dart';

class ZoneAddPage extends StatefulWidget {
  @override
  _ZoneAddPageState createState() => _ZoneAddPageState();
}

class _ZoneAddPageState extends State<ZoneAddPage> {
  final _formKey = GlobalKey<FormState>();

  // Lists to hold controllers for coordinates of arrival zones.
  List<TextEditingController> _arriveeZoneLatitudeControllers = [];
  List<TextEditingController> _arriveeZoneLongitudeControllers = [];

  // Lists to hold controllers for coordinates of provenance zones.
  List<TextEditingController> _provenanceZoneLatitudeControllers = [];
  List<TextEditingController> _provenanceZoneLongitudeControllers = [];

  // Controllers for various input fields.
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

    // Initialize controllers for various input fields.
    _nomZoneController = TextEditingController();
    _fromChronologieController = TextEditingController();
    _toChronologieController = TextEditingController();
    _populationController = TextEditingController();
    _provenanceNomController = TextEditingController();
    _raisonsController = TextEditingController();
    _raisonsDescriptionController = TextEditingController();

    // Add initial coordinates for arrival and provenance zones.
    _addArriveeZoneCoordinate();
    _addProvenanceZoneCoordinate();
  }

  // Function to add a new arrival zone coordinate.
  void _addArriveeZoneCoordinate() {
    _arriveeZoneLatitudeControllers.add(TextEditingController());
    _arriveeZoneLongitudeControllers.add(TextEditingController());
    setState(() {});
  }

  // Function to add a new provenance zone coordinate.
  void _addProvenanceZoneCoordinate() {
    _provenanceZoneLatitudeControllers.add(TextEditingController());
    _provenanceZoneLongitudeControllers.add(TextEditingController());
    setState(() {});
  }

  // Style for input field labels.
  final inputLabelStyle = TextStyle(
    fontWeight: FontWeight.bold,
    fontSize: 16.0,
    color: Colors.grey[600],
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Ajouter une zone'),
        backgroundColor: background,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Zone Name Field.
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                      // Input field for the zone name.
                      TextFormField(
                        controller: _nomZoneController,
                        decoration:
                            InputDecoration(labelText: 'Nom de la zone'),
                        validator: (value) =>
                            value!.isEmpty ? 'Donnée manquante' : null,
                      ),
                      SizedBox(height: 16.0),

                      // Chronology Fields.
                      Row(
                        children: [
                          // Input field for "Chronologie de".
                          Expanded(
                            child: TextFormField(
                              controller: _fromChronologieController,
                              decoration:
                                  InputDecoration(labelText: 'Chronologie de'),
                              keyboardType: TextInputType.number,
                              validator: (value) =>
                                  value!.isEmpty ? 'Donnée manquante' : null,
                            ),
                          ),
                          SizedBox(width: 16.0),
                          // Input field for "Jusqu'à".
                          Expanded(
                            child: TextFormField(
                              controller: _toChronologieController,
                              decoration:
                                  InputDecoration(labelText: 'Jusqu\'à'),
                              keyboardType: TextInputType.number,
                              validator: (value) =>
                                  value!.isEmpty ? 'Donnée manquante' : null,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 16.0),

                      // Population Field.
                      TextFormField(
                        controller: _populationController,
                        decoration:
                            InputDecoration(labelText: 'Type de population'),
                        validator: (value) =>
                            value!.isEmpty ? 'Donnée manquante' : null,
                      ),
                      SizedBox(height: 16.0),

                      // Provenance Name Field.
                      TextFormField(
                        controller: _provenanceNomController,
                        decoration:
                            InputDecoration(labelText: 'Nom provenance'),
                        validator: (value) =>
                            value!.isEmpty ? 'Donnée manquante' : null,
                      ),
                      SizedBox(height: 16.0),

                      // Raisons Fields.
                      TextFormField(
                        controller: _raisonsController,
                        decoration: InputDecoration(
                            labelText: 'Raisons (séparées par des virgules)'),
                        validator: (value) =>
                            value!.isEmpty ? 'Donnée manquante' : null,
                      ),
                      SizedBox(height: 16.0),
                      // Input field for "Description".
                      TextFormField(
                        controller: _raisonsDescriptionController,
                        decoration: InputDecoration(labelText: 'Description'),
                        maxLines: 1,
                        validator: (value) =>
                            value!.isEmpty ? 'Donnée manquante' : null,
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 16.0),

              // Arrival Zone Coordinates.
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
                                // Input field for "Latitude".
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
                                // Input field for "Longitude".
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
                      // Button to add another coordinate.
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: background,
                        ),
                        onPressed: _addArriveeZoneCoordinate,
                        child: Text("Ajouter une autre coordonnée"),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 16.0),

              // Provenance Zone Coordinates.
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
                                // Input field for "Latitude".
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
                                // Input field for "Longitude".
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
                      // Button to add another coordinate.
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: background,
                        ),
                        onPressed: _addProvenanceZoneCoordinate,
                        child: Text("Ajouter une autre coordonnée"),
                      ),
                    ],
                  ),
                ),
              ),
              // Submit Button.
              Center(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: background,
                  ),
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

  // Function to add a new zone.
  void _addZone() async {
    if (_formKey.currentState!.validate()) {
      // Create lists of GeoPoint objects for arrival and provenance zones.
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

      // Create an instance of the DBconnect class.
      DBconnect db = DBconnect();

      // Create a new Zone object with input data.
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

      // Add the new Zone to the database.
      await db.addZone(newZone);

      // Navigate back to the previous screen.
      Navigator.pop(context);
    }
  }

  @override
  void dispose() {
    // Dispose all controllers when the widget is disposed.
    _nomZoneController.dispose();
    _fromChronologieController.dispose();
    _toChronologieController.dispose();
    _populationController.dispose();
    _provenanceNomController.dispose();
    _raisonsController.dispose();
    _raisonsDescriptionController.dispose();

    // Dispose all controllers in the lists.
    _arriveeZoneLatitudeControllers.forEach((controller) => controller.dispose());
    _arriveeZoneLongitudeControllers
        .forEach((controller) => controller.dispose());
    _provenanceZoneLatitudeControllers
        .forEach((controller) => controller.dispose());
    _provenanceZoneLongitudeControllers
        .forEach((controller) => controller.dispose());

    super.dispose();
  }
}
