import 'package:cloud_firestore/cloud_firestore.dart';

// Model for a zone.
class Zone {
  final String nomZone;
  final Map<String, int> chronologieZone;
  final String population;
  final String provenanceNom;
  final List<String> raisons;
  final String raisonsDescription;
  final List<GeoPoint> arriveeZoneList;
  final List<GeoPoint> provenanceZoneList;

  Zone({
    required this.nomZone,
    required this.chronologieZone,
    required this.population,
    required this.provenanceNom,
    required this.raisons,
    required this.raisonsDescription,
    required this.arriveeZoneList,
    required this.provenanceZoneList,
  });

  Map<String, dynamic> toMap() {
    return {
      'nomZone': nomZone,
      'chronologieZone': chronologieZone,
      'population': population,
      'provenanceNom': provenanceNom,
      'raisons': raisons,
      'raisonsDescription': raisonsDescription,
      'arriveeZone': arriveeZoneList,
      'provenanceZone': provenanceZoneList,
    };
  }
}
