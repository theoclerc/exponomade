import 'package:flutter/material.dart';
import 'museum.dart';

class MuseumInfoPopup extends StatelessWidget {
  final Museum museum;

  MuseumInfoPopup({required this.museum});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(museum.name),
      content: ListView.builder(
        itemCount: museum.objects.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(museum.objects[index]),
          );
        },
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
  }
}
