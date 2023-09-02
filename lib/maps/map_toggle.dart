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
import 'package:flutter/services.dart' show rootBundle;
import 'dart:math';

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
  bool isDialogOpen = false;

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
    rootBundle.loadString('assets/map_style.json').then((string) {
      _mapStyle = string;
    });
  }

  Future<void> _fetchPeriods() async {
    List<String> periods = await db.fetchPeriods();

    setState(() {
      periodOptions = periods;
      selectedPeriod = periodOptions[0];
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

  Future<void> _addMuseumMarkersForSelectedPopulation(
      selectedPopulation) async {
    // Update museums
    List<Musee> museums = await db
        .updateMuseumsAndObjectsForSelectedPopulation(selectedPopulation);

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

    if (selectedReason != "Aucune") {
      arriveeZones =
          await db.updateArriveZonesForSelectedPopulation(selectedPopulation);
      provenanceZones = await db
          .updateProvenanceZonesForSelectedPopulation(selectedPopulation);
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

  void _showPeriodSelection() {
    setState(() {
      isDialogOpen = true; // Dialog is about to open, set this to true
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
                        onTap: () {
                          setState(() {
                            selectedPeriod = period;
                            selectedReason = reasonOptions[0];
                            selectedPopulation = populationOptions[0];
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
        isDialogOpen = false; // Dialog is closed, set this to false
      });
    });
  }

  void _showReasonsSelection() {
    setState(() {
      isDialogOpen = true;
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
                          setState(() {
                            selectedReason = reason;
                            selectedPeriod = periodOptions[0];
                            selectedPopulation = populationOptions[0];
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
        isDialogOpen = false;
      });
    });
  }

  void _showPopulationSelection() {
    setState(() {
      isDialogOpen = true;
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
                          setState(() {
                            selectedPopulation = population;
                            selectedPeriod = periodOptions[0];
                            selectedReason = reasonOptions[0];
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
        isDialogOpen = false;
      });
    });
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

List<arriveZone> arriveeZonesToShow = [];
List<ProvenanceZone> provenanceZonesToShow = [];
int currentPairIndex = 1; // Variable pour suivre la paire actuellement affichée
int totalPairs = 0; // Nombre total de paires de zones
String buttonText = '';

  Future<void> _updateZonesForSelectedReason() async {
    currentPairIndex = 1;
  // Update arriveeZones
  List<arriveZone> updatedArriveeZones =
      await db.updateArriveZonesForSelectedReason(selectedReason);

  // Update provenanceZones
  List<ProvenanceZone> updatedProvenanceZones =
      await db.updateProvenanceZonesForSelectedReason(selectedReason);

  // Mettre à jour le nombre total de paires de zones
  totalPairs = min(updatedArriveeZones.length, updatedProvenanceZones.length);

  // Clear existing polygons and markers
  setState(() {
    polygons.clear();
    markers.clear();
  });

  // Add zones to the lists to show
  arriveeZonesToShow = updatedArriveeZones;
  provenanceZonesToShow = updatedProvenanceZones;

  // Afficher la première paire de zones dès le départ
  _afficherZones();

// Update museums
  await _addMuseumMarkersForSelectedReason(selectedReason);
}

void _afficherZones() {
  markers.clear();
  polygons.clear();

  if (arriveeZonesToShow.isNotEmpty && provenanceZonesToShow.isNotEmpty) {
    // Afficher la paire actuelle de zone d'arrivée et de zone de provenance
    var arriveeZone = arriveeZonesToShow[currentPairIndex - 1]; // Utilisez l'index moins 1
    var provenanceZone = provenanceZonesToShow[currentPairIndex - 1]; // Utilisez l'index moins 1

    // Afficher la zone d'arrivée
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

    // Afficher la zone de provenance
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
      polygons.add(arriveZonePolygon(arriveeZone)); // Adding the polygon for arriveeZone
      polygons.add(provenanceZonePolygon(provenanceZone)); // Adding the polygon for provenanceZone
    });

    // Mettre à jour le texte du bouton avec la paire actuellement affichée
    setState(() {
      buttonText = "Paire ${currentPairIndex.toString()} sur ${totalPairs.toString()}";
    });

    // Incrémenter l'index pour afficher la prochaine paire lors de la prochaine pression sur le bouton
    currentPairIndex++;

    // Si nous avons affiché toutes les paires, réinitialiser l'index pour afficher à nouveau la première paire
    if (currentPairIndex > arriveeZonesToShow.length || currentPairIndex > provenanceZonesToShow.length) {
      currentPairIndex = 1;
    }

    // Appeler la fonction pour ajouter les marqueurs de musées après avoir mis à jour l'index
    _addMuseumMarkersForSelectedReason(selectedReason);
  }
}






  Future<void> _updateZonesForSelectedPopulation() async {
    // Update arriveeZones
    List<arriveZone> updatedArriveeZones =
        await db.updateArriveZonesForSelectedPopulation(selectedPopulation);

    // Update provenanceZones
    List<ProvenanceZone> updatedProvenanceZones =
        await db.updateProvenanceZonesForSelectedPopulation(selectedPopulation);

    // Clear existing polygons and markers
    setState(() {
      polygons.clear();
      markers.clear();
    });

    await _addMuseumMarkersForSelectedPopulation(selectedPopulation);

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
        polygons.add(arriveZonePolygon(
            arriveeZone)); // Adding the polygon/ Adding the polygon
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
          polygons.add(provenanceZonePolygon(zone));
        });
      }
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
    onTap: () {
      _afficherZones(); // Appeler la fonction pour afficher les zones
    },
    child: Center(
      child: Text(
        buttonText, // Utiliser le texte du bouton
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 14,
        ),
      ),
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
