import 'package:google_maps_flutter/google_maps_flutter.dart';

// Model for a provenance zone.
class ProvenanceZone {
  final String provenanceNom;
  final List<LatLng> provenanceZone;
  final List<String> reasons;
  final String reasonsDescription;

  ProvenanceZone({
    required this.provenanceNom,
    required this.provenanceZone,
    required this.reasons,
    required this.reasonsDescription,
  });
}