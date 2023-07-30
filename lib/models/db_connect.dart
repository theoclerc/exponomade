import './question_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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
}


