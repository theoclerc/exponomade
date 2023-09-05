import 'package:flutter/material.dart';
import '../models/question_model.dart';
import '../database/db_connect.dart';
import '../utils/constants.dart';

class QuizAddPage extends StatefulWidget {
  @override
  _QuizAddPageState createState() => _QuizAddPageState();
}

class _QuizAddPageState extends State<QuizAddPage> {
  final DBconnect dbConnect = DBconnect();
  TextEditingController titleController = TextEditingController();
  Map<String, TextEditingController> optionsControllers = {};
  Map<String, bool> optionsTruthValues = {};

  @override
  void initState() {
    super.initState();
    for (int i = 1; i <= 4; i++) {
      String key = 'Option $i';
      optionsControllers[key] = TextEditingController();
      optionsTruthValues[key] = false; // Initialize all options as false
    }
  }

  void addQuestion() async {
    String questionTitle = titleController.text.trim();

    // Check if question title is empty
    if (questionTitle.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Le titre de la question ne peut pas être vide.'),
        ),
      );
      return;
    }

    // Check if any option is empty
    for (var key in optionsControllers.keys) {
      if (optionsControllers[key]!.text.trim().isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Les options ne peuvent pas être vides.'),
          ),
        );
        return;
      }
    }

    // Check that only one option is true
    int trueCount = optionsTruthValues.values.where((v) => v).length;
    if (trueCount != 1) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Vous devez sélectionner une seule option correcte.'),
        ),
      );
      return;
    }

    // Check for duplicate options
    List<String> optionTexts =
        optionsControllers.values.map((controller) => controller.text).toList();
    if (optionTexts.toSet().length != optionTexts.length) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Les réponses doivent être uniques.'),
        ),
      );
      return;
    }

    Map<String, bool> options = optionsControllers.map(
      (key, controller) =>
          MapEntry(controller.text, optionsTruthValues[key] ?? false),
    );

    Question newQuestion = Question(
      id: '', // Firestore will auto-generate this
      title: questionTitle,
      options: options,
    );

    await dbConnect.addQuestion(newQuestion);
    Navigator.pop(context); // Navigate back to the previous screen
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Ajouter une question'),
        backgroundColor: background,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.all(16.0),
              child: Column(
                children: [
                  TextFormField(
                    controller: titleController,
                    decoration:
                        InputDecoration(labelText: 'Titre de la question'),
                  ),
                  ...optionsControllers.keys
                      .map(
                        (option) => ListTile(
                          title: TextField(
                            controller: optionsControllers[option],
                            decoration: InputDecoration(labelText: 'Option'),
                          ),
                          trailing: Switch(
                            value: optionsTruthValues[option] ?? false,
                            onChanged: (bool value) {
                              setState(() {
                                optionsTruthValues[option] = value;
                              });
                            },
                          ),
                        ),
                      )
                      .toList(),
                ],
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: background,
              ),
              onPressed: addQuestion,
              child: Text('Envoyer'),
            ),
          ],
        ),
      ),
    );
  }
}
