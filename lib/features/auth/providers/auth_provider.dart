import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final firebaseAuthProvider = Provider<FirebaseAuth>((ref) {
  return FirebaseAuth.instance;
});

final authStateProvider = StreamProvider<User?>((ref) {
  return ref.watch(firebaseAuthProvider).authStateChanges();
});

/// True while signed in as a guest (Firebase anonymous auth) rather than a
/// real account — drives the "Continue as Guest" limitations messaging.
final isGuestProvider = Provider<bool>((ref) {
  return ref.watch(authStateProvider).value?.isAnonymous ?? false;
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

  /// Signs in as a guest via Firebase anonymous auth. The resulting user is
  /// a real (if anonymous) Firebase user, so everything else in the app —
  /// Coach, Settings, onboarding — works exactly as it does for a full
  /// account. The data is fully functional but device-local only until the
  /// guest upgrades via [upgradeGuestAccount].
  Future<void> signInAsGuest() async {
    try {
      await _auth.signInAnonymously();
    } on FirebaseAuthException catch (e) {
      throw AuthException(_message(e));
    }
  }

  /// Converts the current guest session into a real account by attaching an
  /// email/password credential to the same Firebase user — this preserves
  /// the user's UID (and therefore all their local data, which was never
  /// keyed separately) rather than creating a new account from scratch.
  Future<void> upgradeGuestAccount({
    required String name,
    required String email,
    required String password,
  }) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw const AuthException("You're not signed in as a guest.");
    }

    try {
      final credential = EmailAuthProvider.credential(
        email: email,
        password: password,
      );
      final userCredential = await user.linkWithCredential(credential);
      await userCredential.user?.updateDisplayName(name);
      await userCredential.user?.reload();
    } on FirebaseAuthException catch (e) {
      throw AuthException(_message(e));
    }
  }

  String _message(FirebaseAuthException e) {
    switch (e.code) {
      case 'email-already-in-use':
      case 'credential-already-in-use':
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
      case 'operation-not-allowed':
        return "Guest mode isn't available right now — please sign in "
            "or create an account instead.";
      case 'provider-already-linked':
        return "This guest session already has an account attached.";
      default:
        return e.message ?? "Something went wrong. Please try again.";
    }
  }
}

final authControllerProvider = Provider<AuthController>((ref) {
  return AuthController(ref.watch(firebaseAuthProvider));
});
