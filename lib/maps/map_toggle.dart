import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../museum/museum_marker.dart';
import '../zones/arriveZone.dart';
import '../zones/arriveZonepolygon.dart';
import '../zones/provenanceZone.dart';
import '../zones/provenanceZonepolygon.dart';
import '../models/musee_model.dart';
import '../database/db_connect.dart';
import '../zones/arriveZoneInfoPopup.dart';
import '../zones/provenanceZoneInfoPopup.dart';


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

  // Period options
  List<String> periodOptions = [
    "Prehistoric",
    "Ancient",
    "Medieval",
    "Modern",
    "Contemporary",
  ];

  String selectedPeriod = "Prehistoric"; // Default selected period

  @override
  void initState() {
    super.initState();
    _createMarkersAndPolygons();
  }

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  LatLng _getPolygonCenter(List<LatLng> coordinates) {
    double latitude = 0;
    double longitude = 0;
    int count = coordinates.length;

    for (var coordinate in coordinates) {
      latitude += coordinate.latitude;
      longitude += coordinate.longitude;
    }

    return LatLng(latitude / count, longitude / count);
  }

  Future<void> _createMarkersAndPolygons() async {
    List<Musee> museums = await db.fetchMusees();
    List<arriveZone> arriveeZones = await db.fetchArriveZones();
    List<ProvenanceZone> provenanceZones = await db.fetchProvenanceZones();

    for (var museum in museums) {
      Marker marker = await createMuseumMarker(context, museum);
      setState(() {
        markers.add(marker);
      });
    }

    for (var arriveeZone in arriveeZones) {
      Marker marker = Marker(
        markerId: MarkerId(arriveeZone.name),
        position: _getPolygonCenter(arriveeZone.coordinates),
        infoWindow: InfoWindow(title: arriveeZone.name),
        onTap: () {
          showDialog(
            context: context,
            builder: (context) => arriveZoneInfoPopup(zone: arriveeZone),
          );
        },
      );
      setState(() {
        markers.add(marker);
        polygons.add(arriveZonePolygon(arriveeZone));
      });
    }

    for (var provenanceZone in provenanceZones) {
      Marker marker = Marker(
        markerId: MarkerId(provenanceZone.provenanceNom),
        position: _getPolygonCenter(provenanceZone.provenanceZone),
        infoWindow: InfoWindow(title: provenanceZone.provenanceNom),
        onTap: () {
          showDialog(
            context: context,
            builder: (context) => provenanceZoneInfoPopup(zone: provenanceZone),
          );
        },
      );
      setState(() {
        markers.add(marker);
        polygons.add(provenanceZonePolygon(provenanceZone));
      });
    }
  }

  // Function to show the period selection BottomSheet
  void _showPeriodSelection() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor:
          Colors.transparent, // Set the background color to transparent
      builder: (BuildContext context) {
        return FractionallySizedBox(
          widthFactor: 0.5, // Adjust the width factor as needed
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const ListTile(
                  title: Text("Sélectionnez une période :",
                      style: TextStyle(fontWeight: FontWeight.bold)),
                ),
                Divider(),
                ListView.builder(
                  shrinkWrap: true,
                  itemCount: periodOptions.length,
                  itemBuilder: (context, index) {
                    final period = periodOptions[index];
                    return ListTile(
                      title: Text(period),
                      onTap: () {
                        setState(() {
                          selectedPeriod = period;
                        });
                        Navigator.pop(context);
                      },
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
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
          polygons: polygons,
        ),
      ),
    );
  }
}
