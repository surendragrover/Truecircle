
import 'package:firebase_auth/firebase_auth.dart';

// This service will handle all user authentication logic (login, signup, logout).
class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // A stream to listen to the user's authentication state in real-time.
  Stream<User?> get userStream => _auth.authStateChanges();

  // A helper to get the current logged-in user's ID.
  String? get currentUserId => _auth.currentUser?.uid;

  // Sign up a new user with email and password.
  Future<UserCredential?> signUp({required String email, required String password}) async {
    try {
      return await _auth.createUserWithEmailAndPassword(email: email, password: password);
    } on FirebaseAuthException catch (e) {
      // This will catch errors like 'email-already-in-use'.
      print('Signup Error: ${e.message}');
      return null;
    }
  }

  // Sign in an existing user.
  Future<UserCredential?> signIn({required String email, required String password}) async {
    try {
      return await _auth.signInWithEmailAndPassword(email: email, password: password);
    } on FirebaseAuthException catch (e) {
      // This will catch errors like 'user-not-found' or 'wrong-password'.
      print('Signin Error: ${e.message}');
      return null;
    }
  }

  // Sign out the current user.
  Future<void> signOut() async {
    await _auth.signOut();
  }
}
