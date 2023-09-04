import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../utils/constants.dart';

class EditZonePage extends StatefulWidget {
  final Map<String, dynamic>? initialData; // null for new entries
  final String? docId;
  final Function? onSave;

  EditZonePage({this.initialData, this.docId, this.onSave});

  @override
  _EditZonePageState createState() => _EditZonePageState();
}

class _EditZonePageState extends State<EditZonePage> {
  final _formKey = GlobalKey<FormState>();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  List<Map<String, TextEditingController>> _arriveeZoneCoordinates = [];
  List<Map<String, TextEditingController>> _provenanceZoneCoordinates = [];

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

    // Initialize arriveeZoneCoordinate
    if (widget.initialData?['arriveeZone'] != null) {
      for (GeoPoint coordinate in widget.initialData?['arriveeZone']) {
        _arriveeZoneCoordinates.add({
          'latitude':
              TextEditingController(text: coordinate.latitude.toString()),
          'longitude':
              TextEditingController(text: coordinate.longitude.toString()),
        });
      }
    }
    if (_arriveeZoneCoordinates.isEmpty) {
      _addArriveeZoneCoordinate();
    }

    // Initialize provenanceZoneCoordinates
    if (widget.initialData?['provenanceZone'] != null) {
      for (GeoPoint coordinate in widget.initialData?['provenanceZone']) {
        _provenanceZoneCoordinates.add({
          'latitude':
              TextEditingController(text: coordinate.latitude.toString()),
          'longitude':
              TextEditingController(text: coordinate.longitude.toString()),
        });
      }
    }
    if (_provenanceZoneCoordinates.isEmpty) {
      _addProvenanceZoneCoordinate();
    }

    _nomZoneController =
        TextEditingController(text: widget.initialData?['nomZone'] ?? '');
    _fromChronologieController = TextEditingController(
        text: widget.initialData?['chronologieZone']['from']?.toString() ?? '');
    _toChronologieController = TextEditingController(
        text: widget.initialData?['chronologieZone']['to']?.toString() ?? '');
    _populationController =
        TextEditingController(text: widget.initialData?['population'] ?? '');
    _provenanceNomController =
        TextEditingController(text: widget.initialData?['provenanceNom'] ?? '');
    _raisonsController = TextEditingController(
        text: widget.initialData?['raisons']?.join(', ') ?? '');
    _raisonsDescriptionController = TextEditingController(
        text: widget.initialData?['raisonsDescription'] ?? '');
  }

  void _addArriveeZoneCoordinate() {
    _arriveeZoneCoordinates.add({
      'latitude': TextEditingController(),
      'longitude': TextEditingController(),
    });
    setState(() {});
  }

  void _addProvenanceZoneCoordinate() {
    _provenanceZoneCoordinates.add({
      'latitude': TextEditingController(),
      'longitude': TextEditingController(),
    });
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Modifier une zone'),
        backgroundColor: background,
        actions: [
          IconButton(
            icon: Icon(Icons.save),
            onPressed: _saveZone,
          )
        ],
      ),
      body: Form(
        key: _formKey,
        child: SafeArea(
          child: ListView(
            padding: EdgeInsets.all(16.0),
            children: [
              Text('Nom de la zone et chronologie',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              SizedBox(height: 10.0),
              Card(
                child: Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _nomZoneController,
                        decoration:
                            InputDecoration(labelText: 'Nom de la zone'),
                        validator: (value) =>
                            value!.isEmpty ? 'Donnée manquante' : null,
                      ),
                      TextFormField(
                        controller: _fromChronologieController,
                        decoration:
                            InputDecoration(labelText: 'Chronologie de'),
                        keyboardType: TextInputType.number,
                        validator: (value) =>
                            value!.isEmpty ? 'Donnée manquante' : null,
                      ),
                      TextFormField(
                        controller: _toChronologieController,
                        decoration: InputDecoration(labelText: 'Jusqu\'à'),
                        keyboardType: TextInputType.number,
                        validator: (value) =>
                            value!.isEmpty ? 'Donnée manquante' : null,
                      ),
                    ],
                  ),
                ),
              ),

              SizedBox(height: 16.0),

              // Arrivée Zone Coordinates
              Text('Coordonnées zone d\'arrivée',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              SizedBox(height: 10.0),
              Card(
                child: Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                      ..._arriveeZoneCoordinates
                          .map((coordinate) => Column(
                                children: [
                                  TextFormField(
                                    controller: coordinate['latitude'],
                                    decoration:
                                        InputDecoration(labelText: 'Latitude'),
                                    keyboardType:
                                        TextInputType.numberWithOptions(
                                            decimal: true),
                                    validator: (value) => value!.isEmpty
                                        ? 'Donnée manquante'
                                        : null,
                                  ),
                                  TextFormField(
                                    controller: coordinate['longitude'],
                                    decoration:
                                        InputDecoration(labelText: 'Longitude'),
                                    keyboardType:
                                        TextInputType.numberWithOptions(
                                            decimal: true),
                                    validator: (value) => value!.isEmpty
                                        ? 'Donnée manquante'
                                        : null,
                                  ),
                                ],
                              ))
                          .toList(),
                      SizedBox(height: 8.0),
                      ElevatedButton(
                        onPressed: _addArriveeZoneCoordinate,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: background,
                        ),
                        child: Text("Ajouter une autre coordonnée"),
                      ),
                    ],
                  ),
                ),
              ),

              SizedBox(height: 16.0),

              // Provenance Zone Coordinates
              Text('Coordonnées zone de provenance',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              SizedBox(height: 10.0),
              Card(
                child: Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                      ..._provenanceZoneCoordinates
                          .map((coordinate) => Column(
                                children: [
                                  TextFormField(
                                    controller: coordinate['latitude'],
                                    decoration:
                                        InputDecoration(labelText: 'Latitude'),
                                    keyboardType:
                                        TextInputType.numberWithOptions(
                                            decimal: true),
                                    validator: (value) => value!.isEmpty
                                        ? 'Donnée manquante'
                                        : null,
                                  ),
                                  TextFormField(
                                    controller: coordinate['longitude'],
                                    decoration:
                                        InputDecoration(labelText: 'Longitude'),
                                    keyboardType:
                                        TextInputType.numberWithOptions(
                                            decimal: true),
                                    validator: (value) => value!.isEmpty
                                        ? 'Donnée manquante'
                                        : null,
                                  ),
                                ],
                              ))
                          .toList(),
                      SizedBox(height: 8.0),
                      ElevatedButton(
                        onPressed: _addProvenanceZoneCoordinate,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: background,
                        ),
                        child: Text("Ajouter une autre coordonnée"),
                      ),
                    ],
                  ),
                ),
              ),

              SizedBox(height: 16.0),

              // Additional Information
              Text('Information additionnelle',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              SizedBox(height: 10.0),
              Card(
                child: Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _populationController,
                        decoration:
                            InputDecoration(labelText: 'Type de population'),
                        validator: (value) =>
                            value!.isEmpty ? 'Donnée manquante' : null,
                      ),
                      TextFormField(
                        controller: _provenanceNomController,
                        decoration:
                            InputDecoration(labelText: 'Provenance Nom'),
                        validator: (value) =>
                            value!.isEmpty ? 'Donnée manquante' : null,
                      ),
                      TextFormField(
                        controller: _raisonsController,
                        decoration: InputDecoration(
                            labelText: 'Raisons (séparées par des virgules)'),
                      ),
                      TextFormField(
                        controller: _raisonsDescriptionController,
                        decoration:
                            InputDecoration(labelText: 'Raisons description'),
                        maxLines: 3,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _saveZone() async {
    if (_formKey.currentState!.validate()) {
// Extract the coordinates from _arriveeZoneCoordinates
      List<GeoPoint> arriveeZoneList =
          _arriveeZoneCoordinates.map((coordinate) {
        final latitude = double.parse(coordinate['latitude']!.text);
        final longitude = double.parse(coordinate['longitude']!.text);
        return GeoPoint(latitude, longitude);
      }).toList();

      // Extract the coordinates from _provenanceZoneCoordinates
      List<GeoPoint> provenanceZoneList =
          _provenanceZoneCoordinates.map((coordinate) {
        final latitude = double.parse(coordinate['latitude']!.text);
        final longitude = double.parse(coordinate['longitude']!.text);
        return GeoPoint(latitude, longitude);
      }).toList();

      try {
        await _firestore.collection('zones').doc(widget.docId).update({
          'nomZone': _nomZoneController.text,
          'chronologieZone': {
            'from': int.parse(_fromChronologieController.text),
            'to': int.parse(_toChronologieController.text),
          },
          'population': _populationController.text,
          'provenanceNom': _provenanceNomController.text,
          'raisons': _raisonsController.text.split(', ').toList(),
          'raisonsDescription': _raisonsDescriptionController.text,
          'arriveeZone': arriveeZoneList,
          'provenanceZone': provenanceZoneList,
        });

        Navigator.pop(context);
        if (widget.onSave != null) {
          widget.onSave!();
        }
      } catch (error) {
        print("Erreur lors de la sauvegarde sur Firestore : $error");
      }
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
    super.dispose();
  }
}
