import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'museum_marker.dart';
import '../models/arriveZone_model.dart';
import '../maps/arriveZone_polygon.dart';
import '../models/provenanceZone_model.dart';
import '../maps/provenanceZone_polygon.dart';
import '../models/musee_model.dart';
import '../database/db_connect.dart';
import 'arriveZone_info_popup.dart';
import 'provenanceZone_info_popup.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:math';

// This class manages the Google Maps, displaying various elements and making it interactive.
class MapToggle extends StatefulWidget {
  const MapToggle({Key? key}) : super(key: key);

  @override
  _MapToggleState createState() => _MapToggleState();
}

class _MapToggleState extends State<MapToggle> {
  late GoogleMapController mapController;
  late String _mapStyle;

  var db = DBconnect();

  Set<Marker> markers = {};
  Set<Polygon> polygons = {};
  List<arriveZone> arriveeZonesToShow = [];
  List<ProvenanceZone> provenanceZonesToShow = [];

  // Default map view.
  final LatLng _center = const LatLng(46.229352, 7.362049);
  // Boolean for background map management.
  bool isDialogOpen = false; 
  // Number of zone pairs to be displayed (arrival zone + provenance zone).
  int totalPairs = 0;
  // Current pair used.
  int currentPairIndex = 0;

  // Period options.
  List<String> periodOptions = [];
  String selectedPeriod = '';
  // Reasons options.
  List<String> reasonOptions = [];
  String selectedReason = '';
  // Population options.
  List<String> populationOptions = [];
  String selectedPopulation = '';

  @override
  void initState() {
    super.initState();
    _fetchPeriods();
    _fetchReasons();
    _fetchPopulations();
    _createMarkersAndPolygons();
    rootBundle.loadString('assets/map_style.json').then((string) {
      _mapStyle = string;
    });
  }

  // Fetch available periods and set the initial selection.
  Future<void> _fetchPeriods() async {
    List<String> periods = await db.fetchPeriods();

    setState(() {
      periodOptions = periods;
      selectedPeriod = periodOptions[0];
    });
  }

  // Fetch available reasons and set the initial selection.
  Future<void> _fetchReasons() async {
    List<String> reasons = await db.fetchReasons();

    setState(() {
      reasonOptions = reasons;
      selectedReason = reasonOptions[0];
    });
  }

  // Fetch available populations and set the initial selection.
  Future<void> _fetchPopulations() async {
    List<String> populations = await db.fetchPopulations();

    setState(() {
      populationOptions = populations;
      selectedPopulation = populationOptions[0];
    });
  }

  // Callback when the Google Map is created.
  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
    controller.setMapStyle(_mapStyle);
  }

  // Calculate the center of a polygon using its coordinates.
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

  // Add museum markers based on the selected period.
  Future<void> _addMuseumMarkers(selectedPeriod) async {
    // Update museums.
    List<Musee> museums =
        await db.updateMuseumsAndObjectsForSelectedPeriod(selectedPeriod);

    for (var museum in museums) {
      Marker marker = await createMuseumMarker(context, museum);
      setState(() {
        markers.add(marker);
      });
    }
  }

  // Add museum markers based on the selected reason.
  Future<void> _addMuseumMarkersForSelectedReason(selectedReason) async {
    // Update museums.
    List<Musee> museums =
        await db.updateMuseumsAndObjectsForSelectedReason(selectedReason);

    for (var museum in museums) {
      Marker marker = await createMuseumMarker(context, museum);
      setState(() {
        markers.add(marker);
      });
    }
  }

  // Add museum markers based on the selected population.
  Future<void> _addMuseumMarkersForSelectedPopulation(
      selectedPopulation) async {
    // Update museums.
    List<Musee> museums = await db
        .updateMuseumsAndObjectsForSelectedPopulation(selectedPopulation);

    for (var museum in museums) {
      Marker marker = await createMuseumMarker(context, museum);
      setState(() {
        markers.add(marker);
      });
    }
  }

  // Create markers and polygons for arrival and provenance zones.
  Future<void> _createMarkersAndPolygons() async {
    List<arriveZone> arriveeZones = await db.fetchArriveZones();
    List<ProvenanceZone> provenanceZones = await db.fetchProvenanceZones();
    await _addMuseumMarkers(selectedPeriod);

    // When "Aucune" is selected, no zone appears.
    if (selectedPeriod != "Aucune") {
      arriveeZones =
          await db.updateArriveZonesForSelectedPeriod(selectedPeriod);
      provenanceZones =
          await db.updateProvenanceZonesForSelectedPeriod(selectedPeriod);
    }
    // When "Aucune" is selected, no zone appears.
    if (selectedReason != "Aucune") {
      arriveeZones =
          await db.updateArriveZonesForSelectedReason(selectedReason);
      provenanceZones =
          await db.updateProvenanceZonesForSelectedReason(selectedReason);
    }
    // When "Aucune" is selected, no zone appears.
    if (selectedReason != "Aucune") {
      arriveeZones =
          await db.updateArriveZonesForSelectedPopulation(selectedPopulation);
      provenanceZones = await db
          .updateProvenanceZonesForSelectedPopulation(selectedPopulation);
    }

    // Create markers for each arrival zone.
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

    // Create markers for each provenance zone.
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

  // Show a dialog to select a period (filter).
  void _showPeriodSelection() {
    setState(() {
      isDialogOpen = true; // Dialog is about to open, set this to true.
    });
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
                        // Set the selected period and reset other filters.
                        onTap: () {
                          setState(() {
                            selectedPeriod = period;
                            selectedReason = reasonOptions[0];
                            selectedPopulation = populationOptions[0];
                            // All zones are displayed, set to 0.
                            totalPairs = 0;
                            // Zone update according to filter.
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
    ).then((value) {
      setState(() {
        isDialogOpen = false; // Dialog is closed, set this to false.
      });
    });
  }

  // Show a dialog to select a reason.
  void _showReasonsSelection() {
    setState(() {
      isDialogOpen = true; // Dialog is about to open, set this to true.
    });
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
                height: MediaQuery.of(context).size.height * 2 / 3,
                width: MediaQuery.of(context).size.width * 1 / 4,
                child: SingleChildScrollView(
                  child: Column(
                    children: List.generate(reasonOptions.length, (index) {
                      final reason = reasonOptions[index];
                      return ListTile(
                        title: Text(reason),
                        onTap: () {
                          // Set the selected reason and reset other filters.
                          setState(() {
                            selectedReason = reason;
                            selectedPeriod = periodOptions[0];
                            selectedPopulation = populationOptions[0];
                           // Zone update according to filter.
                            _updateZonesForSelectedReason();
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
    ).then((value) {
      setState(() {
        isDialogOpen = false; // Dialog is closed, set this to false.
      });
    });
  }

  // Show a dialog to select a population.
  void _showPopulationSelection() {
    setState(() {
      isDialogOpen = true; // Dialog is about to open, set this to true.
    });
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            "Sélectionnez un type de population :",
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
                    children: List.generate(populationOptions.length, (index) {
                      final population = populationOptions[index];
                      return ListTile(
                        title: Text(population),
                        onTap: () {
                          // Set the selected reason and reset other filters.
                          setState(() {
                            selectedPopulation = population;
                            selectedPeriod = periodOptions[0];
                            selectedReason = reasonOptions[0];
                            // Zone update according to filter.
                            _updateZonesForSelectedPopulation();
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
    ).then((value) {
      setState(() {
        isDialogOpen = false; // Dialog is closed, set this to false.
      });
    });
  }


  // Update zones when a new period is selected.
  Future<void> _updateZonesForSelectedPeriod() async {
    // Update arriveeZones.
    List<arriveZone> updatedArriveeZones =
        await db.updateArriveZonesForSelectedPeriod(selectedPeriod);

    // Update provenanceZones.
    List<ProvenanceZone> updatedProvenanceZones =
        await db.updateProvenanceZonesForSelectedPeriod(selectedPeriod);

    // Clear existing polygons and markers.
    setState(() {
      polygons.clear();
      markers.clear();
    });

    // Add markers and polygons for updated zones (arrival zone).
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
        polygons.add(arriveZonePolygon(arriveeZone)); // Adding the polygon.
      });
    }

    // Add markers and polygons for updated zones (provenance zone).
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

    // Update museums.
    await _addMuseumMarkers(selectedPeriod);
  }

  // Update zones when a new reason is selected.
  Future<void> _updateZonesForSelectedReason() async {
    // Set to 0.
    currentPairIndex = 0;

    // Update arriveeZones.
    List<arriveZone> updatedArriveeZones =
        await db.updateArriveZonesForSelectedReason(selectedReason);

    // Update provenanceZones.
    List<ProvenanceZone> updatedProvenanceZones =
        await db.updateProvenanceZonesForSelectedReason(selectedReason);

    // Update totalPairs.
    totalPairs = min(updatedArriveeZones.length, updatedProvenanceZones.length);

    // Clear existing polygons and markers.
    setState(() {
      polygons.clear();
      markers.clear();
    });

    // Add zones to the lists to show.
    arriveeZonesToShow = updatedArriveeZones;
    provenanceZonesToShow = updatedProvenanceZones;

    // Display first zones (pair of zones displayed according to index).
    if (totalPairs > 0) {
      _displayPair(currentPairIndex);
    }

    // Update museums.
    await _addMuseumMarkersForSelectedReason(selectedReason);
  }

  // Update zones when a new population is selected.
  Future<void> _updateZonesForSelectedPopulation() async {
    currentPairIndex = 0;

    // Update arriveeZones.
    List<arriveZone> updatedArriveeZones =
        await db.updateArriveZonesForSelectedPopulation(selectedPopulation);

    // Update provenanceZones.
    List<ProvenanceZone> updatedProvenanceZones =
        await db.updateProvenanceZonesForSelectedPopulation(selectedPopulation);

    // Update the total number of pairs of zones to display.
    totalPairs = min(updatedArriveeZones.length, updatedProvenanceZones.length);

    // Clear existing polygons and markers.
    setState(() {
      polygons.clear();
      markers.clear();
    });

    // Add zones to the lists to show.
    arriveeZonesToShow = updatedArriveeZones;
    provenanceZonesToShow = updatedProvenanceZones;

    // Display first zones (pair of zones displayed according to index).
    if (totalPairs > 0) {
      _displayPair(currentPairIndex);
    }

    // Update museums.
    await _addMuseumMarkersForSelectedPopulation(selectedPopulation);
  }

  // Display a pair of zones (arrival + provenance zone).
  Future<void> _displayPair(int pairIndex) async {
    polygons.clear();
    markers.clear();

    if (arriveeZonesToShow.isNotEmpty && provenanceZonesToShow.isNotEmpty) {
      // Check if the pair index is valid.
      if (pairIndex >= 0 && pairIndex < totalPairs) {
        var arriveeZone = arriveeZonesToShow[pairIndex];
        var provenanceZone = provenanceZonesToShow[pairIndex];

        // Display the arrival zone.
        Marker arriveeMarker = Marker(
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

        // Display the provenance zone.
        Marker provenanceMarker = Marker(
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
          markers.add(arriveeMarker);
          markers.add(provenanceMarker);
          polygons.add(arriveZonePolygon(arriveeZone));
          polygons.add(provenanceZonePolygon(provenanceZone));
        });
      }
    }

    // Now, determine which museum update should be performed.
    if (selectedReason != "Aucune") {
      _addMuseumMarkersForSelectedReason(selectedReason);
    } else if (selectedPopulation != "Aucune") {
      _addMuseumMarkersForSelectedPopulation(selectedPopulation);
    }
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
              // Block the map if the filters are open.
              scrollGesturesEnabled: !isDialogOpen,
              zoomGesturesEnabled: !isDialogOpen,
              tiltGesturesEnabled: !isDialogOpen,
              rotateGesturesEnabled: !isDialogOpen,
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
                    // Display the period filter.
                    child: GestureDetector(
                      onTap: _showPeriodSelection,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.history),
                          const SizedBox(width: 8),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "Période choisie :",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                selectedPeriod,
                                style: const TextStyle(
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
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
                    // Display the reason filter.
                    child: GestureDetector(
                      onTap: _showReasonsSelection,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.lightbulb_outline),
                          const SizedBox(width: 8),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "Raison choisie :",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                selectedReason,
                                style: const TextStyle(
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
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
                    // Display the population filter.
                    child: GestureDetector(
                      onTap: _showPopulationSelection,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.people),
                          const SizedBox(width: 8),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "Population choisie :",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                selectedPopulation,
                                style: const TextStyle(
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),               
                ],
              ),
            ),
             Positioned(
              bottom: 120,
              left: 450,
              right: 450,
              child: Visibility(
                visible: totalPairs > 0,
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.orange,
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
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          onPressed: () {
                            
                            if (currentPairIndex > 0) {
                              currentPairIndex--;
                              _displayPair(currentPairIndex);
                            }
                          },
                          icon: Icon(Icons.navigate_before, color: Colors.white),
                        ),
                        // Display a button to scroll through zone pairs.
                        Text(
                          "Zone ${currentPairIndex + 1} sur $totalPairs",
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: Colors.white,
                          ),
                        ),
                        IconButton(
                          onPressed: () {
                            if (currentPairIndex < totalPairs - 1) {
                              currentPairIndex++;
                              _displayPair(currentPairIndex);
                            }
                          },
                          icon: Icon(Icons.navigate_next, color: Colors.white),
                        ),
                      ],
                    ),
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
