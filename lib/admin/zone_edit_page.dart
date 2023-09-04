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
              // Zone Name and Chronology
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
                        decoration: InputDecoration(labelText: 'Nom Zone'),
                        validator: (value) =>
                            value!.isEmpty ? 'Cannot be empty' : null,
                      ),
                      TextFormField(
                        controller: _fromChronologieController,
                        decoration:
                            InputDecoration(labelText: 'Chronologie From'),
                        keyboardType: TextInputType.number,
                        validator: (value) =>
                            value!.isEmpty ? 'Cannot be empty' : null,
                      ),
                      TextFormField(
                        controller: _toChronologieController,
                        decoration:
                            InputDecoration(labelText: 'Chronologie To'),
                        keyboardType: TextInputType.number,
                        validator: (value) =>
                            value!.isEmpty ? 'Cannot be empty' : null,
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
                                    decoration: InputDecoration(
                                        labelText: 'Arrivee Zone Latitude'),
                                    keyboardType:
                                        TextInputType.numberWithOptions(
                                            decimal: true),
                                    validator: (value) => value!.isEmpty
                                        ? 'Cannot be empty'
                                        : null,
                                  ),
                                  TextFormField(
                                    controller: coordinate['longitude'],
                                    decoration: InputDecoration(
                                        labelText: 'Arrivee Zone Longitude'),
                                    keyboardType:
                                        TextInputType.numberWithOptions(
                                            decimal: true),
                                    validator: (value) => value!.isEmpty
                                        ? 'Cannot be empty'
                                        : null,
                                  ),
                                ],
                              ))
                          .toList(),
                      ElevatedButton(
                        onPressed: _addArriveeZoneCoordinate,
                        child: Text("Ajouter une autre coordonnée d'arrivée"),
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
                                    decoration: InputDecoration(
                                        labelText: 'Provenance Zone Latitude'),
                                    keyboardType:
                                        TextInputType.numberWithOptions(
                                            decimal: true),
                                    validator: (value) => value!.isEmpty
                                        ? 'Cannot be empty'
                                        : null,
                                  ),
                                  TextFormField(
                                    controller: coordinate['longitude'],
                                    decoration: InputDecoration(
                                        labelText: 'Provenance Zone Longitude'),
                                    keyboardType:
                                        TextInputType.numberWithOptions(
                                            decimal: true),
                                    validator: (value) => value!.isEmpty
                                        ? 'Cannot be empty'
                                        : null,
                                  ),
                                ],
                              ))
                          .toList(),
                      ElevatedButton(
                        onPressed: _addProvenanceZoneCoordinate,
                        child:
                            Text("Ajouter une autre coordonnée de provenance"),
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
                        decoration: InputDecoration(labelText: 'Population'),
                        validator: (value) =>
                            value!.isEmpty ? 'Cannot be empty' : null,
                      ),
                      TextFormField(
                        controller: _provenanceNomController,
                        decoration:
                            InputDecoration(labelText: 'Provenance Nom'),
                        validator: (value) =>
                            value!.isEmpty ? 'Cannot be empty' : null,
                      ),
                      TextFormField(
                        controller: _raisonsController,
                        decoration: InputDecoration(
                            labelText: 'Raisons (comma separated)'),
                      ),
                      TextFormField(
                        controller: _raisonsDescriptionController,
                        decoration:
                            InputDecoration(labelText: 'Raisons Description'),
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
      try {
        // Decide if you want to update or add a new document
        if (widget.initialData != null && widget.docId != null) {
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
          });
        } else {
          List<Map<String, dynamic>> arriveeZoneList = _arriveeZoneCoordinates
              .map((coordinate) => {
                    'latitude': double.parse(
                        (coordinate['latitude'] as TextEditingController).text),
                    'longitude': double.parse(
                        (coordinate['longitude'] as TextEditingController)
                            .text),
                  })
              .toList();

          await _firestore.collection('zones').add({
            'nomZone': _nomZoneController.text,
            'chronologieZone': {
              'from': int.parse(_fromChronologieController.text),
              'to': int.parse(_toChronologieController.text),
            },
            'population': _populationController.text,
            'provenanceNom': _provenanceNomController.text,
            'raisons': _raisonsController.text.split(', ').toList(),
            'raisonsDescription': _raisonsDescriptionController.text,
          });
        }
        Navigator.pop(context);
        if (widget.onSave != null) {
          widget.onSave!();
        }
      } catch (error) {
        print("Error saving to Firestore: $error");
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
