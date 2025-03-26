import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'signup_screen.dart';
import '../services/auth_service.dart';
import 'wizard/movie_selection_screen.dart';
import '../services/taste_profile_service.dart';
import 'home/home_screen.dart';  // Add this import

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _obscureText = true;
  bool _isLoading = false;  // Add this
  final _authService = AuthService();
  final _tasteProfileService = TasteProfileService();  // Add this
  
  // Add controllers
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() => _isLoading = true);
      try {
        final email = _emailController.text.trim();
        final password = _passwordController.text;
        
        if (email.isEmpty || password.isEmpty) {
          throw Exception('Email and password are required');
        }
        
        final user = await _authService.login(email, password);
        
        if (mounted) {
          // Check if user has a taste profile
          final hasProfile = await _tasteProfileService.hasProfile(user.email);
          
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Welcome back, ${user.fullName}!')),
          );

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => hasProfile 
                ? HomeScreen(userId: user.email)
                : MovieSelectionScreen(userId: user.email),
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Login failed: $e')),
          );
        }
      } finally {
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF2C302E), // Jet color
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 50),
                Text(
                  'Welcome Back!',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF9AE19D), // Celadon color
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Sign in to continue',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: const Color(0xFF909590), // Battleship gray
                      ),
                ),
                const SizedBox(height: 50),
                // Update TextFormFields to use controllers
                TextFormField(
                  controller: _emailController,  // Add this
                  style: const TextStyle(color: Color(0xFF9AE19D)),
                  decoration: InputDecoration(
                    labelText: 'Email',
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
                  child: // Update the login button
                  ElevatedButton(
                    onPressed: _isLoading ? null : _handleLogin,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF537A5A),
                      foregroundColor: const Color(0xFF9AE19D),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: _isLoading 
                      ? const CircularProgressIndicator(color: Color(0xFF9AE19D))
                      : const Text('Login'),
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Don't have an account?",
                      style: TextStyle(color: const Color(0xFF909590)), // Battleship gray
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const SignupScreen(),
                          ),
                        );
                      },
                      style: TextButton.styleFrom(
                        foregroundColor: const Color(0xFF9AE19D), // Celadon color
                      ),
                      child: const Text('Sign Up'),
                    ),
                  ],
                ),
                // Add this near your login button
                TextButton(
                  onPressed: () async {
                    await _authService.clearStorage();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Storage cleared')),
                    );
                  },
                  child: const Text('Clear Storage'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}