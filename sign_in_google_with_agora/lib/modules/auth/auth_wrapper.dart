import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'views/login_view.dart';
import 'views/home_screen.dart';
import 'bindings/auth_binding.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }

        // Ensure auth dependencies are registered for both flows
        AuthBinding().dependencies();

        if (snapshot.hasData && snapshot.data != null) {
          return const HomeScreen();
        }

        return const LoginView();
      },
    );
  }
}
