import 'package:flutter/material.dart';

class MuseumAdminPage extends StatefulWidget {
  @override
  _MuseumAdminPageState createState() => _MuseumAdminPageState();
}

class _MuseumAdminPageState extends State<MuseumAdminPage> {
  // For the sake of demonstration, I'll use a static list, but you can fetch it from Firestore.
  List<String> museums = [
    'Musée de Bagnes',
    'Another Museum',
    'And another one'
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Museums Admin')),
      body: ListView.builder(
        itemCount: museums.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(museums[index]),
            trailing: Icon(Icons.edit),
            onTap: () {
              // Handle tap to edit museum details or other admin actions.
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () {
          // Add a new museum.
        },
      ),
    );
  }
}
