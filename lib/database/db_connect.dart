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

  Future<List<arriveZone>> fetchArriveZones() async {
    try {
      DocumentSnapshot querySnapshot = await _firestore
          .collection('zones')
          .doc()
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
          .doc()
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

  Future<List<String>> fetchReasons() async {
    try {
      QuerySnapshot snapshot =
          await FirebaseFirestore.instance.collection('zones').get();

      List<String> reasons = ["Aucune"];
      Set<String> uniqueReasons =
          {}; // Utilisez un ensemble pour stocker les raisons uniques

      for (QueryDocumentSnapshot doc in snapshot.docs) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        if (data['raisons'] != null) {
          List<dynamic> reasonsData = data['raisons'];
          for (dynamic reason in reasonsData) {
            uniqueReasons.add("$reason"); // Ajoutez chaque raison à l'ensemble
          }
        }
      }

      List<String> reasonsToAdd = uniqueReasons.toList();

      //Sort
      reasonsToAdd.sort();
      reasons.insertAll(1, reasonsToAdd);

      return reasons;
    } catch (e) {
      print(
          "Une erreur s'est produite lors de la récupération des raisons : $e");
      return [];
    }
  }

  Future<List<String>> fetchPopulations() async {
    try {
      QuerySnapshot snapshot =
          await FirebaseFirestore.instance.collection('zones').get();

      List<String> populations = ["Aucune"];
      Set<String> uniquePopulations =
          {}; // Utilisez un ensemble pour stocker les populations uniques

      for (QueryDocumentSnapshot doc in snapshot.docs) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        if (data['population'] != null &&
            data['population'].trim().isNotEmpty) {
          String populationData = data['population'];
          uniquePopulations
              .add(populationData); // Ajoutez chaque population à l'ensemble
        }
      }

      List<String> populationsToAdd = uniquePopulations.toList();

      //Sort
      populationsToAdd.sort();
      populations.insertAll(1, populationsToAdd);

      return populations;
    } catch (e) {
      print(
          "Une erreur s'est produite lors de la récupération des populations : $e");
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
          if (selectedPeriodStart == zonePeriodStart &&
              selectedPeriodEnd == zonePeriodEnd) {
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

  Future<List<ProvenanceZone>> updateProvenanceZonesForSelectedPeriod(
      String period) async {
    try {
      QuerySnapshot snapshot = await _firestore.collection('zones').get();

      List<ProvenanceZone> zones = [];

      for (QueryDocumentSnapshot doc in snapshot.docs) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        if (data['chronologieZone'] != null) {
          int from = data['chronologieZone']['from'];
          int to = data['chronologieZone']['to'];

          // Get the start and end years of the selected period
          int selectedPeriodStart =
              int.parse(period.split("à")[0].trim().split(" ").last);
          int selectedPeriodEnd =
              int.parse(period.split("à")[1].trim().split(" ").last);

          if (selectedPeriodStart == from && selectedPeriodEnd == to) {
            List<dynamic> provenanceZoneData = data['provenanceZone'];

            // Assure that each element is a GeoPoint, then transform it into LatLng
            List<LatLng> coordinates = provenanceZoneData.map((e) {
              GeoPoint geoPoint = e as GeoPoint;
              return LatLng(geoPoint.latitude, geoPoint.longitude);
            }).toList();

            List<String> reasons = List<String>.from(data['raisons']);

            ProvenanceZone zone = ProvenanceZone(
              provenanceNom: data['provenanceNom'],
              provenanceZone: coordinates,
              reasons: reasons,
              reasonsDescription: data['raisonsDescription'],
            );

            zones.add(zone);
          }
        }
      }

      return zones;
    } catch (e) {
      print("An error occurred while fetching provenance zone data: $e");
      return [];
    }
  }

  Future<List<Musee>> updateMuseumsAndObjectsForSelectedPeriod(
      String period) async {
    List<Musee> updatedMuseums = [];

    // Fetch all museums and objects
    try {
      QuerySnapshot querySnapshot = await _firestore.collection('musees').get();
      List<Musee> museums = [];

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

          museums.add(musee);
        } catch (e) {
          print(
              "An error occurred while processing document with ID: ${doc.id}");
          print("Error details: $e");
        }
      }

      if (period == "Aucune") {
        // If selected period is "Aucune," return all museums and objects
        return museums;
      }

      // Filter museums and their objects based on the selected period
      for (var museum in museums) {
        List<Objet> filteredObjects = [];
        for (var objet in museum.objets) {
          String? from = objet.chronologie['from'];
          String? to = objet.chronologie['to'];
          int selectedPeriodStart =
              int.parse(period.split("à")[0].trim().split(" ").last);
          int selectedPeriodEnd =
              int.parse(period.split("à")[1].trim().split(" ").last);
          int objetFrom = int.parse(from!);
          int objetTo = int.parse(to!);
          bool isYearInPeriod =
              selectedPeriodStart == objetFrom && selectedPeriodEnd == objetTo;

          if (isYearInPeriod) {
            filteredObjects.add(objet);
          }
        }

        if (filteredObjects.isNotEmpty) {
          Musee updatedMuseum = Musee(
            id: museum.id,
            nomMusee: museum.nomMusee,
            coord: museum.coord,
            objets: filteredObjects,
          );
          updatedMuseums.add(updatedMuseum);
        }
      }
    } catch (e) {
      print("An error occurred while fetching data from Firestore: $e");
    }
    return updatedMuseums;
  }

  Future<List<arriveZone>> updateArriveZonesForSelectedReason(
    String reason) async {
  try {
    QuerySnapshot querySnapshot = await _firestore.collection('zones').get();

    List<arriveZone> filteredZones = [];

    for (QueryDocumentSnapshot doc in querySnapshot.docs) {
      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      if (data['raisons'] != null) {
        // Check if the selected reason is in the list of reasons for this zone
        List<String> reasons = List<String>.from(data['raisons']);
        if (reasons.contains(reason)) {
          int zonePeriodStart = data['chronologieZone']['from'];
          int zonePeriodEnd = data['chronologieZone']['to'];

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
        "An error occurred while updating arrivee zones for selected reason: $e");
    return [];
  }
}

  Future<List<ProvenanceZone>> updateProvenanceZonesForSelectedReason(
      String reason) async {
    try {
      QuerySnapshot snapshot = await _firestore.collection('zones').get();

      List<ProvenanceZone> zones = [];

      for (QueryDocumentSnapshot doc in snapshot.docs) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

        if (data['raisons'] != null) {
          List<String> reasons = List<String>.from(data['raisons']);
          if (reasons.contains(reason)) {
            List<dynamic> provenanceZoneData = data['provenanceZone'];

            // Assure that each element is a GeoPoint, then transform it into LatLng
            List<LatLng> coordinates = provenanceZoneData.map((e) {
              GeoPoint geoPoint = e as GeoPoint;
              return LatLng(geoPoint.latitude, geoPoint.longitude);
            }).toList();

            ProvenanceZone zone = ProvenanceZone(
              provenanceNom: data['provenanceNom'],
              provenanceZone: coordinates,
              reasons: reasons,
              reasonsDescription: data['raisonsDescription'],
            );

            zones.add(zone);
          }
        }
      }

      return zones;
    } catch (e) {
      print("An error occurred while updating provenance zone data: $e");
      return [];
    }
  }

  Future<List<Musee>> updateMuseumsAndObjectsForSelectedReason(
      String reason) async {
    List<Musee> updatedMuseums = [];

    // Fetch all museums and objects
    try {
      QuerySnapshot querySnapshot = await _firestore.collection('musees').get();
      List<Musee> museums = [];

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

          museums.add(musee);
        } catch (e) {
          print(
              "An error occurred while processing document with ID: ${doc.id}");
          print("Error details: $e");
        }
      }

      if (reason == "Aucune") {
        // If selected reason is "Aucune," return all museums
        return museums;
      }

      // Filter museums and their objects based on the selected reason
      for (var museum in museums) {
        List<Objet> filteredObjects = [];
        for (var objet in museum.objets) {
          if (objet.raisons.contains(reason)) {
            filteredObjects.add(objet);
          }
        }

        if (filteredObjects.isNotEmpty) {
          Musee updatedMuseum = Musee(
            id: museum.id,
            nomMusee: museum.nomMusee,
            coord: museum.coord,
            objets: filteredObjects,
          );
          updatedMuseums.add(updatedMuseum);
        }
      }
    } catch (e) {
      print("An error occurred while fetching data from Firestore: $e");
    }
    return updatedMuseums;
  }

  Future<List<arriveZone>> updateArriveZonesForSelectedPopulation(
      String population) async {
    try {
      QuerySnapshot snapshot = await _firestore.collection('zones').get();

      List<arriveZone> zones = [];

      for (QueryDocumentSnapshot doc in snapshot.docs) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

        // Check if the zone's population matches the selected population
        if (data['population'] == population) {

          int zonePeriodStart = data['chronologieZone']['from'];
          int zonePeriodEnd = data['chronologieZone']['to'];

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

          zones.add(zone);
        }
      }

      return zones;
    } catch (e) {
      print("An error occurred while fetching provenance zone data for selected population: $e");
      return [];
    }
  }

  Future<List<ProvenanceZone>> updateProvenanceZonesForSelectedPopulation(
      String population) async {
    try {
      QuerySnapshot snapshot = await _firestore.collection('zones').get();

      List<ProvenanceZone> zones = [];

      for (QueryDocumentSnapshot doc in snapshot.docs) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

        // Check if the zone's population matches the selected population
        if (data['population'] == population) {

          List<dynamic> provenanceZoneData = data['provenanceZone'];

          // Assure that each element is a GeoPoint, then transform it into LatLng
          List<LatLng> coordinates = provenanceZoneData.map((e) {
            GeoPoint geoPoint = e as GeoPoint;
            return LatLng(geoPoint.latitude, geoPoint.longitude);
          }).toList();

          List<String> reasons = List<String>.from(data['raisons']);

          ProvenanceZone zone = ProvenanceZone(
            provenanceNom: data['provenanceNom'],
            provenanceZone: coordinates,
            reasons: reasons,
            reasonsDescription: data['raisonsDescription'],
          );

          zones.add(zone);
        }
      }

      return zones;
    } catch (e) {
      print("An error occurred while fetching provenance zone data for selected population: $e");
      return [];
    }
  }

  Future<List<Musee>> updateMuseumsAndObjectsForSelectedPopulation(
      String population) async {
    List<Musee> updatedMuseums = [];

    // Fetch all museums and objects
    try {
      QuerySnapshot querySnapshot = await _firestore.collection('musees').get();
      List<Musee> museums = [];

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

          museums.add(musee);
        } catch (e) {
          print(
              "An error occurred while processing document with ID: ${doc.id}");
          print("Error details: $e");
        }
      }

      if (population == "Aucune") {
        // If selected reason is "Aucune," return all museums
        return museums;
      }

      // Filter museums and their objects based on the selected reason
      for (var museum in museums) {
        List<Objet> filteredObjects = [];
        for (var objet in museum.objets) {
          if (objet.population.contains(population)) {
            filteredObjects.add(objet);
          }
        }

        if (filteredObjects.isNotEmpty) {
          Musee updatedMuseum = Musee(
            id: museum.id,
            nomMusee: museum.nomMusee,
            coord: museum.coord,
            objets: filteredObjects,
          );
          updatedMuseums.add(updatedMuseum);
        }
      }
    } catch (e) {
      print("An error occurred while fetching data from Firestore: $e");
    }
    return updatedMuseums;
  }

  
}
