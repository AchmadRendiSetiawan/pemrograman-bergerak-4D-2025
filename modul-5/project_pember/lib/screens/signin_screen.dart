import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:project_pember/screens/signup_screen.dart';
import '../features/auth/auth_service.dart';
import '../main.dart'; //
import 'forget_password_screen.dart';
import '../widgets/custom_scaffold.dart';

class SignInScreen extends StatefulWidget {
  @override
  _SignInScreenState createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  String _error = '';
  bool _loading = false;
  bool _rememberMe = false;

  // Updated _handleLogin method
  void _handleLogin() async {
    setState(() {
      _loading = true;
      _error = '';
    });

    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    // Use the updated AuthService.login
    final success = await AuthService.login(email, password); //

    if (mounted) {
      setState(() => _loading = false);

      if (success) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => MainNavigation()), //
          (route) => false,
        );
      } else {
        setState(() => _error = 'Login failed. Please check your email and password.');
      }
    }
  }

  Future<void> _loadSavedCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _rememberMe = prefs.getBool('rememberMe') ?? false;
      if (_rememberMe) {
        _emailController.text = prefs.getString('savedEmail') ?? '';
        _passwordController.text = prefs.getString('savedPassword') ?? '';
      }
    });
  }

  Future<void> _saveCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    if (_rememberMe) {
      prefs.setString('savedEmail', _emailController.text);
      prefs.setString('savedPassword', _passwordController.text);
    } else {
      prefs.remove('savedEmail');
      prefs.remove('savedPassword');
    }
    prefs.setBool('rememberMe', _rememberMe);
  }

  @override
  void initState() {
    super.initState();
    _loadSavedCredentials();
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      'Welcome Back',
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.w900,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 40),
                    if (_error.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: Text(
                          _error,
                          style: const TextStyle(color: Colors.red),
                        ),
                      ),
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
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
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Masukkan email';
                        } else if (!value.contains('@') || !value.contains('.')) { // Basic email check
                          return 'Enter a valid email address';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 25),
                    TextFormField(
                      controller: _passwordController,
                      obscureText: true,
                      obscuringCharacter: '*',
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
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Password tidak boleh kosong';
                        }
                        // You might want to keep or adjust password length validation
                        // if (value.length < 2) {
                        //   return 'Password minimal 2 karakter';
                        // }
                        return null;
                      },
                    ),
                    const SizedBox(height: 15),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Checkbox(
                              value: _rememberMe,
                              onChanged:
                                  (val) => setState(
                                    () => _rememberMe = val ?? false,
                                  ),
                              activeColor: Colors.black,
                            ),
                            const Text(
                              'Remember me',
                              style: TextStyle(color: Colors.black),
                            ),
                          ],
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => ForgetPasswordScreen(),
                              ),
                            );
                          },
                          child: const Text(
                            'Lupa Password?',
                            style: TextStyle(color: Colors.black),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 25),
                    _loading
                        ? const Center(child: CircularProgressIndicator())
                        : SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.black,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 16),
                            ),
                            onPressed: () {
                              _saveCredentials();
                              _handleLogin();
                            },
                            child: const Text('Sign In'),
                          ),
                        ),
                    const SizedBox(height: 25),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          "Belum punya akun? ",
                          style: TextStyle(color: Colors.black45),
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => SignUpScreen()), //
                            );
                          },
                          child: Text(
                            'Daftar',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
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
        ],
      ),
    );
  }
}