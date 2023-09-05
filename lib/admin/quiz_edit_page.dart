import '../database/db_connect.dart';
import 'package:flutter/material.dart';
import '../models/question_model.dart';
import '../utils/constants.dart';

class EditQuizPage extends StatefulWidget {
  final Question question;

  EditQuizPage({required this.question});

  @override
  _EditQuizPageState createState() => _EditQuizPageState();
}

class _EditQuizPageState extends State<EditQuizPage> {
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

    // Initialize the title input field with the current question's title.
    titleController.text = widget.question.title;

    // Initialize option controllers and truth values from the current question.
    widget.question.options.forEach((key, value) {
      optionsControllers[key] = TextEditingController(text: key);
      optionsTruthValues[key] = value;
    });
  }

  // Function to save the edited question.
  void saveQuestion() async {
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

    // Check for duplicate options.
    List<String> optionTexts = optionsControllers.values
        .map((controller) => controller.text.trim())
        .toList();
    if (optionTexts.toSet().length != optionTexts.length) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Les réponses doivent être uniques.'),
        ),
      );
      return;
    }

    // Update the question in Firestore.
    await dbConnect.updateQuestion(
        widget.question.id,
        questionTitle,
        optionsControllers.map((key, controller) => MapEntry(
            controller.text.trim(), optionsTruthValues[key] ?? false)));

    // Close the edit page and navigate back.
    Navigator.pop(context);
  }

  // Function to set only one option as true and handle errors.
  void setOnlyOneTrue(String option, bool value) {
    if (value) {
      // If setting to true, make this the only true option.
      setState(() {
        optionsTruthValues.forEach((key, _) {
          optionsTruthValues[key] = false;
        });
        optionsTruthValues[option] = true;
      });
    } else {
      // If setting to false, only allow if there's another true option.
      int trueCount = optionsTruthValues.values.where((e) => e).length;
      if (trueCount > 1) {
        setState(() {
          optionsTruthValues[option] = false;
        });
      } else {
        // Show a dialog, alert, or some feedback for the error.
        showDialog(
            context: context,
            builder: (context) => AlertDialog(
                  title: Text("Erreur"),
                  content: Text("Au moins une option doit être correcte."),
                  actions: [
                    TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: Text("OK"))
                  ],
                ));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Modifier une question'),
        backgroundColor: background,
      ),
      body: Column(
        children: [
          // Input field for question title.
          ListTile(
            title: TextField(
              controller: titleController,
              decoration: InputDecoration(labelText: 'Titre de la question'),
            ),
          ),
          // Input fields for options and switches for truth values.
          ...optionsControllers.keys.map(
            (option) => ListTile(
              title: TextField(
                controller: optionsControllers[option],
                decoration: InputDecoration(labelText: 'Option'),
              ),
              trailing: Switch(
                value: optionsTruthValues[option] ?? false,
                onChanged: (bool value) {
                  if (value) {
                    setOnlyOneTrue(option, value);
                  } else {
                    // Ensure that at least one option is true before allowing de-selection.
                    int trueCount =
                        optionsTruthValues.values.where((e) => e).length;
                    if (trueCount > 1) {
                      setState(() {
                        optionsTruthValues[option] = false;
                      });
                    } else {
                      // Show a dialog, alert, or some feedback for the error.
                      showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                                title: Text("Erreur"),
                                content: Text(
                                    "Au moins une option doit être correcte."),
                                actions: [
                                  TextButton(
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      },
                                      child: Text("OK"))
                                ],
                              ));
                    }
                  }
                },
              ),
            ),
          ),
          // Button to save the edited question.
          ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: background,
              ),
              onPressed: saveQuestion,
              child: Text('Sauvegarder'))
        ],
      ),
    );
  }
}
