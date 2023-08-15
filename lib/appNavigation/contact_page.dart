import 'package:flutter/material.dart';
import '../constants.dart';
import '../services/contact_services.dart';
import '../widgets/custom_textfield.dart';


class ContactPage extends StatefulWidget {
  const ContactPage({Key? key}) : super(key: key);

  @override
  State<ContactPage> createState() => _ContactPageState();
}

class _ContactPageState extends State<ContactPage> {
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        backgroundColor: background,
        appBar: AppBar(
          title: const Text('Formulaire de contact'),
          backgroundColor: background,
        ),
        body: Padding(
          padding: const EdgeInsets.fromLTRB(25.0, 40, 25, 0),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                CustomTextField(
                  controller: ContactService.nameController,
                  icon: Icons.account_circle,
                  labelText: 'Nom',
                  hintText: 'écris ton nom ici',
                  maxLength: 30,
                ),
                const SizedBox(height: 25),
                CustomTextField(
                  controller: ContactService.subjectController,
                  icon: Icons.subject_rounded,
                  labelText: 'Sujet',
                  hintText: 'écris le sujet de ton message ici',
                  maxLength: 20,
                ),
                const SizedBox(height: 25),
                CustomTextField(
                    controller: ContactService.emailController,
                    icon: Icons.email,
                    labelText: 'Email',
                    hintText: 'à quelle adresse pouvons-nous te répondre ?',
                    maxLength: 40,
                    validator: (value) {
                        Pattern pattern = r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,4}$';
                        RegExp regex = RegExp(pattern as String);
                        if (!regex.hasMatch(value!)) {
                            return 'Entrez un e-mail valide';
                        } else {
                            return null;
                        }
                    },
                ),
                const SizedBox(height: 25),
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
                const SizedBox(height: 25),
                ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      ContactService.sendEmail();
                      ContactService.clearTextFields(); 
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
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
