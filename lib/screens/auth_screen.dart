import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:supabase_auth_ui/supabase_auth_ui.dart';

class AuthScreen extends StatelessWidget {
  const AuthScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(24.0, 40.0, 24.0, 24.0),
          children: [
            Column(
              children: [
                const Text(
                  'Reimbursement Box',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 24,
                  ),
                ),
                const SizedBox(height: 32.0),
                SupaEmailAuth(
                  redirectTo: kIsWeb 
                      ? 'http://localhost:3000/'
                      : 'io.supabase.reimbursementbox://login-callback/',
                  onSignInComplete: (res) => Navigator.pushReplacementNamed(context, '/home'),
                  onSignUpComplete: (res) => Navigator.pushReplacementNamed(context, '/home'),
                  onError: (error) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(error.toString()),
                        backgroundColor: Colors.red,
                      )
                    );
                  },
                ),
                const SizedBox(height: 20.0),
                const Divider(),
                const SizedBox(height: 12.0),
                const Text(
                  'Or continue with',
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 12.0),
                if (kIsWeb) // Only show social auth on web for now
                  SupaSocialsAuth(
                    socialProviders: const [
                      OAuthProvider.google,
                      OAuthProvider.github,
                    ],
                    colored: true,
                    redirectUrl: 'http://localhost:3000/',
                    onSuccess: (session) {
                      Navigator.pushReplacementNamed(context, '/home');
                    },
                    onError: (error) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(error.toString()),
                          backgroundColor: Colors.red,
                        )
                      );
                    },
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
} 