import 'package:flutter/material.dart';
import '../utils/constants.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../widgets/custom_textfield.dart';
import '../utils/validators.dart';

class AdminPage extends StatefulWidget {
  @override
  State<AdminPage> createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  User? _user; // To store the authenticated user
  String? _signInError;

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
        } else {
          _signInError = 'Une erreur est survenue. Veuillez réessayer.';
        }
      });
    }
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
    // Build the admin UI here
    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text('Administration'),
        backgroundColor: background,
      ),
      body: Center(
        child: _user == null
            ? _buildSignInForm() // Show sign-in form when not authenticated
            : _buildAdminActions(), // Show admin actions when authenticated,
      ),
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
                      color: Colors.red, // Error text color
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
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Bienvenue ${_user!.email} !'),
              SizedBox(height: 25),
              ElevatedButton(
                onPressed: _signOut,
                style: ElevatedButton.styleFrom(
                  backgroundColor: neutral,
                  padding:
                      const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15.0),
                  ),
                ),
                child: const Text(
                  "Se déconnecter",
                  style: TextStyle(
                    fontSize: 20,
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              // Add admin-specific functionality and UI here
            ],
          ),
        ),
      ),
    );
  }
}
