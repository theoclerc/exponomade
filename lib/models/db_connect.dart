import 'package:http/http.dart' as http;
import './question_model.dart';
import 'dart:convert';

class DBconnect{
  final url = Uri.parse('https://exponomade-87d35-default-rtdb.europe-west1.firebasedatabase.app/questions.json');

  Future<List<Question>> fetchQuestions() async{
    return http.get(url).then((reponse){
      var data = json.decode(reponse.body);
      List<Question> newQuestions = [];
      data.forEach((key, value) {
        var newQuestion = Question(
          id: key,
          title: value['title'],
          options: Map.castFrom(value['options']),
        );
        newQuestions.add(newQuestion);
      });
      return newQuestions;

    });

  }
}