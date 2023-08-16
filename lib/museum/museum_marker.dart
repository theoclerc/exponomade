import 'package:flutter/material.dart';
import '../models/musee_model.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

Future<Marker> createMuseumMarker(BuildContext context, Musee musee) async {
  BitmapDescriptor markerbitmap = await BitmapDescriptor.fromAssetImage(
    const ImageConfiguration(devicePixelRatio: 10),
    "assets/musee.png",
  );

  return Marker(
  markerId: MarkerId(musee.nomMusee),
  position: musee.coord,
  icon: markerbitmap,
  onTap: () {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(musee.nomMusee),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Objets: ${musee.objets}"),
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Close'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  },
);

}


