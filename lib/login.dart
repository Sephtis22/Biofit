import 'package:flutter/material.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';
import 'register.dart'; // Ensure this import is correct
import 'database_helper.dart';
import 'teendashboard.dart'; // Import TeenDashboard
import 'olddashboard.dart'; // Import TeenDashboard
import 'addultdashboard.dart'; // Import TeenDashboard
import 'package:shared_preferences/shared_preferences.dart'; // For SharedPreferences

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  LoginScreenState createState() => LoginScreenState();
}

class LoginScreenState extends State<LoginScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;

  Future<void> _login() async {
  setState(() {
    _isLoading = true;
    _errorMessage = null;
  });

  final username = _usernameController.text.trim();
  final password = _passwordController.text.trim();

  if (username.isEmpty || password.isEmpty) {
    setState(() {
      _errorMessage = "Please enter both username and password.";
      _isLoading = false;
    });
    return;
  }

  final dbHelper = DatabaseHelper.instance;
  final user = await dbHelper.getUser(username);

  if (user != null) {
    final hashedPassword = sha256.convert(utf8.encode(password)).toString();
    if (user['password'] == hashedPassword) {
      final age = user['age'];

      if (age == null) {
        setState(() {
          _errorMessage = "Age data is missing. Please contact support.";
          _isLoading = false;
        });
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Login successful!")),
      );

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('username', username);

      // Navigate to correct dashboard based on age
      Widget targetScreen;
      if (age >= 9 && age <= 17) {
        targetScreen = TeenDashboard(username: username);
      } else if (age >= 18 && age <= 59) {
        targetScreen = AdultDashboard(username: username);
      } else if (age >= 60 && age <= 100) {
        targetScreen = OldDashboard(username: username);
      } else {
        setState(() {
          _errorMessage = "Invalid age range.";
          _isLoading = false;
        });
        return;
      }

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => targetScreen),
      );
    } else {
      setState(() {
        _errorMessage = "Invalid username or password.";
        _isLoading = false;
      });
    }
  } else {
    setState(() {
      _errorMessage = "User not found.";
      _isLoading = false;
    });
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.fitness_center, size: 80, color: Colors.deepPurple),
              const SizedBox(height: 10),
              const Text(
                "Welcome Back!",
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.deepPurple),
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 10,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    TextField(
                      controller: _usernameController,
                      decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.person, color: Colors.deepPurple),
                        labelText: "Username",
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                    const SizedBox(height: 15),
                    TextField(
                      controller: _passwordController,
                      obscureText: true,
                      decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.lock, color: Colors.deepPurple),
                        labelText: "Password",
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                    if (_errorMessage != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 10),
                        child: Text(
                          _errorMessage!,
                          style: const TextStyle(color: Colors.red),
                        ),
                      ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepPurple,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      onPressed: _isLoading ? null : _login,
                      child: _isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text("Login", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Don't have an account?", style: TextStyle(fontSize: 16, color: Colors.black54)),
                  const SizedBox(width: 5),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const RegisterScreen()),
                      );
                    },
                    child: const Text(
                      "Register",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.deepPurple,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
