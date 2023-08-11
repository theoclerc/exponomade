import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../museum/museum_marker.dart';
import '../database/data.dart';
import '../zones/arriveZone.dart';
import '../zones/arriveZonepolygon.dart';
import '../zones/provenanceZone.dart';
import '../zones/provenanceZonepolygon.dart';

class MapToggle extends StatefulWidget {
  const MapToggle({Key? key}) : super(key: key);

  @override
  _MapToggleState createState() => _MapToggleState();
}

class _MapToggleState extends State<MapToggle> {
  late GoogleMapController mapController;
  final LatLng _center = const LatLng(46.229352, 7.362049);
  Set<Marker> markers = {};
  Set<Polygon> polygons = {};

  @override
  void initState() {
    super.initState();
    _createMarkers();
    _createPolygons();
  }

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  Future<void> _createMarkers() async {
    for (var museum in museums) {
      Marker marker = await createMuseumMarker(context, museum);
      setState(() {
        markers.add(marker);
      });
    }
  }

  void _createPolygons() {
    // arriveeZone
    var arriveeZoneCoordinates = [
     LatLng(46.3027, 7.5736), // Bois de Finges
  LatLng(46.1144, 7.5094), // Évolène
  LatLng(46.0911, 7.4386), // Mont Fort
  LatLng(46.2076, 7.1872), // Chamoson
  LatLng(46.3208, 7.1561), // Les Diablerets
  LatLng(46.3033, 7.4186), // Wildhorn
  LatLng(46.3027, 7.5736), // Retour au Bois de Finges
    ];
    var arriveeZone = arriveZone(
      name: 'Arrival Zone',
      coordinates: arriveeZoneCoordinates,
      from: DateTime.now(),
      to: DateTime.now().add(Duration(days: 1)),
    );
    polygons.add(arriveZonePolygon(arriveeZone));

    // provenanceZone
  var provenanceZoneCoordinates = [
  LatLng(50.1109, 9.6825),  // Frontière nord de l'Empire en Germanie
  LatLng(43.325, -6.364),   // Nord de l'Espagne
  LatLng(36.527, -6.289),   // Sud de l'Espagne
  LatLng(36.862, 10.323),   // Tunisie, près de Carthage
  LatLng(31.200, 29.918),   // Égypte, près d'Alexandrie
  LatLng(36.202, 36.157),   // Côte turque
  LatLng(44.409, 28.965),   // Près de la côte de la Mer Noire en Roumanie
  LatLng(51.165, 10.451),   // Frontière nord de l'Empire en Germanie (retour)
    ];
    var provenanceZoneData = ProvenanceZone(
      provenanceNom: 'Provenance Zone',
      provenanceZone: provenanceZoneCoordinates,
      reasons: ['Reason 1', 'Reason 2'],
      reasonsDescription: 'Description',
    );
    polygons.add(provenanceZonePolygon(provenanceZoneData));
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: GoogleMap(
          onMapCreated: _onMapCreated,
          initialCameraPosition: CameraPosition(
            target: _center,
            zoom: 11.0,
          ),
          markers: markers,
          polygons: polygons, // Ajout des polygones
        ),
      ),
    );
  }
}
