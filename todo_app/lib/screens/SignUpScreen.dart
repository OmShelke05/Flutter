import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:todo_app/services/auth.dart';
import 'HomeScreen.dart';

//This screen Signs Up new user with unique email address.

class SignUpScreen extends StatefulWidget {
  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  bool isLoading = false;

  AuthMethods authMethods = new AuthMethods();
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
    Firebase.initializeApp().whenComplete(() {
      print("completed");
      setState(() {});
    });
  }

  signNewUserUp() {
    if (_formKey.currentState.validate()) {
      setState(() {
        isLoading = true;
      });
      authMethods
          .signUpWithEmailAndPassword(
              emailController.text, passwordController.text)
          .then((val) {
        print(val);
        if (val == null) {
          Fluttertoast.showToast(
              msg: 'Couldn\'t create account!',
              toastLength: Toast.LENGTH_LONG,
              gravity: ToastGravity.BOTTOM,
              backgroundColor: Colors.red,
              textColor: Colors.white);
          setState(() {
            isLoading = false;
          });
        } else {
          saveData();
          Map<String, dynamic> task = {
            "title": "Sample Task",
            "description": "This is the description of the task! Click on the peek icon to go into edit mode. You can swipe to delete this task.",
            "category": "Personal",
            "reminder": DateTime.now(),
            "image": null,
            'createdOn': DateTime.now()
          };
          Map<String, dynamic> userTask = {task['title']: task};
          CollectionReference users = FirebaseFirestore.instance.collection('users');
          DocumentReference currentUser = users.doc(emailController.text);
          currentUser.set(userTask, SetOptions(merge: true));
          Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                  builder: (context) => HomeScreen(emailController.text)));
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: isLoading
            ? Container(child: Center(child: CircularProgressIndicator()))
            : Form(
                key: _formKey,
                child: Padding(
                  padding: EdgeInsets.all(0.0),
                  child: ListView(
                    children: <Widget>[
                      SizedBox(
                        height: 10,
                      ),
                      BackgroundWidget(),
                      SizedBox(
                        height: 10,
                      ),
                      Padding(
                        padding: const EdgeInsets.all(5),
                        child: Text(
                          'Create New User',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 18),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Row(
                          children: <Widget>[
                            IconButton(icon: Icon(Icons.person)),
                            Expanded(
                                child: Container(
                                    margin:
                                        EdgeInsets.only(right: 20, left: 10),
                                    child: TextFormField(
                                        decoration: InputDecoration(
                                            hintText: 'First Name'),
                                        controller: firstNameController,
                                        validator: (String enteredFirstName) {
                                          return enteredFirstName.isEmpty ||
                                                  enteredFirstName.length < 2
                                              ? "Enter valid first name"
                                              : null;
                                        }))),
                            Expanded(
                                child: Container(
                                    margin:
                                        EdgeInsets.only(right: 20, left: 10),
                                    child: TextFormField(
                                        decoration: InputDecoration(
                                            hintText: 'Last Name'),
                                        controller: lastNameController,
                                        validator: (String enteredLastName) {
                                          return enteredLastName.isEmpty ||
                                                  enteredLastName.length < 2
                                              ? "Enter valid last name"
                                              : null;
                                        }))),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Row(
                          children: <Widget>[
                            IconButton(icon: Icon(Icons.face)),
                            Expanded(
                                child: Container(
                                    margin:
                                        EdgeInsets.only(right: 20, left: 10),
                                    child: TextFormField(
                                        decoration: InputDecoration(
                                            hintText: 'Nick Name'),
                                        controller: nickNameController,
                                        validator: (String enteredNickName) {
                                          return enteredNickName.isEmpty ||
                                                  enteredNickName.length < 2
                                              ? "Please provide valid nick name"
                                              : null;
                                        })))
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Row(
                          children: <Widget>[
                            IconButton(icon: Icon(Icons.mail)),
                            Expanded(
                                child: Container(
                                    margin:
                                        EdgeInsets.only(right: 20, left: 10),
                                    child: TextFormField(
                                        decoration:
                                            InputDecoration(hintText: 'Email'),
                                        controller: emailController,
                                        keyboardType:
                                            TextInputType.emailAddress,
                                        validator: (String enteredEmail) {
                                          return RegExp(
                                                      r"^[A-Z0-9a-z._%!$&+-]+@[A-Za-z0-9.-]+\.[A-Za-z]+")
                                                  .hasMatch(enteredEmail)
                                              ? null
                                              : "Please enter valid email";
                                        })))
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Row(
                          children: <Widget>[
                            IconButton(icon: Icon(Icons.lock)),
                            Expanded(
                                child: Container(
                                    margin:
                                        EdgeInsets.only(right: 20, left: 10),
                                    child: TextFormField(
                                      validator: (val) {
                                        return val.length > 6
                                            ? null
                                            : "Password length must be 6+";
                                      },
                                      decoration:
                                          InputDecoration(hintText: 'Password'),
                                      controller: passwordController,
                                      obscureText: true,
                                    )))
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
                                    signNewUserUp();
                                  },
                                  child: Text(
                                    'Sign Up',
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 20),
                                  ),
                                ),
                              ))),
                    ],
                  ),
                ),
              ));
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

class BackgroundWidget extends StatelessWidget {
  const BackgroundWidget({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 30),
      child: Container(
        height: 200,
        decoration: BoxDecoration(
            image: DecorationImage(
                fit: BoxFit.contain,
                image: AssetImage('assets/images/note.png'))),
      ),
    );
  }
}
