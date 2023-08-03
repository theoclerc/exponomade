import 'package:google_maps_flutter/google_maps_flutter.dart';

class Museum {
  final String name;
  final LatLng location;
  final List<String> objects;

  Museum({
    required this.name,
    required this.location,
    required this.objects,
  });
}
