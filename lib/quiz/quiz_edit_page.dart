import '../database/db_connect.dart';
import 'package:flutter/material.dart';
import '../models/question_model.dart';


class EditQuizPage extends StatefulWidget {
  final Question question;

  EditQuizPage({required this.question});

  @override
  _EditQuizPageState createState() => _EditQuizPageState();
}

class _EditQuizPageState extends State<EditQuizPage> {
  TextEditingController titleController = TextEditingController();
  Map<String, TextEditingController> optionsControllers = {};
  Map<String, bool> optionsTruthValues = {};  // To keep track of the truth values
  final DBconnect dbConnect = DBconnect();

  @override
  void initState() {
    super.initState();
    titleController.text = widget.question.title;
    widget.question.options.forEach((key, value) {
      optionsControllers[key] = TextEditingController(text: key);
      optionsTruthValues[key] = value;  // Initialize the truth values
    });
  }

  void saveQuestion() async {
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

    // Check for duplicate options
    List<String> optionTexts = optionsControllers.values.map((controller) => controller.text.trim()).toList();
    if (optionTexts.toSet().length != optionTexts.length) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Les réponses doivent être uniques.'),
        ),
      );
      return;
    }

  // Update Firestore
  await dbConnect.updateQuestion(
    widget.question.id,
    questionTitle,
    optionsControllers.map((key, controller) => MapEntry(controller.text.trim(), optionsTruthValues[key] ?? false))
  );
    
    Navigator.pop(context); // Close the edit page and go back
  }

  void setOnlyOneTrue(String option, bool value) {
    // If setting to true, make this the only true option
    if (value) {
      setState(() {
        optionsTruthValues.forEach((key, _) {
          optionsTruthValues[key] = false;
        });
        optionsTruthValues[option] = true;
      });
    } else {
      // If setting to false, only allow if there's another true option
      int trueCount = optionsTruthValues.values.where((e) => e).length;
      if (trueCount > 1) {
        setState(() {
          optionsTruthValues[option] = false;
        });
      } else {
        // Show a dialog, alert, or some feedback
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
        title: Text('Edit Quiz'),
      ),
      body: Column(
        children: [
          ListTile(
            title: TextField(
              controller: titleController,
              decoration: InputDecoration(labelText: 'Question Title'),
            ),
          ),
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
                    // Ensure that at least one option is true before allowing de-selection
                    int trueCount = optionsTruthValues.values.where((e) => e).length;
                    if (trueCount > 1) {
                      setState(() {
                        optionsTruthValues[option] = false;
                      });
                    } else {
                      // Show a dialog, alert, or some feedback
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
                },
              ),
            ),
          ),
          ElevatedButton(onPressed: saveQuestion, child: Text('Sauvegarder'))
        ],
      ),
    );
  }
}

