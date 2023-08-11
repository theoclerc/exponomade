import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../museum/museum_marker.dart';
import '../zones/arriveZone.dart';
import '../zones/arriveZonepolygon.dart';
import '../zones/provenanceZone.dart';
import '../zones/provenanceZonepolygon.dart';
import '../models/musee_model.dart';
import '../database/db_connect.dart';

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
  var db = DBconnect();

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
    List<Musee> museums = await db.fetchMusees(); // Fetching museums from Firestore

    for (var museum in museums) {
      Marker marker = await createMuseumMarker(context, museum);
      setState(() {
        markers.add(marker);
      });
    }
  }

  Future<void> _createPolygons() async {
    // Fetching arrival and provenance zones from Firestore
    List<arriveZone> arriveeZones = await db.fetchArriveZones();
    List<ProvenanceZone> provenanceZones = await db.fetchProvenanceZones();

    // Adding polygons for arrival zones
    for (var arriveeZone in arriveeZones) {
      setState(() {
        polygons.add(arriveZonePolygon(arriveeZone));
      });
    }

    // Adding polygons for provenance zones
    for (var provenanceZoneData in provenanceZones) {
      setState(() {
        polygons.add(provenanceZonePolygon(provenanceZoneData));
      });
    }
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
