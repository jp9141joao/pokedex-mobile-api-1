import 'package:flutter/material.dart'; // Flutter framework for UI components
import 'package:google_fonts/google_fonts.dart'; // For custom Google Fonts
import 'package:firebase_auth/firebase_auth.dart'; // Firebase Authentication
import 'package:mobileproject/pages/register_page.dart'; // Registration page

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  // Controllers to capture the input from text fields
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false; // Tracks whether a login attempt is in progress

  // Validate email and password fields
  bool _validateFields() {
    // If email is empty or does not contain '@', show an error message
    if (_emailController.text.isEmpty || !_emailController.text.contains('@')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invalid email')),
      );
      return false;
    }
    // If password length is less than 6, show an error message
    if (_passwordController.text.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Password must be at least 6 characters')),
      );
      return false;
    }
    return true; // All fields are valid
  }

  // Attempt to sign in the user with Firebase Auth
  Future<void> _login() async {
    // First, validate the fields; if invalid, exit early
    if (!_validateFields()) return;

    setState(() => _isLoading = true); // Show loading indicator

    try {
      // Sign in user with email and password in Firebase
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
      // If successful, FirebaseAuth will update the auth state stream and navigate automatically
    } on FirebaseAuthException catch (e) {
      String errorMessage = 'Unknown error';
      // If the user is not found or password is wrong, update the error message
      if (e.code == 'user-not-found' || e.code == 'wrong-password') {
        errorMessage = 'Incorrect email or password';
      }
      // Show the error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMessage)),
      );
    } finally {
      // Stop showing the loading indicator if still mounted
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // Page title with custom Google Font
        title: Text('Rick and Morty Login', style: GoogleFonts.lato()),
        centerTitle: true, // Center the title text
      ),
      body: Padding(
        padding: const EdgeInsets.all(24), // Add padding around the form
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center, // Center the form vertically
          children: [
            // Email input field
            TextField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(labelText: 'Email'),
            ),
            const SizedBox(height: 16), // Vertical spacing
            // Password input field
            TextField(
              controller: _passwordController,
              obscureText: true, // Hide the password as it's typed
              decoration: const InputDecoration(labelText: 'Password'),
            ),
            const SizedBox(height: 24), // Vertical spacing before button
            ElevatedButton(
              onPressed: _isLoading ? null : _login, // Disable button if loading
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(50), // Make button full-width
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12), // Rounded corners
                ),
              ),
              // Show a loading spinner if logging in, otherwise show "Login"
              child: _isLoading
                  ? const CircularProgressIndicator()
                  : const Text('Login'),
            ),
            const SizedBox(height: 12), // Spacing before registration link
            // Button to navigate to the registration page
            TextButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const RegisterPage()),
              ),
              child: const Text('Create Account'),
            ),
          ],
        ),
      ),
    );
  }
}
