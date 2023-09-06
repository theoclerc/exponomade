import 'package:flutter/material.dart';
import '../utils/constants.dart';

// This custom widget represents a styled "Next" button for navigating to the next question.
class NextButton extends StatelessWidget {
  const NextButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 200,
      decoration: BoxDecoration(
        color: neutral,
        borderRadius: BorderRadius.circular(15.0),
      ),
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: const Text(
        'Question suivante',
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 22.0, fontWeight: FontWeight.bold),
      ),
    );
  }
}
