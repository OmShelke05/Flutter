import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'screens/ForgotPasswordScreen.dart';
import 'screens/HomeScreen.dart';
import 'screens/SignInScreen.dart';
import 'screens/SignUpScreen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String userEmail = prefs.getString('userEmail');
  runApp(MaterialApp(
      theme: ThemeData(
        primarySwatch: Colors.blueGrey,
      ),
      debugShowCheckedModeBanner: false,
      //Check if user has already loggedIn before and redirect accordingly.
      home: userEmail == null ? new MyApp() : HomeScreen(userEmail)));
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Start Up Screen ',
      debugShowCheckedModeBanner: false,
      initialRoute: 'SignIn',
      routes: {
        'SignIn': (context) => SignInScreen(),
        'SignUp': (context) => SignUpScreen(),
        'ForgotPassword': (context) => ForgotPasswordScreen(),
      },
    );
  }
}
