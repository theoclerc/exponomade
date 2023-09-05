import 'package:flutter/material.dart';
import '../utils/constants.dart';
import '../services/contact_services.dart';
import '../widgets/custom_textfield.dart';
import '../utils/validators.dart';

class ContactPage extends StatefulWidget {
  // User's score.
  final int? score;

  const ContactPage({Key? key, this.score}) : super(key: key);

  @override
  State<ContactPage> createState() => _ContactPageState();
}

class _ContactPageState extends State<ContactPage> {
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    // Initialize the score from the widget parameter or set it to 0.
    ContactService.score = widget.score ?? 0;
  }

  Widget _sizedBox() => const SizedBox(height: 25);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      // Appbar for the contact form page.
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text('Formulaire de contact'),
        backgroundColor: background,
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(25.0, 40, 25, 0),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: Form(
              key: _formKey,
              child: Column(
                // Different boxes of the form to fill in.
                children: [
                  CustomTextField(
                    controller: ContactService.nameController,
                    icon: Icons.account_circle,
                    labelText: 'Nom',
                    hintText: 'écris ton nom ici',
                    maxLength: 30,
                  ),
                  _sizedBox(),
                  CustomTextField(
                    controller: ContactService.subjectController,
                    icon: Icons.subject_rounded,
                    labelText: 'Sujet',
                    hintText: 'écris le sujet de ton message ici',
                    maxLength: 20,
                  ),
                  _sizedBox(),
                  CustomTextField(
                    controller: ContactService.emailController,
                    icon: Icons.email,
                    labelText: 'Email',
                    hintText: 'à quelle adresse pouvons-nous te répondre ?',
                    maxLength: 40,
                    validator: Validators.emailValidator,
                  ),
                  _sizedBox(),
                  CustomTextField(
                    controller: ContactService.messageController,
                    icon: Icons.message,
                    labelText: 'Message',
                    hintText: 'écris ton message ici',
                    maxLength: 300,
                    minLines: 3,
                    maxLines: null,
                    keyboardType: TextInputType.multiline,
                  ),
                  _sizedBox(),
                  // Button to validate form submission.
                  ElevatedButton(
                    // Reaction after pressing the button "Envoyer"
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        ContactService.sendEmail();
                        ContactService.clearTextFields();
                        ContactService.redirectToHomecontact(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Formulaire envoyé !'),
                            behavior: SnackBarBehavior.floating,
                            margin: EdgeInsets.only(
                                bottom: 20.0, left: 20.0, right: 20.0),
                          ),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: neutral,
                      padding:
                          const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15.0),
                      ),
                    ),
                    child: const Text(
                      "Envoyer",
                      style: TextStyle(
                        fontSize: 20,
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  _sizedBox(),
                  Text(
                    // Display the user's score or a default of '0'.
                    "Note: votre score de ${widget.score ?? '0'} sera inclus dans le courriel.",
                    style: const TextStyle(
                      fontSize: 14,
                      fontStyle: FontStyle.italic,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
