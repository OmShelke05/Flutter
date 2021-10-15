import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:insta_post/network.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'HomeScreen.dart';

class SignInScreen extends StatefulWidget {
  @override
  _SignInScreenState createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {

  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    tryToPost();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        children: <Widget>[
          Container(
            height: 300,
            decoration: BoxDecoration(
                image: DecorationImage(
                    fit: BoxFit.cover,
                    image: AssetImage('asset/images/abstract.png'))),
              child: Padding(
                  padding: const EdgeInsets.only(top: 100.0),
                  child: Text(
                    'Insta Post',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 45,
                    fontFamily: 'Georgia'),
                  ),
                ),
          ),
          SizedBox(
            height: 20,
          ),
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Row(
              children: <Widget>[
                IconButton(icon: Icon(Icons.email_outlined), onPressed: null),
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
                          decoration: InputDecoration(hintText: 'Password'),
                          controller: passwordController,
                          obscureText: true,
                        ))),
              ],
            ),
          ),
          SizedBox(
            height: 10,
          ),
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(5),
              child: Container(
                height: 60,
                child: RaisedButton(
                  onPressed: () async {
                    bool authenticationResult= await authenticateUser(emailController.text,passwordController.text);

                     if(authenticationResult==true){
                       saveData();
                       Navigator.push(
                           context,
                           MaterialPageRoute(
                               builder: (context) =>
                                   HomeScreen(emailController.text,passwordController.text)));
                      Navigator.pushNamed(context, 'Home');
                    setState(() {
                    });}
                     else{
                       Fluttertoast.showToast(
                           msg:
                           'Log in failed! Please try again.',
                           fontSize: 18.0,
                           toastLength: Toast.LENGTH_SHORT,
                           gravity: ToastGravity.BOTTOM,
                           backgroundColor: Colors.red,
                           textColor: Colors.white);
                     }
                  },
                  color: Colors.grey,
                  child: Text(
                    'Log In',
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20),
                  ),
                ),
              ),
            ),
          ),
          SizedBox(
            height: 10,
          ),
          InkWell(
            onTap: () {
              Navigator.pushNamed(context, 'SignUp');
            },
            child: Center(
              child: RichText(
                text: TextSpan(
                    text: 'Don\'t have an account?  ',
                    style: TextStyle( fontSize: 15.0),
                    children: [
                      TextSpan(
                        text: 'Sign Up',
                        style: TextStyle(

                            fontWeight: FontWeight.bold,
                            fontSize: 20.0),
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
    saveDataPreference(userEmail,userPassword);
  }

  Future saveDataPreference(userEmail, userPassword) async {
    SharedPreferences preferencesInstance =
    await SharedPreferences.getInstance();
    preferencesInstance.setString("userEmail", userEmail);
    preferencesInstance.setString("userPassword", userPassword);
  }
}
