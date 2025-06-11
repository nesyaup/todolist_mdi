import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<bool> signIn(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      return true;
    } catch (e) {
      print("SignIn Error: $e");
      return false;
    }
  }

  Future<bool> signUp(String email, String password) async {
    try {
      await _auth.createUserWithEmailAndPassword(email: email, password: password);
      return true;
    } catch (e) {
      print("SignUp Error: $e");
      return false;
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }

  Future<String?> getCurrentUser() async {
    return _auth.currentUser?.uid;
  }

  Future<UserCredential?> signInWithGoogleWeb() async {
    try {
      if (!kIsWeb) throw Exception("signInWithGoogleWeb hanya untuk Web");
      GoogleAuthProvider googleProvider = GoogleAuthProvider();
      googleProvider.setCustomParameters({'prompt': 'select_account'});
      return await _auth.signInWithPopup(googleProvider);
    } catch (e) {
      print("Google Sign-In Web Error: $e");
      return null;
    }
  }
}
