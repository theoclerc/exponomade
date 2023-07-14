import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../constants.dart';

class ContactPage extends StatefulWidget {
  const ContactPage({Key? key}) : super(key: key);

  @override
  _ContactPageState createState() => _ContactPageState();
}

final nameController = TextEditingController();
final subjectController = TextEditingController();
final emailController = TextEditingController();
final messageController = TextEditingController();

Future sendEmail() async {
  final url = Uri.parse("https://api.emailjs.com/api/v1.0/email/send");
  const serviceId = "service_0pvl2j5";
  const templateId = "template_eukwi3w";
  const userId = "cAyLawFqO24GkUAng";
  final response = await http.post(url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        "service_id": serviceId,
        "template_id": templateId,
        "user_id": userId,
        "template_params": {
          "name": nameController.text,
          "subject": subjectController.text,
          "user_email": emailController.text,
          "message": messageController.text,
        }
      }));
  return response.statusCode;
}

class _ContactPageState extends State<ContactPage> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: background,
        appBar: AppBar(
          title: const Text('Contact Us'),
          backgroundColor: background,
        ),
        body: Padding(
          padding: const EdgeInsets.fromLTRB(25.0, 40, 25, 0),
          child: Column(
            children: [
              customTextField(nameController, Icons.account_circle, 'Name',
                  'Type your name...'),
              const SizedBox(
                height: 25,
              ),
              customTextField(subjectController, Icons.subject_rounded,
                  'Subject', 'Type the subject...'),
              const SizedBox(
                height: 25,
              ),
              customTextField(
                  emailController, Icons.email, 'Email', 'Type your email...'),
              const SizedBox(
                height: 25,
              ),
              customTextField(messageController, Icons.message, 'Message',
                  'Type your message...'),
              const SizedBox(
                height: 25,
              ),
              ElevatedButton(
                onPressed: () {
                  sendEmail();
                  _clearTextFields();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Form Submitted!'),
                      behavior: SnackBarBehavior.floating,
                      margin: EdgeInsets.only(
                          bottom: 20.0, left: 20.0, right: 20.0),
                    ),
                  );
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
                  "Send",
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
    );
  }

  Widget customTextField(TextEditingController controller, IconData icon,
      String labelText, String hintText) {
    return Container(
      padding: EdgeInsets.only(left: 10.0, right: 10.0),
      decoration: BoxDecoration(
        color: neutral,
        borderRadius: BorderRadius.circular(15.0),
      ),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          icon: Icon(icon),
          labelText: labelText,
          hintText: hintText,
          border: InputBorder.none,
        ),
      ),
    );
  }

  void _clearTextFields() {
    nameController.clear();
    subjectController.clear();
    emailController.clear();
    messageController.clear();
  }
}
