import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../models/question_model.dart';
import '../models/musee_model.dart';
import '../museum/objet.dart';
import '../zones/arriveZone.dart';
import '../zones/provenanceZone.dart';

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

  Future<List<arriveZone>> fetchArriveZones() async {
    try {
      DocumentSnapshot querySnapshot = await _firestore
          .collection('zones')
          .doc('HpaJ7k9BYzlKRKnQA79E')
          .get();
      Map<String, dynamic> data = querySnapshot.data() as Map<String, dynamic>;

      List<dynamic> arriveeZoneData = data['arriveeZone'];

      // Assurer que chaque élément est une GeoPoint, puis transformer en LatLng
      List<LatLng> coordinates = arriveeZoneData.map((e) {
        GeoPoint geoPoint = e as GeoPoint;
        return LatLng(geoPoint.latitude, geoPoint.longitude);
      }).toList();

      print(
          "Arrive Zones coordinates: $coordinates"); // Log pour vérifier les coordonnées
      Map<String, dynamic> chronologieZone = data['chronologieZone'];
      int from = chronologieZone['from'];
      int to = chronologieZone['to'];

      return [
        arriveZone(
          name: data['nomZone'],
          coordinates: coordinates,
          from: from,
          to: to,
        ),
      ];
    } catch (e) {
      print(
          "Une erreur s'est produite lors de la récupération des données des zones d'arrivée: $e");
      return [];
    }
  }

  Future<List<ProvenanceZone>> fetchProvenanceZones() async {
    try {
      DocumentSnapshot querySnapshot = await _firestore
          .collection('zones')
          .doc('HpaJ7k9BYzlKRKnQA79E')
          .get();
      Map<String, dynamic> data = querySnapshot.data() as Map<String, dynamic>;

      List<dynamic> provenanceZoneData = data['provenanceZone'];

      // Assurer que chaque élément est une GeoPoint, puis transformer en LatLng
      List<LatLng> coordinates = provenanceZoneData.map((e) {
        GeoPoint geoPoint = e as GeoPoint;
        return LatLng(geoPoint.latitude, geoPoint.longitude);
      }).toList();

      print(
          "Provenance Zones coordinates: $coordinates"); // Log pour vérifier les coordonnées

      List<String> reasons = List<String>.from(data['raisons']);

      return [
        ProvenanceZone(
          provenanceNom: data['provenanceNom'],
          provenanceZone: coordinates,
          reasons: reasons,
          reasonsDescription: data['raisonsDescription'],
        ),
      ];
    } catch (e) {
      print(
          "Une erreur s'est produite lors de la récupération des données des zones de provenance: $e");
      return [];
    }
  }

  Future<List<String>> fetchPeriods() async {
    try {
      QuerySnapshot snapshot =
          await FirebaseFirestore.instance.collection('zones').get();

      List<String> periods = ["Aucune"];
      for (QueryDocumentSnapshot doc in snapshot.docs) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        if (data['chronologieZone'] != null) {
          periods.add(
              "De ${data['chronologieZone']['from']} à ${data['chronologieZone']['to']}");
        }
      }

      // Sort the periods
      periods.sort((a, b) {
        if (a == "Aucune") return -1; // "Aucune" doit être en premier
        if (b == "Aucune") return 1; // "Aucune" doit être en premier

        int fromA = int.parse(a.split("à")[0].trim().split(" ").last);
        int fromB = int.parse(b.split("à")[0].trim().split(" ").last);
        return fromA.compareTo(fromB);
      });

      return periods;
    } catch (e) {
      print(
          "Une erreur s'est produite lors de la récupération des chronologies : $e");
      return [];
    }
  }

  Future<List<arriveZone>> updateArriveZonesForSelectedPeriod(
      String period) async {
    try {
      QuerySnapshot querySnapshot = await _firestore.collection('zones').get();

      List<arriveZone> filteredZones = [];

      for (QueryDocumentSnapshot doc in querySnapshot.docs) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        if (data['chronologieZone'] != null) {
          int zonePeriodStart = data['chronologieZone']['from'];
          int zonePeriodEnd = data['chronologieZone']['to'];

          // Get the start and end years of the selected period
          int selectedPeriodStart =
              int.parse(period.split("à")[0].trim().split(" ").last);
          int selectedPeriodEnd =
              int.parse(period.split("à")[1].trim().split(" ").last);

          // Filter the zones based on the selected period
          if (selectedPeriodStart >= zonePeriodStart &&
              selectedPeriodEnd <= zonePeriodEnd) {
            List<dynamic> arriveeZoneData = data['arriveeZone'];

            // Assure that each element is a GeoPoint, then transform it into LatLng
            List<LatLng> coordinates = arriveeZoneData.map((e) {
              GeoPoint geoPoint = e as GeoPoint;
              return LatLng(geoPoint.latitude, geoPoint.longitude);
            }).toList();

            arriveZone zone = arriveZone(
              name: data['nomZone'],
              coordinates: coordinates,
              from: zonePeriodStart,
              to: zonePeriodEnd,
            );

            filteredZones.add(zone);
          }
        }
      }

      return filteredZones;
    } catch (e) {
      print(
          "An error occurred while updating arrivee zones for selected period: $e");
      return [];
    }
  }
}
