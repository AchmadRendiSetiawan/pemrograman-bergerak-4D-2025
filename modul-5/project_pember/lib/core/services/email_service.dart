import 'package:http/http.dart' as http;
import 'dart:convert';

Future<void> sendOTP(String email, String otp) async {
  const serviceId = 'your_service_id';
  const templateId = 'your_template_id';
  const userId = 'your_user_id';

  final url = Uri.parse('https://api.emailjs.com/api/v1.0/email/send');

  final response = await http.post(
    url,
    headers: {'origin': 'http://localhost', 'Content-Type': 'application/json'},
    body: json.encode({
      'service_id': serviceId,
      'template_id': templateId,
      'user_id': userId,
      'template_params': {'to_email': email, 'otp': otp},
    }),
  );

  if (response.statusCode == 200) {
    print('OTP sent!');
  } else {
    print('Failed to send OTP: ${response.body}');
  }
}
