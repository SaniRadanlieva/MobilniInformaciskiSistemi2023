import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'exam_schedule_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _isLoginMode = true;

  Future<void> _authenticate() async {
    try {
      if (_isLoginMode) {
        await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: _emailController.text,
          password: _passwordController.text,
        );
        // Handle successful login
        _showSuccessDialog('Login Successful');
      } else {
        await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: _emailController.text,
          password: _passwordController.text,
        );
        // Handle successful registration
        _showSuccessDialog('Registration Successful');
      }

      // Redirect to exam_schedule_screen.dart on success
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => ExamSchedulingScreen()),
      );
    } catch (e) {
      print('Authentication Error: $e');
      // Handle error (show a snackbar, for example)
    }
  }

  void _showSuccessDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Success'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Exam Scheduling App',
              style: TextStyle(
                fontSize: 20.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 50.0),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _isLoginMode = true;
                });
              },
              style: ElevatedButton.styleFrom(
                fixedSize: Size(200.0, 50.0),
                primary: _isLoginMode ? Colors.lightBlueAccent : Colors.grey,
              ),
              child: Text('Login'),
            ),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _isLoginMode = false;
                });
              },
              style: ElevatedButton.styleFrom(
                fixedSize: Size(200.0, 50.0),
                primary: !_isLoginMode ? Colors.lightBlueAccent : Colors.grey,
              ),
              child: Text('Register'),
            ),
            SizedBox(height: 16.0),
            TextFormField(
              controller: _emailController,
              decoration: InputDecoration(labelText: 'Email'),
              keyboardType: TextInputType.emailAddress,
            ),
            SizedBox(height: 16.0),
            TextFormField(
              controller: _passwordController,
              decoration: InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () => _authenticate(),
              style: ElevatedButton.styleFrom(
                fixedSize: Size(200.0, 50.0),
              ),
              child: Text(_isLoginMode ? 'Login' : 'Register'),
            ),
          ],
        ),
      ),
    );
  }
}
