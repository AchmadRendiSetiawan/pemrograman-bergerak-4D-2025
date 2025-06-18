import 'package:flutter/material.dart';
import '../features/auth/auth_service.dart'; // Import AuthService
import '../widgets/custom_scaffold.dart'; //

class ForgetPasswordScreen extends StatefulWidget {
  @override
  State<ForgetPasswordScreen> createState() => _ForgetPasswordScreenState();
}

class _ForgetPasswordScreenState extends State<ForgetPasswordScreen> {
  final _emailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _loading = false;
  String _message = '';
  bool _isSuccess = false;

  Future<void> _handleSendResetEmail() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _loading = true;
      _message = '';
    });

    final email = _emailController.text.trim();
    final result = await AuthService.sendPasswordResetEmail(email);

    if (mounted) {
      setState(() {
        _loading = false;
        _message = result['message'];
        _isSuccess = result['success'];
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_message),
          backgroundColor: _isSuccess ? Colors.green : Colors.red,
        ),
      );

      if (_isSuccess) {
        // Optionally navigate back or clear fields
        // Navigator.pop(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return CustomScaffold( //
      child: Column(
        children: [
          const Expanded(
            flex: 3,
            child: SizedBox.shrink(), // Placeholder as background is in CustomScaffold
          ),
          Expanded(
            flex: 7,
            child: Container(
              padding: const EdgeInsets.fromLTRB(25.0, 40.0, 25.0, 20.0),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(40),
                  topRight: Radius.circular(40),
                ),
              ),
              child: SingleChildScrollView(
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'Reset Password',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 30.0,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'Enter your email address and we will send you a link to reset your password.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16.0,
                          color: Colors.grey[700],
                        ),
                      ),
                      const SizedBox(height: 30),
                      TextFormField(
                        controller: _emailController,
                        decoration: InputDecoration(
                          labelText: 'Email',
                          hintText: 'Enter your email',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          prefixIcon: Icon(Icons.email),
                        ),
                        keyboardType: TextInputType.emailAddress,
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your email';
                          } else if (!value.contains('@') || !value.contains('.')) {
                            return 'Please enter a valid email address';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 30),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        onPressed: _loading ? null : _handleSendResetEmail,
                        child: _loading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                              )
                            : const Text('Send Password Reset Email'),
                      ),
                      const SizedBox(height: 25.0),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            "Remember your password? ",
                            style: TextStyle(color: Colors.black45),
                          ),
                          GestureDetector(
                            onTap: () {
                              Navigator.pop(context);
                            },
                            child: Text(
                              'Sign In',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).primaryColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}