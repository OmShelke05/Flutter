import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:todo_app/services/auth.dart';
import 'HomeScreen.dart';

// This screen is the logIn screen.
// User can enter login credentials to proceed to home screen.
// New users have an option to Sign Up.
// If any user forgets password, Forgot Password Functionality is provided which sends the reset link to registered mail address.

class SignInScreen extends StatefulWidget {
  @override
  _SignInScreenState createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  bool isLoading = false;
  AuthMethods authMethods = new AuthMethods();

  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    Firebase.initializeApp().whenComplete(() {
      setState(() {});
    });
  }

  signIn() {
    setState(() {
      isLoading = true;
    });
    authMethods
        .signInWithEmailAndPassword(
            emailController.text, passwordController.text)
        .then((val) {
      if (val == null) {
        Fluttertoast.showToast(
            msg: 'Invalid email/password. Please try again!',
            toastLength: Toast.LENGTH_LONG,
            gravity: ToastGravity.BOTTOM,
            backgroundColor: Colors.red,
            textColor: Colors.white);
        setState(() {
          isLoading = false;
        });
      } else {
        print(val);
        saveData();
        Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (context) => HomeScreen(emailController.text)));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: isLoading
          ? Container(child: Center(child: CircularProgressIndicator()))
          : ListView(
              children: <Widget>[
                SizedBox(
                  height: 10,
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 30),
                  child: Container(
                    height: 300,
                    alignment: Alignment.topCenter,
                    decoration: BoxDecoration(
                        image: DecorationImage(
                            fit: BoxFit.contain,
                            image: AssetImage('assets/images/note.png'))),
                    child: Padding(
                      padding: const EdgeInsets.only(top: 40, right: 40),
                      child: Text(
                        'To Do',
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 32,
                            fontFamily: 'Georgia'),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Row(
                    children: <Widget>[
                      IconButton(
                          icon: Icon(Icons.email_outlined), onPressed: null),
                      Expanded(
                          child: Container(
                              margin: EdgeInsets.only(right: 20, left: 10),
                              child: TextField(
                                decoration: InputDecoration(hintText: 'Email'),
                                controller: emailController,
                                keyboardType: TextInputType.emailAddress,
                              )))
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Row(
                    children: <Widget>[
                      IconButton(icon: Icon(Icons.lock), onPressed: null),
                      Expanded(
                          child: Container(
                              margin: EdgeInsets.only(right: 20, left: 10),
                              child: TextField(
                                decoration:
                                    InputDecoration(hintText: 'Password'),
                                controller: passwordController,
                                obscureText: true,
                              ))),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(5),
                    child: Container(
                      height: 60,
                      child: RaisedButton(
                        color: Colors.deepPurple,
                        onPressed: () {
                          signIn();
                          print('Login pressed');
                        },
                        child: Text(
                          'Log In',
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 20),
                        ),
                      ),
                    ),
                  ),
                ),
                InkWell(
                  onTap: () {
                    Navigator.pushNamed(context, 'ForgotPassword');
                  },
                  child: Center(
                    child: RichText(
                      text: TextSpan(
                        text: 'Forgot password?  ',
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                            fontSize: 15.0),
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                InkWell(
                  onTap: () {
                    Navigator.pushNamed(context, 'SignUp');
                  },
                  child: Center(
                    child: RichText(
                      text: TextSpan(
                          text: 'Don\'t have an account?  ',
                          style: TextStyle(color: Colors.black, fontSize: 15.0),
                          children: [
                            TextSpan(
                              text: 'Sign Up',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 20.0),
                            )
                          ]),
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  void saveData() {
    String userEmail = emailController.text;
    String userPassword = passwordController.text;
    saveDataPreference(userEmail, userPassword);
  }

  Future saveDataPreference(userEmail, userPassword) async {
    SharedPreferences preferencesInstance =
        await SharedPreferences.getInstance();
    preferencesInstance.setString("userEmail", userEmail);
    preferencesInstance.setString("userPassword", userPassword);
  }
}
