import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'provenanceZone.dart';
import 'provenanceZoneInfoPopup.dart';
import 'package:flutter/material.dart';

Polygon provenanceZonePolygon(
  BuildContext context,
  ProvenanceZone provenanceZone,
) {
  return Polygon(
      polygonId: PolygonId(provenanceZone.provenanceNom),
      points: provenanceZone.provenanceZone,
      fillColor: Colors.red.withOpacity(0.3), // Change as needed
      strokeWidth: 1,
      strokeColor: Colors.red, // Change as needed
      consumeTapEvents: true,
      onTap: () {
        showDialog(
          context: context,
          builder: (context) => provenanceZoneInfoPopup(zone: provenanceZone),
        );
      });
}
