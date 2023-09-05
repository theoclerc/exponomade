import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'objet_model.dart';

class Musee {
  final String id;
  final String nomMusee;
  final LatLng coord;
  final List<Objet> objets; // Use List<Objet> here

  Musee(
      {required this.id,
      required this.nomMusee,
      required this.coord,
      required this.objets});

  @override
  String toString() {
    return 'Musee(id: $id, nomMusee: $nomMusee, coord: $coord, objets: $objets)';
  }
}
