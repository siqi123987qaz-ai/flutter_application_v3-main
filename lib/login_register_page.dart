import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'auth_service.dart'; // <--- Import the new file

class LoginRegisterPage extends StatefulWidget {
  const LoginRegisterPage({super.key});

  @override
  State<LoginRegisterPage> createState() => _LoginRegisterPageState();
}

class _LoginRegisterPageState extends State<LoginRegisterPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool isLogin = true;
  String error = '';

  // 1. Email/Password Auth
  Future<void> handleAuth() async {
    try {
      if (isLogin) {
        await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );
      } else {
        await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );
      }
    } catch (e) {
      setState(() {
        error = e.toString();
      });
    }
  }

  // 2. NEW: Google Auth Wrapper
  Future<void> handleGoogleLogin() async {
    try {
      // Show a loading message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Connecting to Google..."))
      );

      final user = await AuthService.signInWithGoogle();

      if (user == null) {
         // User cancelled or failed
         ScaffoldMessenger.of(context).showSnackBar(
           const SnackBar(content: Text("Google Login Failed"))
         );
      }
      // Note: If successful, the 'StreamBuilder' in main.dart (AuthGate) 
      // will automatically detect the user and switch to HomePage.
      
    } catch (e) {
      setState(() => error = e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(isLogin ? 'Login' : 'Register')),
      body: SingleChildScrollView( // Added scroll view to prevent overflow
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: 'Email'),
            ),
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Password'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: handleAuth,
              child: Text(isLogin ? 'Login' : 'Register'),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  isLogin = !isLogin;
                  error = '';
                });
              },
              child: Text(isLogin
                  ? 'No account? Register here'
                  : 'Already have an account? Login'),
            ),

            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(child: Divider(color: Colors.grey.shade300, thickness: 1)),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Text('OR', style: TextStyle(color: Colors.grey.shade600)),
                ),
                Expanded(child: Divider(color: Colors.grey.shade300, thickness: 1)),
              ],
            ),
            const SizedBox(height: 20),

            // --- GOOGLE LOGIN BUTTON ---
            SizedBox(
              width: double.infinity,
              height: 50,
              child: OutlinedButton( // Changed from OutlinedButton.icon to OutlinedButton
                style: OutlinedButton.styleFrom(
                  backgroundColor: Colors.white,
                  side: const BorderSide(color: Colors.grey),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                onPressed: handleGoogleLogin,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // THE REAL GOOGLE LOGO
                    Image.asset(
                      'assets/google_logo.png',
                      height: 24, // Standard icon size
                      width: 24,
                    ),
                    const SizedBox(width: 12), // Space between logo and text
                    const Text(
                      'Continue with Google',
                      style: TextStyle(
                        color: Colors.black, 
                        fontSize: 16,
                        fontWeight: FontWeight.w500
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            if (error.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 20.0),
                child: Text(error, style: const TextStyle(color: Colors.red, fontSize: 12)),
              ),
          ],
        ),
      ),
    );
  }
}
