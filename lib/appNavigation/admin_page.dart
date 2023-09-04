import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:exponomade/admin/zone_add_page.dart';
import 'package:flutter/material.dart';
import '../models/musee_model.dart';
import '../utils/constants.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../widgets/custom_textfield.dart';
import '../utils/validators.dart';
import '../admin/zone_edit_page.dart';
import 'editMuseumPage.dart';
import 'addMuseumPage.dart';
import '../models/question_model.dart';
import '../database/db_connect.dart';
import '../admin/quiz_add_page.dart';
import '../admin/quiz_edit_page.dart';
import 'home_page.dart';

class AdminPage extends StatefulWidget {
  @override
  State<AdminPage> createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  List<String> collections = ['Musées', 'Quiz', 'Zones'];
  bool showMuseumAdminPage = false;
  bool showZoneAdminPage = false;
  bool showQuizAdminPage = false;
  User? _user; // To store the authenticated user
  String? _signInError;
  late Future<List<Question>> questions;
  late Future<List<Musee>> musees;
  final DBconnect db = DBconnect();

  @override
  void initState() {
    super.initState();
    _checkAuthenticationStatus();
    questions = db.fetchQuestions();
    musees = db.fetchMusees();
  }

  // Function to check if a user is already authenticated
  Future<void> _checkAuthenticationStatus() async {
    User? user = FirebaseAuth.instance.currentUser;
    setState(() {
      _user = user;
    });
  }

  // Function to sign in with email and password
  Future<void> _signInWithEmailAndPassword() async {
    try {
      UserCredential userCredential =
          await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text,
        password: _passwordController.text,
      );

      // Update the UI to reflect the signed-in user
      setState(() {
        _user = userCredential.user;
        _signInError = null;
      });

      // Successful sign-in, you can now perform admin actions.
      // Access the signed-in user: userCredential.user
    } catch (e) {
      setState(() {
        if (e.toString().contains('user-not-found') ||
            e.toString().contains('wrong-password')) {
          _signInError = 'L\u0027utilisateur ou le mot de passe est incorrect.';
        } else if (_emailController.text.isEmpty ||
            e.toString().contains('invalid-email')) {
          _signInError = 'Veuillez rentrer une adresse email valide.';
        } else {
          _signInError = 'Une erreur est survenue. Veuillez réessayer.';
        }
      });
    }
    _emailController.clear();
    _passwordController.clear();
  }

  // Function to sign out
  Future<void> _signOut() async {
    await FirebaseAuth.instance.signOut();
    // After signing out, _user will be null.
    setState(() {
      _user = null;
    });
    Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const HomePage(initialPage: 0),
        ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      appBar: _user != null
          ? AppBar(
              automaticallyImplyLeading: false,
              title: Text('Administration'),
              backgroundColor: background,
              actions: [
                  IconButton(icon: Icon(Icons.logout), onPressed: _signOut),
                ])
          : AppBar(
              automaticallyImplyLeading: false,
              title: Text('Administration'),
              backgroundColor: background,
            ),
      body: Center(
        child: _user == null
            ? _buildSignInForm() // Show sign-in form when not authenticated
            : _buildAdminActions(),
      ), // Show admin actions when authenticated,
    );
  }

  Widget _buildSignInForm() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(25.0, 40, 25, 0),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: Form(
            child: Column(
              children: [
                const Text(
                  "Veuillez vous connecter",
                  style: TextStyle(
                    fontSize: 20,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 25),
                CustomTextField(
                  controller: _emailController,
                  icon: Icons.email,
                  labelText: 'Email',
                  hintText: 'Email',
                  maxLength: 40,
                  validator: Validators.emailValidator,
                ),
                SizedBox(height: 25),
                CustomTextField(
                  controller: _passwordController,
                  icon: Icons.password,
                  labelText: 'Mot de passe',
                  hintText: 'Mot de passe',
                  obscureText: true,
                  maxLines: 1,
                ),
                SizedBox(height: 25),
                ElevatedButton(
                  onPressed: _signInWithEmailAndPassword,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: neutral,
                    padding: const EdgeInsets.symmetric(
                        vertical: 16, horizontal: 24),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15.0),
                    ),
                  ),
                  child: const Text(
                    "Se connecter",
                    style: TextStyle(
                      fontSize: 20,
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                SizedBox(height: 25),
                if (_signInError != null)
                  Text(
                    _signInError!,
                    style: TextStyle(
                      fontSize: 20,
                      color: Colors.red,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAdminActions() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(25.0, 40, 25, 0),
      child: showMuseumAdminPage
          ? _buildMuseumAdminPage()
          : showQuizAdminPage
              ? _buildQuizAdminPage()
              : showZoneAdminPage
                  ? _buildZoneAdminPage()
                  : Column(
                      children: [
                        Text(
                          "Bienvenue ${_user!.email} !",
                          style: TextStyle(
                            fontSize: 20,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(height: 25),
                        Expanded(
                          child: ListView.builder(
                            itemCount: collections.length,
                            itemBuilder: (context, index) {
                              return ListTile(
                                title: Text(
                                  collections[index],
                                  style: TextStyle(
                                    color: Colors.white,
                                  ),
                                ),
                                onTap: () {
                                  if (index == 0) {
                                    setState(() {
                                      showMuseumAdminPage = true;
                                    });
                                  } else if (index == 1) {
                                    setState(() {
                                      showQuizAdminPage = true;
                                    });
                                  } else if (index == 2) {
                                    setState(() {
                                      showZoneAdminPage = true;
                                    });
                                  }
                                },
                                trailing: Icon(
                                  Icons.arrow_forward_ios,
                                  color: Colors.white,
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
    );
  }

  Widget _buildMuseumAdminPage() {
    return Scaffold(
      backgroundColor: background,
      body: Column(
        children: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: neutral,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15.0),
              ),
            ),
            onPressed: () {
              setState(() {
                showMuseumAdminPage = false; // Hide the MuseumAdminPage
              });
            },
            child: Text("Retour",
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                )),
          ),
          FutureBuilder<List<Musee>>(
            future: musees,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              }

              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return Center(child: Text('Aucun muséee trouvé'));
              }

              return Expanded(
                child: ListView.builder(
                  itemCount:
                      snapshot.data!.length * 2 - 1, // Account for Dividers
                  itemBuilder: (context, index) {
                    if (index.isEven) {
                      Musee musee = snapshot.data![index ~/ 2];
                      return ListTile(
                        title: Text(
                          musee.nomMusee,
                          style: TextStyle(
                            color: Colors.white,
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Coordonnées: ${musee.coord.latitude}, ${musee.coord.longitude}',
                              style: TextStyle(
                                color: Colors.white70,
                              ),
                            ),
                            ...musee.objets
                                .map((objet) => Text(
                                      objet.nomObjet,
                                      style: TextStyle(
                                        color: Colors.white70,
                                      ),
                                    ))
                                .toList(),
                          ],
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: Icon(
                                Icons.edit,
                                color: Colors.white,
                              ),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        EditMuseumPage(musee: musee),
                                  ),
                                ).then((_) {
                                  setState(() {
                                    musees = db.fetchMusees();
                                  });
                                });
                              },
                            ),
                            IconButton(
                              icon: Icon(
                                Icons.delete,
                                color: Colors.white,
                              ),
                              onPressed: () {
                                showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return AlertDialog(
                                      title: Text('Confirmer la suppression'),
                                      content: Text(
                                          'Etes-vous sûr de vouloir supprimer ce musée ?'),
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
                                            db.deleteMusee(musee.id).then((_) {
                                              setState(() {
                                                musees = db.fetchMusees();
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
                      return Divider();
                    }
                  },
                  padding: EdgeInsets.only(bottom: 80.0),
                ),
              );
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: neutral,
        child: Icon(
          Icons.add,
          color: Colors.black,
        ),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddMuseumPage(),
            ),
          ).then((_) {
            setState(() {
              musees = db.fetchMusees();
            });
          });
        },
      ),
    );
  }

  Widget _buildQuizAdminPage() {
    return Scaffold(
      backgroundColor: background,
      body: Column(
        children: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: neutral,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15.0),
              ),
            ),
            onPressed: () {
              setState(() {
                showQuizAdminPage = false; // Hide the QuizAdminPage
              });
            },
            child: Text("Retour",
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                )),
          ),
          FutureBuilder<List<Question>>(
            future: questions,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              }

              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return Center(child: Text('Aucune question trouvée'));
              }

              return Expanded(
                child: ListView.builder(
                  itemCount:
                      snapshot.data!.length * 2 - 1, // Account for Dividers
                  itemBuilder: (context, index) {
                    if (index.isEven) {
                      // This is a ListTile
                      Question question = snapshot.data![index ~/ 2];
                      return ListTile(
                        title: Text(
                          question.title,
                          style: TextStyle(
                            color: Colors.white,
                          ),
                        ),
                        subtitle: Text(
                          question.options.keys.join(', '),
                          style: TextStyle(
                            color: Colors.white70,
                          ),
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: Icon(
                                Icons.edit,
                                color: Colors.white,
                              ),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        EditQuizPage(question: question),
                                  ),
                                ).then((_) {
                                  setState(() {
                                    questions = db.fetchQuestions();
                                  });
                                });
                              },
                            ),
                            IconButton(
                              icon: Icon(
                                Icons.delete,
                                color: Colors.white,
                              ),
                              onPressed: () {
                                showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return AlertDialog(
                                      title: Text('Confirmer la suppression'),
                                      content: Text(
                                          'Etes-vous sûr de vouloir supprimer cette question ?'),
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
                                            db
                                                .deleteQuestion(question.id)
                                                .then((_) {
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
                  padding: EdgeInsets.only(
                      bottom: 80.0), // Extra padding at the bottom
                ),
              );
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: neutral,
        child: Icon(
          Icons.add,
          color: Colors.black,
        ),
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

  Widget _buildZoneAdminPage() {
    return Scaffold(
      backgroundColor: background,
      body: Column(
        children: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: neutral,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15.0),
              ),
            ),
            onPressed: () {
              setState(() {
                showZoneAdminPage = false; // Hide the QuizAdminPage
              });
            },
            child: Text("Retour",
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                )),
          ),
          FutureBuilder<List<DocumentSnapshot>>(
            future: db.fetchZones(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(child: Text('Error fetching data'));
              } else if (snapshot.data == null || snapshot.data!.isEmpty) {
                return Center(child: Text('No zones found'));
              } else {
                return Expanded(
                  child: ListView.builder(
                    itemCount: snapshot.data!.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        title: Text(
                          snapshot.data![index]['nomZone'],
                          style: TextStyle(
                            color: Colors.white,
                          ),
                        ),
                        subtitle: Text(
                          "De ${snapshot.data![index]['chronologieZone']['de']} à ${snapshot.data![index]['chronologieZone']['à']}",
                          style: TextStyle(
                            color: Colors.white70,
                          ),
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: Icon(
                                Icons.edit,
                                color: Colors.white,
                              ),
                              onPressed: () async {
                                await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => EditZonePage(
                                      initialData: snapshot.data![index].data()
                                          as Map<String, dynamic>,
                                      docId: snapshot.data![index].id,
                                      onSave: () {
                                        setState(
                                            () {}); // This will refresh your widget
                                      },
                                    ),
                                  ),
                                );
                              },
                            ),
                            IconButton(
                              icon: Icon(
                                Icons.delete,
                                color: Colors.white,
                              ),
                              onPressed: () {
                                showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return AlertDialog(
                                      title: Text('Confirmer la suppression'),
                                      content: Text(
                                          'Etes-vous sûr de vouloir supprimer ce musée ?'),
                                      actions: [
                                        TextButton(
                                          child: Text('Annuler'),
                                          onPressed: () {
                                            Navigator.of(context).pop();
                                          },
                                        ),
                                        TextButton(
                                          child: Text('Effacer'),
                                          onPressed: () async {
                                            // Call the delete function for the selected zone
                                            await db.deleteZone(
                                                snapshot.data![index].id);

                                            // Refresh the list
                                            setState(() {
                                              db.fetchZones();
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
                    },
                    padding: EdgeInsets.only(bottom: 80.0),
                  ),
                );
              }
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: neutral,
        child: Icon(
          Icons.add,
          color: Colors.black,
        ),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ZoneAddPage(),
            ),
          ).then((_) {
            setState(() {
              db.fetchZones();
            });
          });
        },
      ),
    );
  }
}
