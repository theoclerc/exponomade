import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../appNavigation/home_page.dart';

// This class provides functions to interact with a contact form and send emails.
class ContactService {
  // Text controllers for form input fields.
  static final nameController = TextEditingController();
  static final subjectController = TextEditingController();
  static final emailController = TextEditingController();
  static final messageController = TextEditingController();
  static int score = 0;

  // Sends an email using an external email service and returns the response status code.
  static Future<int> sendEmail() async {
    final url = Uri.parse("https://api.emailjs.com/api/v1.0/email/send");
    const serviceId = "service_0pvl2j5";
    const templateId = "template_eukwi3w";
    const userId = "cAyLawFqO24GkUAng";

    final response = await http.post(url,
        headers: {
          'origin': 'http://localhost',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          "service_id": serviceId,
          "template_id": templateId,
          "user_id": userId,
          "template_params": {
            "name": nameController.text,
            "subject": subjectController.text,
            "user_email": emailController.text,
            "message": messageController.text,
            "score": score,
          }
        }));
    return response.statusCode;
  }

  // Clears the text fields in the contact form.
  static void clearTextFields() {
    nameController.clear();
    subjectController.clear();
    emailController.clear();
    messageController.clear();
  }

  // Redirects to the home page after performing a contact-related action.
  static void redirectToHomecontact(BuildContext context) {
    Navigator.push(context, MaterialPageRoute(builder: (context) => const HomePage(initialPage: 1)));
  }
}
