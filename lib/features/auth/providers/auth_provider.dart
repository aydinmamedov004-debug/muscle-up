import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final firebaseAuthProvider = Provider<FirebaseAuth>((ref) {
  return FirebaseAuth.instance;
});

final authStateProvider = StreamProvider<User?>((ref) {
  return ref.watch(firebaseAuthProvider).authStateChanges();
});

class AuthException implements Exception {
  final String message;

  const AuthException(this.message);
}

class AuthController {
  final FirebaseAuth _auth;

  const AuthController(this._auth);

  Future<void> signUp({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      await credential.user?.updateDisplayName(name);
      await credential.user?.reload();
    } on FirebaseAuthException catch (e) {
      throw AuthException(_message(e));
    }
  }

  Future<void> signIn({
    required String email,
    required String password,
  }) async {
    try {
      await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      throw AuthException(_message(e));
    }
  }

  Future<void> signOut() => _auth.signOut();

  String _message(FirebaseAuthException e) {
    switch (e.code) {
      case 'email-already-in-use':
        return "An account already exists for that email.";
      case 'invalid-email':
        return "That email address looks invalid.";
      case 'weak-password':
        return "Choose a stronger password (6+ characters).";
      case 'user-not-found':
      case 'wrong-password':
      case 'invalid-credential':
        return "Incorrect email or password.";
      case 'configuration-not-found':
        return "Email/password sign-in isn't enabled for this project yet.";
      default:
        return e.message ?? "Something went wrong. Please try again.";
    }
  }
}

final authControllerProvider = Provider<AuthController>((ref) {
  return AuthController(ref.watch(firebaseAuthProvider));
});
