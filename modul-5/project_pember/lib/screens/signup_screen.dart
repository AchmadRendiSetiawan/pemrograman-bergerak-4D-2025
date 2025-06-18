import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http; // No longer needed for signup
import 'package:project_pember/screens/signin_screen.dart'; //
// import 'dart:convert'; // No longer needed for signup
import '../features/auth/auth_service.dart'; // Import AuthService
import '../theme/theme.dart';
import '../widgets/custom_scaffold.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool agree = true; // Assuming default is true, adjust if needed
  bool _loading = false;

  // Updated _handleSignUp method
  Future<void> _handleSignUp() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    if (!agree) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('You must agree to the terms to continue.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _loading = true);

    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    // Use the updated AuthService.signUp
    final result = await AuthService.signUp(email, password);

    if (mounted) {
      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['message']),
          backgroundColor: result['success'] ? Colors.green : Colors.red,
        ),
      );

      if (result['success']) {
        Navigator.pushReplacement( // Navigate to SignInScreen after successful signup
          context,
          MaterialPageRoute(builder: (_) => SignInScreen()), //
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
      child: Column(
        children: [
          const Expanded(flex: 1, child: SizedBox(height: 10)),
          Expanded(
            flex: 7,
            child: Container(
              padding: const EdgeInsets.fromLTRB(25, 50, 25, 20),
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
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        'Create Account',
                        style: TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.w900,
                          color: lightColorScheme.primary, //
                        ),
                      ),
                      const SizedBox(height: 40),
                      TextFormField(
                        controller: _emailController,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Masukkan email';
                          } else if (!value.contains('@') || !value.contains('.')) { // Basic email check
                            return 'Enter a valid email address';
                          }
                          return null;
                        },
                        decoration: InputDecoration(
                          label: const Text('Email'),
                          hintText: 'Enter Email',
                          hintStyle: const TextStyle(color: Colors.black26),
                          border: OutlineInputBorder(
                            borderSide: const BorderSide(color: Colors.black12),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: const BorderSide(color: Colors.black12),
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                      const SizedBox(height: 25),
                      TextFormField(
                        controller: _passwordController,
                        obscureText: true,
                        obscuringCharacter: '*',
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Masukkan password';
                          } else if (value.length < 6) { // Firebase default is 6 chars
                            return 'Password must be at least 6 characters';
                          }
                          return null;
                        },
                        decoration: InputDecoration(
                          label: const Text('Password'),
                          hintText: 'Enter Password',
                          hintStyle: const TextStyle(color: Colors.black26),
                          border: OutlineInputBorder(
                            borderSide: const BorderSide(color: Colors.black12),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: const BorderSide(color: Colors.black12),
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                      const SizedBox(height: 25),
                      Row(
                        children: [
                          Checkbox(
                            value: agree,
                            onChanged: (val) => setState(() => agree = val!),
                            activeColor: lightColorScheme.primary, //
                          ),
                          const Text(
                            'I agree to the terms',
                            style: TextStyle(color: Colors.black45),
                          ),
                        ],
                      ),
                      const SizedBox(height: 25),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _loading ? null : _handleSignUp,
                          child: _loading
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                )
                              : const Text('Sign Up'),
                        ),
                      ),
                      const SizedBox(height: 25),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            'Already have an account? ',
                            style: TextStyle(color: Colors.black45),
                          ),
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => SignInScreen(), //
                                ),
                              );
                            },
                            child: Text(
                              'Sign in',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: lightColorScheme.primary, //
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
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