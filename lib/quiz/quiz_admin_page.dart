import 'package:flutter/material.dart';
import '../database/db_connect.dart';
import '../models/question_model.dart';
import 'quiz_add_page.dart';
import 'quiz_edit_page.dart';

class QuizAdminPage extends StatefulWidget {
  @override
  _QuizAdminPageState createState() => _QuizAdminPageState();
}

class _QuizAdminPageState extends State<QuizAdminPage> {
  late Future<List<Question>> questions;
  final DBconnect db = DBconnect();

  @override
  void initState() {
    super.initState();
    questions = db.fetchQuestions();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Quiz Admin')),
      body: FutureBuilder<List<Question>>(
        future: questions,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return CircularProgressIndicator();
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Text('Aucune question trouvée');
          }

          return ListView.builder(
            itemCount: snapshot.data!.length * 2 - 1, // Account for Dividers
            itemBuilder: (context, index) {
              if (index.isEven) {
                // This is a ListTile
                Question question = snapshot.data![index ~/ 2];
                return ListTile(
                  title: Text(question.title),
                  subtitle: Text(question.options.keys.join(', ')),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(Icons.edit),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => EditQuizPage(question: question),
                            ),
                          ).then((_) {
                            setState(() {
                              questions = db.fetchQuestions();
                            });
                          });
                        },
                      ),
                      IconButton(
                        icon: Icon(Icons.delete),
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: Text('Confirmer la suppression'),
                                content: Text('Etes-vous sûr de vouloir supprimer cette question ?'),
                                actions: [
                                  TextButton(
                                    child: Text('Annuler'),
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                  ),
                                  TextButton(
                                    child: Text('Effacer'),
                                    onPressed: () {
                                      db.deleteQuestion(question.id).then((_) {
                                        setState(() {
                                          questions = db.fetchQuestions();
                                        });
                                      });
                                      Navigator.of(context).pop();
                                    },
                                  ),
                                ],
                              );
                            },
                          );
                        },
                      ),
                    ],
                  ),
                );
              } else {
                // This is a Divider
                return Divider();
              }
            },
            padding: EdgeInsets.only(bottom: 80.0), // Extra padding at the bottom
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => QuizAddPage(),
            ),
          ).then((_) {
            setState(() {
              questions = db.fetchQuestions();
            });
          });
        },
      ),
    );
  }

}
