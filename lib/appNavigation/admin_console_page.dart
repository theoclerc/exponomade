
import 'package:flutter/material.dart';
import '../museum/museum_admin_page.dart';
import '../quiz/quiz_admin_page.dart';
import '../zones/zoneAdminPage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'admin_page.dart';
import 'home_page.dart';

class AdminConsolePage extends StatefulWidget {
  const AdminConsolePage({Key? key}) : super(key: key);

  @override
  _AdminConsolePageState createState() => _AdminConsolePageState();
}

class _AdminConsolePageState extends State<AdminConsolePage> {
  List<String> collections = ['Musées', 'Quiz', 'Zones'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Console administrateur'),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
              icon: Icon(Icons.logout),
              onPressed: () async {
                await FirebaseAuth.instance.signOut();
                Navigator.pushReplacement(context,
                    MaterialPageRoute(builder: (context) => const HomePage(initialPage: 0),));
              }),
        ],
      ),
      body: ListView.builder(
        itemCount: collections.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(collections[index]),
            onTap: () {
              if (index == 0) {
                // index for museum
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => MuseumAdminPage()));
                    
              } else if (index == 1) {
                // index for quiz
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => QuizAdminPage()));
                                       
              } else if (index == 2) {
                // index for zones
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => ZoneAdminPage()));
              }
            },
            trailing: Icon(Icons.arrow_forward_ios),
          );
        },
      ),
    );
  }
}
