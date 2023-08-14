import 'package:flutter/material.dart';
import '../appNavigation/home_page.dart';
import '../database/db_connect.dart';
import '../models/question_model.dart';

class QuizServices {
  
  static final DBconnect db = DBconnect();

  static Future<List<Question>> getData() async {
    List<Question> questions = await db.fetchQuestions();
    questions.shuffle();
    return questions.take(3).toList();
  }

  static void checkAnswerAndUpdate({
    required bool value,
    required bool isAlreadySelected,
    required Function setPressed,
    required Function setAlreadySelected,
    required Function incrementScore,
  }) {
    if (isAlreadySelected) {
      return;
    } else {
      if (value == true) {
        incrementScore();
      }
      setPressed();
      setAlreadySelected();
    }
  }

  static void redirectToContact(BuildContext context) {
    Navigator.push(context, MaterialPageRoute(builder: (context) => const HomePage(initialPage: 1)));
  }
}