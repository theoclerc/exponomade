import 'package:flutter/material.dart';
import '../constants.dart';

class ResultBox extends StatelessWidget {
  const ResultBox({
    Key? key,
    required this.result,
    required this.questionLength,
    required this.onPressed,
    required this.onContactPressed,
  }) : super(key: key);

  final int result;
  final int questionLength;
  final VoidCallback onPressed;
  final VoidCallback onContactPressed;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: background,
      content: Padding(
        padding: const EdgeInsets.all(70.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Résultat',
              style: TextStyle(color: neutral, fontSize: 22.0),
            ),
            const SizedBox(height: 20.0),
            CircleAvatar(
              radius: 70.0,
              backgroundColor: result == questionLength / 2
                  ? Colors.yellow
                  : result < questionLength / 2
                      ? incorrect
                      : correct,
              child: Text('$result/$questionLength',
                  style: const TextStyle(fontSize: 30.0)),
            ),
            const SizedBox(height: 20.0),
            Text(
              result == questionLength / 2
                  ? 'Tu y es presque!'
                  : result < questionLength / 2
                      ? 'Beurk!'
                      : 'Joli!',
              style: const TextStyle(color: neutral),
            ),
            const SizedBox(height: 25.0),
            ElevatedButton(
              onPressed: onPressed,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                foregroundColor: neutral,
                side: const BorderSide(color: neutral, width: 1),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15.0),
                ),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.refresh, size: 24.0),
                  SizedBox(width: 10.0),
                  Text('Recommencer',
                      style: TextStyle(fontSize: 22.0, letterSpacing: 1.0)),
                ],
              ),
            ),
            const SizedBox(height: 20.0),
            ElevatedButton(
              onPressed: onContactPressed,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                foregroundColor: neutral,
                side: const BorderSide(color: neutral, width: 1),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15.0),
                ),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.mail_outline, size: 24.0),
                  SizedBox(width: 10.0),
                  Text('Nous contacter',
                      style: TextStyle(fontSize: 22.0, letterSpacing: 1.0)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
