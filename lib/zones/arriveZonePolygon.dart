import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'arriveZone.dart';
import 'package:flutter/material.dart';

Polygon arriveZonePolygon(arriveZone zone) {
  return Polygon(
    polygonId: PolygonId(zone.name),
    points: zone.coordinates,
    fillColor: Colors.blue.withOpacity(0.7),  // Change as needed
    strokeWidth: 1,
    strokeColor: Colors.blue,  // Change as needed
  );
}
