import 'package:flutter/material.dart';
import '../appNavigation/home_page.dart';
import '../database/db_connect.dart';
import '../models/question_model.dart';
import '../widgets/result_box.dart';

class QuizServices {

  static final DBconnect db = DBconnect();

  static Future<List<Question>> getData() async {
    List<Question> questions = await db.fetchQuestions();
    questions.shuffle();
    return questions.take(10).toList();
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

  static void nextQuestion({
    required BuildContext context,
    required int index,
    required int score,
    required bool isPressed,
    required List<Question> extractedData,
    required Function updateState,
  }) {
    if (index == extractedData.length - 1) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => ResultBox(
          result: score,
          questionLength: extractedData.length,
          onPressed: () => startOver(context),
          onContactPressed: () => redirectToContact(context, score),
        ),
      );
    } else {
      if (isPressed) {
        updateState(index + 1, score, false, false);
      } else {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Une réponse est requise'),
            behavior: SnackBarBehavior.floating,
            margin: EdgeInsets.only(bottom: 80.0, left: 20.0, right: 20.0),
          ),
        );
      }
    }
  }

  static void startOver(BuildContext context) {
    Navigator.push(context, MaterialPageRoute(builder: (context) => const HomePage(initialPage: 2)));
  }


  static void redirectToContact(BuildContext context, int score) {
    Navigator.push(context, MaterialPageRoute(builder: (context) => HomePage(initialPage: 1, score: score)));
  }

}
