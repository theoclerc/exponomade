import '../models/question_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/musee_model.dart';
import '../museum/objet.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class DBconnect {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<Question>> fetchQuestions() async {
    QuerySnapshot querySnapshot = await _firestore.collection('quiz').get();
    List<Question> newQuestions = [];

    for (var doc in querySnapshot.docs) {
      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      var newQuestion = Question(
        id: doc.id,
        title: data['title'] as String,
        options: Map<String, bool>.from(data['options'] as Map),
      );
      newQuestions.add(newQuestion);
    }

    return newQuestions;
  }

  Future<List<Musee>> fetchMusees() async {
    try {
      QuerySnapshot querySnapshot = await _firestore.collection('musees').get();
      List<Musee> musees = [];

      for (var doc in querySnapshot.docs) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

        try {
          GeoPoint coord = data['coordonneesMusee'];
          var coordLatLng = LatLng(coord.latitude, coord.longitude);

          List<Map<String, dynamic>> objetsData =
              List<Map<String, dynamic>>.from(data['objets'] as List);
          List<Objet> objets = objetsData.map((objetData) {
            // todo : changer la chronologie en num plutot que String une fois que la chronologie dans la DB sera remplie
            Map<String, String> chronologie = {
              'from': objetData['chronologie']['from'] as String,
              'to': objetData['chronologie']['to'] as String,
            };
            return Objet(
              chronologie: chronologie,
              descriptionObjet: objetData['descriptionObjet'] as String,
              image: objetData['image'] as String,
              nomObjet: objetData['nomObjet'] as String,
              population: objetData['population'] as String,
              raisons: List<String>.from(objetData['raisons'] as List),
            );
          }).toList();

          var musee = Musee(
            id: doc.id,
            nomMusee: data['nomMusee'] as String,
            coord: coordLatLng,
            objets: objets,
          );

          musees.add(musee);
        } catch (e) {
          print(
              "An error occurred while processing document with ID: ${doc.id}");
          print("Error details: $e");
        }
      }

      return musees;
    } catch (e) {
      print("An error occurred while fetching data from Firestore: $e");
      return []; // Return an empty list if an error occurs
    }
  }
}
