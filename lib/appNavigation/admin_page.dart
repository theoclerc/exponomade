import 'package:flutter/material.dart';
import '../utils/constants.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../widgets/custom_textfield.dart';
import '../utils/validators.dart';
import '../zones/zoneAdminPage.dart';

class AdminPage extends StatefulWidget {
  @override
  State<AdminPage> createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  List<String> collections = ['Musées', 'Zones'];
  bool showMuseumAdminPage = false;
  bool showZoneAdminPage = false;
  User? _user; // To store the authenticated user
  String? _signInError;

// For the sake of demonstration, I'll use a static list, but you can fetch it from Firestore.
  List<String> museums = [
    'Musée de Bagnes',
    'Another Museum',
    'And another one'
  ];

  @override
  void initState() {
    super.initState();
    _checkAuthenticationStatus();
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
                Text(
                  "Modifier la base de données :",
                  style: TextStyle(
                    fontSize: 20,
                    color: Colors.white,
                  ),
                ),
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
                              showMuseumAdminPage =
                                  true; // Show MuseumAdminPage
                            });
                          } else if (index == 1) {
                            // index for zones
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ZoneAdminPage(),
                              ),
                            );
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
          Expanded(
            child: ListView.builder(
              itemCount: museums.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(museums[index],
                      style: TextStyle(
                        color: Colors.white,
                      )),
                  trailing: Icon(
                    Icons.edit,
                    color: Colors.white,
                  ),
                  onTap: () {
                    // Handle tap to edit museum details or other admin actions.
                  },
                );
              },
            ),
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
          // Add a new museum.
        },
      ),
    );
  }
}
