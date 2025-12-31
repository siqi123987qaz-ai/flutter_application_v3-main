import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';


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

  Future<void> handleFacebookLogin() async {

    print('Login with Facebook - To be implemented');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(isLogin ? 'Login' : 'Register')),
      body: Padding(
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

            Row(
              children: [
                Expanded(
                  child:Divider(
                    color: Colors.grey.shade300,
                    thickness: 1,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Text(
                    'OR',
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                Expanded(
                  child: Divider(
                    color: Colors.grey.shade300,
                    thickness: 1,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: handleFacebookLogin,
              icon: const Icon(Icons.facebook, color: Colors.white),
              label: const Text('Login with Facebook'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1877F2),
                foregroundColor: Colors.white,
              ),
            ),







            if (error.isNotEmpty)
              Text(error,
                  style: const TextStyle(color: Colors.red, fontSize: 12)),
          ],
        ),
      ),
    );
  }
}
