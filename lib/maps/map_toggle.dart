import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../museum/museum_marker.dart';
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
  var db = DBconnect();

  @override
  void initState() {
    super.initState();
    _createMarkers();
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
        ),
      ),
    );
  }
}
