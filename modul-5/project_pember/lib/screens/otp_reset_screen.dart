import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class OtpResetScreen extends StatefulWidget {
  final String email;
  final String otp;

  OtpResetScreen({required this.email, required this.otp});

  @override
  _OtpResetScreenState createState() => _OtpResetScreenState();
}

class _OtpResetScreenState extends State<OtpResetScreen> {
  final _otpController = TextEditingController();
  final _newPassController = TextEditingController();
  String _error = '';

  void _verifyOtp() async {
    if (_otpController.text.trim() == widget.otp) {
      final url = Uri.parse(
        'https://studio-foto-5471f-default-rtdb.firebaseio.com/users.json',
      );
      final res = await http.get(url);

      if (res.statusCode == 200) {
        final data = json.decode(res.body) as Map<String, dynamic>;
        final updatedUsers = <String, dynamic>{};

        data.forEach((key, value) {
          if (value['email'] == widget.email) {
            value['password'] = _newPassController.text.trim();
          }
          updatedUsers[key] = value;
        });

        await http.put(url, body: json.encode(updatedUsers));
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Password berhasil diperbarui.')),
        );
        Navigator.pop(context);
        Navigator.pop(context);
      }
    } else {
      setState(() => _error = 'Kode OTP salah!');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Verifikasi OTP')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            if (_error.isNotEmpty)
              Text(_error, style: TextStyle(color: Colors.red)),
            TextField(
              controller: _otpController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: 'Kode OTP'),
            ),
            TextField(
              controller: _newPassController,
              obscureText: true,
              decoration: InputDecoration(labelText: 'Password Baru'),
            ),
            SizedBox(height: 24),
            ElevatedButton(
              onPressed: _verifyOtp,
              child: Text('Ganti Password'),
            ),
          ],
        ),
      ),
    );
  }
}
