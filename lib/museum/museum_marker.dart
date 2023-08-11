import 'package:flutter/material.dart';
import '../models/musee_model.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

Future<Marker> createMuseumMarker(BuildContext context, Musee musee) async {
  BitmapDescriptor markerbitmap = await BitmapDescriptor.fromAssetImage(
    const ImageConfiguration(devicePixelRatio: 10),
    "assets/musee.png",
  );

  return Marker(
    markerId: MarkerId(musee.nomMusee), // Use musee.nomMusee
    position: musee.coord, // Use musee.coord
    icon: markerbitmap,
    onTap: () {
      print(musee.nomMusee);
      
      // implement popup for info here
    },
  );
}


