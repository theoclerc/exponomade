import 'package:google_maps_flutter/google_maps_flutter.dart';

class arriveZone {
  final String name;
  final List<LatLng> coordinates;
  final DateTime from;
  final DateTime to;

  arriveZone({
    required this.name,
    required this.coordinates,
    required this.from,
    required this.to,
  });
}
