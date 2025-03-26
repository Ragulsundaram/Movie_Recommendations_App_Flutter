import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _obscureText = true;
  final _authService = AuthService();
  
  // Add controllers
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF2C302E), // Jet color
      appBar: AppBar(
        backgroundColor: const Color(0xFF474A48), // Outer space color
        title: const Text('Sign Up', style: TextStyle(color: Color(0xFF9AE19D))), // Celadon color
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Create Account',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF9AE19D), // Celadon color
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Sign up to get started',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: const Color(0xFF909590), // Battleship gray
                      ),
                ),
                const SizedBox(height: 50),
                // Update TextFormFields to use controllers
                TextFormField(
                  controller: _nameController,  // Add this
                  style: const TextStyle(color: Color(0xFF9AE19D)),
                  decoration: InputDecoration(
                    labelText: 'Full Name',
                    labelStyle: const TextStyle(color: Color(0xFF909590)), // Battleship gray
                    prefixIcon: const Icon(Iconsax.user, size: 20, color: Color(0xFF537A5A)), // Fern green
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFF537A5A)), // Fern green
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFF537A5A)), // Fern green
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _emailController,  // Add this
                  style: const TextStyle(color: Color(0xFF9AE19D)),
                  decoration: InputDecoration(
                    labelText: 'Email',
                    labelStyle: const TextStyle(color: Color(0xFF909590)), // Battleship gray
                    prefixIcon: const Icon(Iconsax.sms, size: 20, color: Color(0xFF537A5A)), // Fern green
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFF537A5A)), // Fern green
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFF537A5A)), // Fern green
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your email';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _passwordController,  // Add this
                  style: const TextStyle(color: Color(0xFF9AE19D)),
                  obscureText: _obscureText,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    labelStyle: const TextStyle(color: Color(0xFF909590)), // Battleship gray
                    prefixIcon: const Icon(Iconsax.lock, size: 20, color: Color(0xFF537A5A)), // Fern green
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscureText ? Iconsax.eye_slash : Iconsax.eye,
                        size: 20,
                        color: const Color(0xFF537A5A), // Fern green
                      ),
                      onPressed: () {
                        setState(() {
                          _obscureText = !_obscureText;
                        });
                      },
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFF537A5A)), // Fern green
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFF537A5A)), // Fern green
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your password';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: // Update the signup button
                  ElevatedButton(
                    onPressed: () async {
                      if (_formKey.currentState!.validate()) {
                        try {
                          // Trim the input values and validate
                          final name = _nameController.text.trim();
                          final email = _emailController.text.trim();
                          final password = _passwordController.text;
                          
                          // Additional validation
                          if (name.isEmpty || email.isEmpty || password.isEmpty) {
                            throw Exception('All fields are required');
                          }
                          
                          final user = User(
                            fullName: name,
                            email: email,
                            password: password,
                          );
                          
                          await _authService.signUp(user);
                          
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Sign up successful!')),
                            );
                            Navigator.pop(context);
                          }
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(e.toString())),
                          );
                        }
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF537A5A), // Fern green
                      foregroundColor: const Color(0xFF9AE19D), // Celadon color
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('Sign Up'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}