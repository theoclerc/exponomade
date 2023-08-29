import 'dart:convert';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;

class ContactService {
  
  static final nameController = TextEditingController();
  static final subjectController = TextEditingController();
  static final emailController = TextEditingController();
  static final messageController = TextEditingController();
  static int score = 0;
  

  static Future<int> sendEmail() async {
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
            "score": score,
          }
        }));
    return response.statusCode;
  }

    static void clearTextFields() {
    nameController.clear();
    subjectController.clear();
    emailController.clear();
    messageController.clear();
  }
  
}
