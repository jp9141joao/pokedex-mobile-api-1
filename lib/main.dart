import 'package:flutter/material.dart'; // Flutter framework for UI components
import 'package:firebase_core/firebase_core.dart'; // Core Firebase initialization
import 'package:firebase_auth/firebase_auth.dart'; // Firebase Authentication
import 'package:mobileproject/pages/login_page.dart'; // Login screen
import 'package:mobileproject/pages/characters_page.dart'; // Characters list screen

void main() async {
  // Ensure Flutter bindings are initialized before using any plugins
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase with the given configuration options
  await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: "AIzaSyDiX3KHE9R6C8RvABxZYjtF1zy56mUVhxY",
      authDomain: "mobile-project-7a5ed.firebaseapp.com",
      projectId: "mobile-project-7a5ed",
      storageBucket: "mobile-project-7a5ed.firebasestorage.app",
      messagingSenderId: "858792678747",
      appId: "1:858792678747:web:05ffb1a5d2a6239fe6b67e",
    ),
  );

  // Run the root widget of the application
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false, // Disable debug banner
      theme: ThemeData(
        // Generate a ColorScheme from a seed color (teal)
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
        useMaterial3: true, // Enable Material 3 design
      ),
      home: StreamBuilder<User?>(
        // Listen to Firebase Authentication state changes
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          // While checking the authentication state, show a loading indicator
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }
          // If the user is authenticated (snapshot.hasData == true), show the CharactersPage
          if (snapshot.hasData) {
            return const CharactersPage();
          }
          // If no user is authenticated, show the LoginPage
          return const LoginPage();
        },
      ),
    );
  }
}
