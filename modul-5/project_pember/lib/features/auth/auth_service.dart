// In lib/features/auth/auth_service.dart

import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  static final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  static bool isLoggedIn() {
    return _firebaseAuth.currentUser != null;
  }

  static String? getUserEmail() {
    return _firebaseAuth.currentUser?.email;
  }

  // Add this method
  static String? getUserUID() {
    return _firebaseAuth.currentUser?.uid;
  }

  static Future<bool> login(String email, String password) async {
    try {
      await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return true;
    } on FirebaseAuthException catch (e) {
      print('Firebase Login Error: ${e.message}');
      return false;
    } catch (e) {
      print('Login Error: $e');
      return false;
    }
  }

  static Future<Map<String, dynamic>> signUp(
    String email,
    String password,
  ) async {
    try {
      await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return {'success': true, 'message': 'Account created successfully!'};
    } on FirebaseAuthException catch (e) {
      String message = 'An error occurred. Please try again.';
      if (e.code == 'weak-password') {
        message = 'The password provided is too weak.';
      } else if (e.code == 'email-already-in-use') {
        message = 'The account already exists for that email.';
      } else {
        message = e.message ?? message;
      }
      print('Firebase SignUp Error: $message');
      return {'success': false, 'message': message};
    } catch (e) {
      print('SignUp Error: $e');
      return {'success': false, 'message': 'An unexpected error occurred.'};
    }
  }

  static Future<void> logout() async {
    await _firebaseAuth.signOut();
  }

  static Future<Map<String, dynamic>> sendPasswordResetEmail(
    String email,
  ) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email);
      return {
        'success': true,
        'message': 'Password reset email sent. Check your inbox.',
      };
    } on FirebaseAuthException catch (e) {
      String message = 'An error occurred. Please try again.';
      if (e.code == 'user-not-found') {
        message = 'No user found for that email.';
      } else {
        message = e.message ?? message;
      }
      print('Firebase Password Reset Error: $message');
      return {'success': false, 'message': message};
    } catch (e) {
      print('Password Reset Error: $e');
      return {'success': false, 'message': 'An unexpected error occurred.'};
    }
  }
}
