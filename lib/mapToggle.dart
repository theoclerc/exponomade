import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class mapToggle extends StatefulWidget{

@override
_MapToggleState createState() => _MapToggleState();
  
  const mapToggle({super.key});
  
}

class _MapToggleState extends State<mapToggle> {
@override
  Widget build(BuildContext context){

    var marker = <Marker>[];

    marker = [
      //Châteaux de Sion
      Marker(
        point: const LatLng(46.2352107258,7.36683686598),
        builder: (ctx) => const Icon(Icons.pin_drop), 
      ),
      //Aéroport Sion
      Marker(
        point: const LatLng(46.219277,7.329936),
        builder: (ctx) => const Icon(Icons.pin_drop), 
      ),
    ];

    return Scaffold(
      body: Center(
        child: Container(
          child: Column(
            children: [
              Flexible(
                child: FlutterMap(
                  options: 
                    MapOptions(center: const LatLng(46.229352,7.362049),zoom: 8),
                  children: [
                    TileLayer(
                    urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'com.example.app',
                    ),
                    MarkerLayer(
                      markers: marker,
                    )
                  ],
                ),
              ),
            ],
          ), 
        ),
      ),
    );
  }

}