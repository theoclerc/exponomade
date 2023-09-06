import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../models/provenanceZone_model.dart';
import 'package:flutter/material.dart';

// Polygon of a provenance zone defined by different coordinates.
Polygon provenanceZonePolygon(
  ProvenanceZone provenanceZone,
) {
  return Polygon(
    polygonId: PolygonId(provenanceZone.provenanceNom),
    points: provenanceZone.provenanceZone,
    fillColor: Colors.red.withOpacity(0.3),
    strokeWidth: 1,
    strokeColor: Colors.red,

  );
}
