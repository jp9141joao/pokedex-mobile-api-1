import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firebase_options.dart';
import 'package:mobileproject/pages/login_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: const FirebaseOptions(
        apiKey: "AIzaSyDiX3KHE9R6C8RvABxZYjtF1zy56mUVhxY",
        authDomain: "mobile-project-7a5ed.firebaseapp.com",
        projectId: "mobile-project-7a5ed",
        storageBucket: "mobile-project-7a5ed.firebasestorage.app",
        messagingSenderId: "858792678747",
        appId: "1:858792678747:web:05ffb1a5d2a6239fe6b67e"),
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: LoginPage(),
    );
  }
}
