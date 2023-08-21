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
  List<String> periodOptions = [];
  String selectedPeriod = '';
  // Reasons options
  List<String> reasonOptions = [];
  String selectedReason = '';
  // Population options
  List<String> populationOptions = [];
  String selectedPopulation = '';

  @override
  void initState() {
    super.initState();
    _fetchPeriods();
    _fetchReasons();
    _fetchPopulations();
    _createMarkersAndPolygons();
  }

  Future<void> _fetchPeriods() async {
    List<String> periods = await db.fetchPeriods();

    setState(() {
      periodOptions = periods;
      selectedPeriod = periodOptions[5];
    });
  }

  Future<void> _fetchReasons() async {
    List<String> reasons = await db.fetchReasons();

    setState(() {
      reasonOptions = reasons;
      selectedReason = reasonOptions[0];
    });
  }

  Future<void> _fetchPopulations() async {
    List<String> populations = await db.fetchPopulations();

    setState(() {
      populationOptions = populations;
      selectedPopulation = populationOptions[0];
    });
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

  Future<void> _addMuseumMarkers(selectedPeriod) async {
    // Update museums
    List<Musee> museums =
        await db.updateMuseumsAndObjectsForSelectedPeriod(selectedPeriod);

    for (var museum in museums) {
      Marker marker = await createMuseumMarker(context, museum);
      setState(() {
        markers.add(marker);
      });
    }
  }

  Future<void> _createMarkersAndPolygons() async {
    List<arriveZone> arriveeZones = await db.fetchArriveZones();
    List<ProvenanceZone> provenanceZones = await db.fetchProvenanceZones();
    await _addMuseumMarkers(selectedPeriod);

    if (selectedPeriod != "Aucune") {
      arriveeZones =
          await db.updateArriveZonesForSelectedPeriod(selectedPeriod);
      provenanceZones =
          await db.updateProvenanceZonesForSelectedPeriod(selectedPeriod);
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
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return FractionallySizedBox(
          heightFactor: 2 / 3,
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
                Expanded(
                  child: ListView.builder(
                    itemCount: periodOptions.length,
                    itemBuilder: (context, index) {
                      final period = periodOptions[index];
                      return ListTile(
                        title: Text(period),
                        onTap: () {
                          setState(() {
                            selectedPeriod = period;
                            _updateZonesForSelectedPeriod();
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

  void _showReasonsSelection() {
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
                    "Sélectionnez une raison :",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                const Divider(),
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.4,
                  child: ListView.builder(
                    itemCount: reasonOptions.length,
                    itemBuilder: (context, index) {
                      final reason = reasonOptions[index];
                      return ListTile(
                        title: Text(reason),
                        onTap: () {
                          setState(() {
                            selectedReason = reason;
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

  void _showPopulationSelection() {
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
                    "Sélectionnez une population :",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                const Divider(),
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.4,
                  child: ListView.builder(
                    itemCount: populationOptions.length,
                    itemBuilder: (context, index) {
                      final population = populationOptions[index];
                      return ListTile(
                        title: Text(population),
                        onTap: () {
                          setState(() {
                            selectedPopulation = population;
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

  Future<void> _updateZonesForSelectedPeriod() async {
    // Update arriveeZones
    List<arriveZone> updatedArriveeZones =
        await db.updateArriveZonesForSelectedPeriod(selectedPeriod);

    // Update provenanceZones
    List<ProvenanceZone> updatedProvenanceZones =
        await db.updateProvenanceZonesForSelectedPeriod(selectedPeriod);

    // Clear existing polygons and markers
    setState(() {
      polygons.clear();
      markers.clear();
    });

    // Add markers and polygons for updated zones
    for (var arriveeZone in updatedArriveeZones) {
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
        polygons.add(arriveZonePolygon(arriveeZone)); // Adding the polygon
      });
    }
    for (var zone in updatedProvenanceZones) {
      Marker marker = Marker(
        markerId: MarkerId(zone.provenanceNom),
        position: _getPolygonCenter(zone.provenanceZone),
        infoWindow: InfoWindow(title: zone.provenanceNom),
        onTap: () {
          showDialog(
            context: context,
            builder: (context) => provenanceZoneInfoPopup(zone: zone),
          );
        },
      );

      setState(() {
        markers.add(marker);
        polygons.add(provenanceZonePolygon(zone));
      });
    }
    // Update museums
    await _addMuseumMarkers(selectedPeriod);
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
              polygons: polygons,
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
            Positioned(
              right: 250,
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
                  onTap: _showReasonsSelection,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.lightbulb_outline),
                      const SizedBox(width: 8),
                      RichText(
                          text: TextSpan(children: [
                        const TextSpan(
                          text: "Raison choisie :\n",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        TextSpan(text: selectedReason)
                      ])),
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              right: 440, // Adjusted the position for the new container
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
                  onTap: _showPopulationSelection,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.people),
                      const SizedBox(width: 8),
                      RichText(
                          text: TextSpan(children: [
                        const TextSpan(
                          text: "Population choisie :\n",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        TextSpan(text: selectedPopulation)
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
