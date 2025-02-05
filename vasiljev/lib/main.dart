import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';

// Import screens
import 'package:vasiljev/registration/register_screen.dart';
import 'package:vasiljev/login/login_screen.dart';
import 'package:vasiljev/home/home_screen.dart';
import 'package:vasiljev/book/book_screen.dart';
import 'package:vasiljev/profile/profile_screen.dart';
import 'package:vasiljev/profile/edit_profile_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(VasiljevSalonApp());
}

class VasiljevSalonApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Vasiljev Salon',
      theme: ThemeData(
        primarySwatch: Colors.amber,
        scaffoldBackgroundColor: Colors.black,
        textTheme: const TextTheme(
          bodyLarge: TextStyle(color: Colors.white),
        ),
      ),
      home: AuthHandler(), // AuthHandler checks if the user is logged in
      routes: {
        '/login': (context) => LoginScreen(),
        '/registration': (context) => RegisterScreen(),
        '/home': (context) => HomeScreen(),
        '/book': (context) => BookScreen(),
        '/profile': (context) => ProfileScreen(),
        '/edit_profile': (context) => EditProfileScreen(),
      },
    );
  }
}

class AuthHandler extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasData) {
          return HomeScreen(); // Redirect to HomeScreen if logged in
        } else {
          return LoginScreen(); // Show login screen if not logged in
        }
      },
    );
  }
}
