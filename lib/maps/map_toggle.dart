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
import 'package:flutter/services.dart';

class MapToggle extends StatefulWidget {
  const MapToggle({Key? key}) : super(key: key);

  @override
  _MapToggleState createState() => _MapToggleState();
}

class _MapToggleState extends State<MapToggle> {
  late GoogleMapController mapController;
  late String _mapStyle;
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
    rootBundle.loadString('map_style.json').then((string) {
      _mapStyle = string;
    });
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
    controller.setMapStyle(_mapStyle);
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

  Future<void> _addMuseumMarkersForSelectedReason(selectedReason) async {
    // Update museums
    List<Musee> museums =
        await db.updateMuseumsAndObjectsForSelectedReason(selectedReason);

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

    if (selectedReason != "Aucune") {
      arriveeZones =
          await db.updateArriveZonesForSelectedReason(selectedReason);
      provenanceZones =
          await db.updateProvenanceZonesForSelectedReason(selectedReason);
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
        polygons.add(arriveZonePolygon(context, arriveeZone));
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
        polygons.add(provenanceZonePolygon(context, provenanceZone));
      });
    }
  }

  void _showPeriodSelection() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            "Sélectionnez une période :",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Divider(),
              SizedBox(
                height: MediaQuery.of(context).size.height * 2 / 3,
                width: MediaQuery.of(context).size.width * 1 / 4,
                child: SingleChildScrollView(
                  child: Column(
                    children: List.generate(periodOptions.length, (index) {
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
                    }),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showReasonsSelection() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            "Sélectionnez une raison :",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Divider(),
              SizedBox(
                height: MediaQuery.of(context).size.height * 1 / 2,
                width: MediaQuery.of(context).size.width * 1 / 4,
                child: ListView.builder(
                  itemCount: reasonOptions.length,
                  itemBuilder: (context, index) {
                    final reason = reasonOptions[index];
                    return ListTile(
                      title: Text(reason),
                      onTap: () {
                        setState(() {
                          selectedReason = reason;
                          _updateZonesForSelectedReason();
                        });
                        Navigator.pop(context);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showPopulationSelection() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            "Sélectionnez une population :",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Divider(),
              SizedBox(
                height: MediaQuery.of(context).size.height * 1 / 2,
                width: MediaQuery.of(context).size.width * 1 / 4,
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
        polygons
            .add(arriveZonePolygon(context, arriveeZone)); // Adding the polygon
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
        polygons.add(provenanceZonePolygon(context, zone));
      });
    }
    // Update museums
    await _addMuseumMarkers(selectedPeriod);
  }

  Future<void> _updateZonesForSelectedReason() async {
    // Update arriveeZones
    List<arriveZone> updatedArriveeZones =
        await db.updateArriveZonesForSelectedReason(selectedReason);

    // Update provenanceZones
    List<ProvenanceZone> updatedProvenanceZones =
        await db.updateProvenanceZonesForSelectedReason(selectedReason);

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
        polygons
            .add(arriveZonePolygon(context, arriveeZone)); // Adding the polygon
      });

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
          polygons.add(provenanceZonePolygon(context, zone));
        });
      }
    }
    // Update museums
    await _addMuseumMarkersForSelectedReason(selectedReason);
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
              left: 0,
              right: 0,
              bottom: 24,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 180,
                    height: 80,
                    margin: const EdgeInsets.symmetric(horizontal: 10),
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
                  Container(
                    width: 180,
                    height: 80,
                    margin: const EdgeInsets.symmetric(horizontal: 10),
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
                  Container(
                    width: 180,
                    height: 80,
                    margin: const EdgeInsets.symmetric(horizontal: 10),
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
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
