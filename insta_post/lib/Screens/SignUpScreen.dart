import 'package:flutter/material.dart';
import 'package:insta_post/network.dart';
import 'package:insta_post/validation.dart';
import 'package:fluttertoast/fluttertoast.dart';

class SignUpScreen extends StatefulWidget {
  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  TextEditingController firstNameController = TextEditingController();
  TextEditingController lastNameController = TextEditingController();
  TextEditingController nickNameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  String nickNameValidationString;
  String emailValidationString;
  var _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    tryToPost();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Form(
          key: _formKey,
          child: Padding(
            padding: EdgeInsets.all(0.0),
            child: ListView(
              children: <Widget>[
                BackgroundWidget(),
                SizedBox(
                  height: 20,
                ),
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Row(
                    children: <Widget>[
                      IconButton(icon: Icon(Icons.person), onPressed: null),
                      Expanded(
                          child: Container(
                              margin: EdgeInsets.only(right: 20, left: 10),
                              child: TextFormField(
                                  decoration:
                                      InputDecoration(hintText: 'First Name'),
                                  controller: firstNameController,
                                  validator: (String enteredFirstName) {
                                    return validateFirstName(enteredFirstName);
                                  }))),
                      Expanded(
                          child: Container(
                              margin: EdgeInsets.only(right: 20, left: 10),
                              child: TextFormField(
                                  decoration:
                                      InputDecoration(hintText: 'Last Name'),
                                  controller: lastNameController,
                                  validator: (String enteredLastName) {
                                    return validateLastName(enteredLastName);
                                  }))),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Row(
                    children: <Widget>[
                      IconButton(icon: Icon(Icons.face), onPressed: null),
                      Expanded(
                          child: Container(
                              margin: EdgeInsets.only(right: 20, left: 10),
                              child: TextFormField(
                                  decoration:
                                      InputDecoration(hintText: 'Nick Name'),
                                  controller: nickNameController,
                                  validator: (String enteredNickName) {
                                    return nickNameValidationString;
                                  })))
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Row(
                    children: <Widget>[
                      IconButton(icon: Icon(Icons.mail), onPressed: null),
                      Expanded(
                          child: Container(
                              margin: EdgeInsets.only(right: 20, left: 10),
                              child: TextFormField(
                                  decoration:
                                      InputDecoration(hintText: 'Email'),
                                  controller: emailController,
                                  keyboardType: TextInputType.emailAddress,
                                  validator: (String enteredEmail) {
                                    return emailValidationString;
                                  })))
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Row(
                    children: <Widget>[
                      IconButton(icon: Icon(Icons.lock), onPressed: null),
                      Expanded(
                          child: Container(
                              margin: EdgeInsets.only(right: 20, left: 10),
                              child: TextFormField(
                                  decoration:
                                      InputDecoration(hintText: 'Password'),
                                  controller: passwordController,
                                  obscureText: true,
                                  validator: (String enteredPassword) {
                                    return validatePassword(enteredPassword);
                                  })))
                    ],
                  ),
                ),

                Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Container(
                      height: 60,
                      child: RaisedButton(
                        color: Colors.grey,
                        onHighlightChanged: (bool) {
                          Fluttertoast.showToast(
                              msg: 'Checking Fields! Please wait a moment.',
                              toastLength: Toast.LENGTH_SHORT,
                              gravity: ToastGravity.TOP,
                              backgroundColor: Colors.redAccent,
                              textColor: Colors.white);
                        },
                        onPressed: () async {
                          emailValidationString =
                              await validateEmail(emailController.text);
                          nickNameValidationString =
                              await validateNickName(nickNameController.text);
                          if (_formKey.currentState.validate()) {
                            newUser(
                                firstNameController.text,
                                lastNameController.text,
                                nickNameController.text,
                                emailController.text,
                                passwordController.text
                            );
                            Fluttertoast.showToast(
                                msg:
                                'Account successfully created! Login to continue.',
                                toastLength: Toast.LENGTH_SHORT,
                                gravity: ToastGravity.TOP,
                                backgroundColor: Colors.lightGreen,
                                textColor: Colors.white);
                            Navigator.pop(context);
                          }
                          setState(() {
                          });
                        },
                        child: Text(
                          'SIGN UP',
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 20),
                        ),
                      ),
                    )),
              ],
            ),
          ),
        ));
  }
}

class BackgroundWidget extends StatelessWidget {
  const BackgroundWidget({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 200,
      decoration: BoxDecoration(
          image: DecorationImage(
              fit: BoxFit.cover,
              image: AssetImage('asset/images/abstract.png'))),
      child: Padding(
        padding: const EdgeInsets.only(top: 150.0),
        child: Text(
          'Create New Account',
          style: TextStyle(
               fontWeight: FontWeight.bold, fontSize: 18),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
