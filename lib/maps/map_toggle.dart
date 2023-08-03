import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../museum/museum_marker.dart';
import '../database/data.dart';

class MapToggle extends StatefulWidget {
  const MapToggle({Key? key}) : super(key: key);

  @override
  _MapToggleState createState() => _MapToggleState();
}

class _MapToggleState extends State<MapToggle> {
  late GoogleMapController mapController;

  final LatLng _center = const LatLng(46.229352, 7.362049);

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
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
          markers: museums.map((museum) => createMuseumMarker(context, museum)).toSet(),
        ),
      ),
    );
  }
}
