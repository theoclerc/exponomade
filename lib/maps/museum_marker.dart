import 'package:flutter/material.dart';
import '../models/musee_model.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'museum_info_popup.dart';

// This function creates a custom marker for a museum on the Google Maps widget.
Future<Marker> createMuseumMarker(BuildContext context, Musee musee) async {
  // Load a custom bitmap image to be used as the marker icon.
  BitmapDescriptor markerbitmap = await BitmapDescriptor.fromAssetImage(
    const ImageConfiguration(devicePixelRatio: 10),
    // Path to stored museum icon
    "assets/musee.png", 
  );

  // Create a Marker object with the museum's information.
  return Marker(
    markerId: MarkerId(musee.nomMusee),
    position: musee.coord,
    icon: markerbitmap,
    onTap: () {
      showDialog(
        context: context,
        builder: (BuildContext context) {
           // Display the MuseumInfoPopup widget.
          return MuseumInfoPopup(musee: musee);
        },
      );
    },
  );
}
