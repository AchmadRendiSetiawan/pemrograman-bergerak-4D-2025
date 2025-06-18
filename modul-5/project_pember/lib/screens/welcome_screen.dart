import 'package:flutter/material.dart';
import 'package:project_pember/screens/signin_screen.dart';
import 'package:project_pember/screens/signup_screen.dart';
import 'package:project_pember/widgets/custom_scaffold.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
      child: Stack(
        children: [
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Text(
                    'Welcome Back!',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Color.fromARGB(255, 0, 0, 0),
                    ),
                  ),
                  SizedBox(height: 12),
                  Text(
                    'Enter personal details to your Galery account',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      color: Color.fromARGB(179, 0, 0, 0),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => SignInScreen()),
                      );
                    },
                    child: const Padding(
                      padding: EdgeInsets.symmetric(vertical: 20),
                      child: Text(
                        'Sign in',
                        style: TextStyle(
                          color: Color.fromARGB(255, 0, 0, 0),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Container(
                    decoration: const BoxDecoration(
                      color: Color.fromARGB(255, 0, 0, 0),
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(32),
                      ),
                    ),
                    child: TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => SignUpScreen()),
                        );
                      },
                      child: const Padding(
                        padding: EdgeInsets.symmetric(vertical: 20),
                        child: Text(
                          'Sign up',
                          style: TextStyle(
                            color: Color.fromARGB(255, 255, 255, 255),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
