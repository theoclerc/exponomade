import 'package:exponomade/zones/editZonePage.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ZoneAdminPage extends StatefulWidget {
  @override
  _ZoneAdminPageState createState() => _ZoneAdminPageState();
}

class _ZoneAdminPageState extends State<ZoneAdminPage> {
  final _firestore = FirebaseFirestore.instance;

  Future<List<DocumentSnapshot>> fetchZones() async {
    try {
      QuerySnapshot zonesSnapshot = await _firestore.collection('zones').get();
      return zonesSnapshot.docs;
    } catch (e) {
      print("Error fetching zones: $e");
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Zones Admin')),
      body: FutureBuilder<List<DocumentSnapshot>>(
        future: fetchZones(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error fetching data'));
          } else if (snapshot.data == null || snapshot.data!.isEmpty) {
            return Center(child: Text('No zones found'));
          } else {
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(snapshot.data![index]['nomZone']),
                  trailing: Icon(Icons.edit),
                  onTap: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => EditZonePage(
                          initialData: snapshot.data![index].data()
                              as Map<String, dynamic>,
                          docId: snapshot.data![index].id,
                          onSave: () {
                            setState(() {}); // This will refresh your widget
                          },
                        ),
                      ),
                    );
                  },
                );
              },
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () {
          // todo ajouter le code pour créer une nouvelle zone.
        },
      ),
    );
  }
}
