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

  // Period options
  List<String> periodOptions = [];
  String selectedPeriod = '';

  @override
  void initState() {
    super.initState();
    _fetchPeriods();
    _createMarkers();
    _createPolygons();
  }

  Future<void> _fetchPeriods() async {
    List<String> periods = await db.fetchPeriods();

    setState(() {
      periodOptions = periods;
      selectedPeriod = periodOptions[0];
    });
  }

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  Future<void> _createMarkers() async {
    List<Musee> museums =
        await db.fetchMusees(); // Fetching museums from Firestore

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

  // Function to show the period selection BottomSheet
  void _showPeriodSelection() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return FractionallySizedBox(
          widthFactor: 0.5,
          alignment: Alignment.bottomCenter,
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
                  title: Text(
                    "Sélectionnez une période :",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                const Divider(),
                Container(
                  height: MediaQuery.of(context).size.height * 0.4,
                  child: ListView.builder(
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
        body: Stack(
          children: [
            GoogleMap(
              onMapCreated: _onMapCreated,
              initialCameraPosition: CameraPosition(
                target: _center,
                zoom: 11.0,
              ),
              markers: markers,
              polygons: polygons, // Ajout des polygones
            ),
            Positioned(
              right: 60,
              bottom: 24,
              child: Container(
                width: 180,
                height: 80,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 6.0,
                      spreadRadius: 2.0,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: GestureDetector(
                  onTap: _showPeriodSelection,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.history),
                      const SizedBox(width: 8),
                      RichText(
                          text: TextSpan(children: [
                        const TextSpan(
                          text: "Période choisie :\n",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        TextSpan(text: selectedPeriod)
                      ])),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
