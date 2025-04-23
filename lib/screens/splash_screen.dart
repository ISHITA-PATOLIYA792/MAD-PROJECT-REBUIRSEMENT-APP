import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/foundation.dart';
// Conditional import for web platform
import 'web_utils.dart' if (dart.library.html) 'dart:html' as html;

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final supabase = Supabase.instance.client;
  
  @override
  void initState() {
    super.initState();
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    try {
      // Add a small delay to allow Supabase to initialize properly
      await Future.delayed(const Duration(milliseconds: 1000));
      
      // Handle deep link authentication if needed
      if (kIsWeb) {
        final session = supabase.auth.currentSession;
        if (session != null) {
          // Already authenticated, go to home
          if (mounted) {
            Navigator.pushReplacementNamed(context, '/home');
          }
          return;
        }
        
        // Check if we're in the middle of an OAuth redirect
        String currentUrl = '';
        try {
          // This code only runs on web
          if (kIsWeb) {
            currentUrl = html.window.location.href;
          }
          final Uri? uri = Uri.tryParse(currentUrl);
          if (uri != null && uri.queryParameters.containsKey('code')) {
            // Show loading while we handle the redirect
            return;
          }
        } catch (e) {
          // Ignore on non-web platforms
        }
      }
      
      // Check if user is already authenticated
      final session = supabase.auth.currentSession;
      if (session != null) {
        // Already authenticated, go to home
        if (mounted) {
          Navigator.pushReplacementNamed(context, '/home');
        }
      } else {
        // Not authenticated, go to onboarding
        if (mounted) {
          Navigator.pushReplacementNamed(context, '/onboarding');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error during auth check: $e');
      }
      // On error, default to onboarding
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/onboarding');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const FlutterLogo(size: 100),
            const SizedBox(height: 24),
            const Text(
              'Reimbursement Box',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 24,
              ),
            ),
            const SizedBox(height: 24),
            const CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
} 