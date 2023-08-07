import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'museum.dart';

Future<Marker> createMuseumMarker(BuildContext context, Museum museum) async {
  BitmapDescriptor markerbitmap = await BitmapDescriptor.fromAssetImage(
    const ImageConfiguration(devicePixelRatio: 10),
    "assets/musee.png",
  );

  return Marker(
    markerId: MarkerId(museum.name),
    position: museum.location,
    icon: markerbitmap,
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

