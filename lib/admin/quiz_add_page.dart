import 'package:flutter/material.dart';
import '../models/question_model.dart';
import '../database/db_connect.dart';
import '../utils/constants.dart';

class QuizAddPage extends StatefulWidget {
  @override
  _QuizAddPageState createState() => _QuizAddPageState();
}

class _QuizAddPageState extends State<QuizAddPage> {
  // Instance of DBconnect for database operations.
  final DBconnect dbConnect = DBconnect();

  // Controller for the question title input field.
  TextEditingController titleController = TextEditingController();

  // Controllers for options input fields.
  Map<String, TextEditingController> optionsControllers = {};

  // Map to track the truth values of options (true for correct options, false for others).
  Map<String, bool> optionsTruthValues = {};

  @override
  void initState() {
    super.initState();
    // Initialize option controllers and set all options as false by default.
    for (int i = 1; i <= 4; i++) {
      String key = 'Option $i';
      optionsControllers[key] = TextEditingController();
      optionsTruthValues[key] = false;
    }
  }

  // Function to add a new question.
  void addQuestion() async {
    // Get the trimmed question title.
    String questionTitle = titleController.text.trim();

    // Check if the question title is empty.
    if (questionTitle.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Le titre de la question ne peut pas être vide.'),
        ),
      );
      return;
    }

    // Check if any option is empty.
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

    // Check that only one option is marked as true (correct).
    int trueCount = optionsTruthValues.values.where((v) => v).length;
    if (trueCount != 1) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Vous devez sélectionner une seule option correcte.'),
        ),
      );
      return;
    }

    // Check for duplicate options.
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

    // Map options with their truth values.
    Map<String, bool> options = optionsControllers.map(
      (key, controller) =>
          MapEntry(controller.text, optionsTruthValues[key] ?? false),
    );

    // Create a new question object.
    Question newQuestion = Question(
      // Firestore will auto-generate this.
      id: '', 
      title: questionTitle,
      options: options,
    );

    // Add the new question to the database.
    await dbConnect.addQuestion(newQuestion);

    // Navigate back to the previous screen.
    Navigator.pop(context);
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
                  // Input field for question title.
                  TextFormField(
                    controller: titleController,
                    decoration:
                        InputDecoration(labelText: 'Titre de la question'),
                  ),
                  // Input fields and switches for options.
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
            // Button to add the question.
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
