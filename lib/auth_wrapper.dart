import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:truecircle/pages/login_signup_page.dart';
import 'package:truecircle/services/auth_service.dart';
import 'initialization_wrapper.dart'; // पहले यहाँ 'home_page.dart' था

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context, listen: false);

    return StreamBuilder<User?>(
      stream: authService.userStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.active) {
          final User? user = snapshot.data;
          if (user == null) {
            return const LoginSignupPage();
          }
          // यदि उपयोगकर्ता लॉग इन है, तो उसे सीधे होम पेज पर न भेजें।
          // पहले "जैकेट" (InitializationWrapper) पर भेजें ताकि सब कुछ लोड हो सके।
          return const InitializationWrapper();
        }
        return const Scaffold(
          body: Center(
            child: CircularProgressIndicator(),
          ),
        );
      },
    );
  }
}
