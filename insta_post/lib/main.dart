import 'dart:io';

import 'package:flutter/material.dart';
import 'package:insta_post/Screens/HomeScreen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'Screens/SignInScreen.dart';
import 'Screens/SignUpScreen.dart';
import 'network.dart';

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}

Future<void> main() async {
  HttpOverrides.global = new MyHttpOverrides();
  WidgetsFlutterBinding.ensureInitialized();
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String userEmail = prefs.getString('userEmail');
  String userPassword = prefs.getString('userPassword');

  tryToPost();

  runApp(MaterialApp(
      debugShowCheckedModeBanner: false,
        theme: ThemeData.dark(),
      home: userEmail == null
          ? new MyApp()
          : HomeScreen(userEmail, userPassword)));
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Start Up Screen ',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(),
      initialRoute: 'SignIn',
      routes: {
        'SignIn': (context) => SignInScreen(),
        'SignUp': (context) => SignUpScreen(),
      },
    );
  }
}
