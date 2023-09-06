import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../models/arriveZone_model.dart';
import 'package:flutter/material.dart';

// Polygon of a final zone defined by different coordinates.
Polygon arriveZonePolygon(
  arriveZone zone,
) {
  return Polygon(
    polygonId: PolygonId(zone.name),
    points: zone.coordinates,
    fillColor: Colors.blue.withOpacity(0.7),
    strokeWidth: 1,
    strokeColor: Colors.blue,

  );
}
