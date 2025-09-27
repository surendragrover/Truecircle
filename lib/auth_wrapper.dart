
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:truecircle/pages/gift_marketplace_page.dart';
import 'package:truecircle/pages/login_signup_page.dart';
import 'package:truecircle/services/auth_service.dart';

// This widget acts as a gatekeeper, showing the correct page based on auth state.
class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final AuthService _authService = AuthService();

    return StreamBuilder<User?>(
      stream: _authService.userStream, // Listens to the auth state
      builder: (context, snapshot) {
        // Show a loading screen while checking auth state
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        // If the user is logged in, show the main app (GiftMarketplacePage)
        if (snapshot.hasData) {
          return const GiftMarketplacePage();
        }

        // If the user is not logged in, show the Login/Signup page
        return const LoginSignupPage();
      },
    );
  }
}
