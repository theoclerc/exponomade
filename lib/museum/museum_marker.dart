import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'museum.dart';
import 'museum_info_popup.dart';

Marker createMuseumMarker(BuildContext context, Museum museum) {
  return Marker(
    markerId: MarkerId(museum.name),
    position: museum.location,
    onTap: () {
      print(museum.name);
      
      // implémenter ici le popup pour les infos
      /* showDialog(
        context: context,
        builder: (context) => MuseumInfoPopup(museum: museum),
      ); */
    },
  );
}
