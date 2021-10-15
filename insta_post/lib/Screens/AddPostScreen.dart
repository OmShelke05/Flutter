import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:insta_post/network.dart';
import 'package:insta_post/validation.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AddPostScreen extends StatefulWidget {
  final String userEmail, userPassword;

  AddPostScreen(this.userEmail,this.userPassword);

  @override
  AddPostScreenState createState() => AddPostScreenState(userEmail,userPassword);
}

class AddPostScreenState extends State<AddPostScreen> {

  AddPostScreenState(this.userEmail,this.userPassword);

  String userEmail,userPassword;
  TextEditingController textController = TextEditingController();
  TextEditingController hashTagsController = TextEditingController();
  String textValidationString;
  String hashTagsValidationString;
  var _formKey = GlobalKey<FormState>();
  final picker = ImagePicker();
  File imageFile;
  int postId;

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
                  padding: const EdgeInsets.all(15.0),
                  child: Row(
                    children: <Widget>[
                      IconButton(icon: Icon(Icons.notes_rounded), onPressed: null),
                      Expanded(
                          child: Container(
                              margin: EdgeInsets.only(right: 20, left: 10),
                              child: TextFormField(
                                decoration:
                                InputDecoration(hintText: 'Post text'),
                                controller: textController,
                                validator: (String enteredText) {
                                  return validateText(enteredText);
                                 }
                              ))),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: Row(
                    children: <Widget>[
                      IconButton(icon: Icon(Icons.tag), onPressed: null),
                      Expanded(
                          child: Container(
                              margin: EdgeInsets.only(right: 20, left: 10),
                              child: TextFormField(
                                decoration:
                                InputDecoration(hintText: 'Hash Tags'),
                                controller: hashTagsController,
                                validator: (String enteredHashTags) {
                                  return validateHashTags(enteredHashTags);
                                }
                              )))
                    ],
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                imageAdder(),
                Padding(
                    padding: const EdgeInsets.all(15.0),
                    child: Container(
                      height: 60,
                      child: RaisedButton(
                        color: Colors.grey,
                        onPressed: () async {
                          if (_formKey.currentState.validate()) {
                            checkConnectivityAndAddPost();
                          }
                          setState(() {
                          });
                        },
                        child: Text(
                          'Post',
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

  checkConnectivityAndAddPost() async{
    try {
      final result = await InternetAddress.lookup('bismarck.sdsu.edu');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        List hashTags;
        hashTags=hashTagsController.text.split(' ');
        postId= await newPost(userEmail,userPassword,textController.text,hashTags);
        Fluttertoast.showToast(
            msg:
            'Post successful!',
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.TOP,
            backgroundColor: Colors.lightGreen,
            textColor: Colors.white);
        if(imageFile!=null){
          final imageBytes = imageFile.readAsBytesSync();
          String image64 = base64Encode(imageBytes);
          uploadImage(userEmail,userPassword,image64,postId);}
      }
    } on SocketException catch (_) {
      Fluttertoast.showToast(
        msg:
        'No internet connection\nIt will be posted once device is online.',
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
      );
      SharedPreferences preferencesInstance =   await SharedPreferences.getInstance();
      //storing offline when no internet
      preferencesInstance.remove('postText');
      preferencesInstance.remove('postHashTags');


      preferencesInstance.setString("postText", textController.text);
      preferencesInstance.setString("postHashTags", hashTagsController.text);
      if(imageFile!=null) {
        preferencesInstance.remove('postImage');
        final imageBytes = imageFile.readAsBytesSync();
        String image64 = base64Encode(imageBytes);
        preferencesInstance.setString("postImage", image64);
      }
    }

    Navigator.pop(context);
  }

  Widget imageAdder(){
    return Container(
        child: Column(
            children: <Widget>[
              imageViewDecider(),
            ]
        )
    );
  }

  Widget imageViewDecider(){
    if(imageFile!=null)
      return ClipRRect(
          child: new Image.file(imageFile,
              width: 400.0, height: 300.0, fit: BoxFit.fill));
    else{
      return Column(children: <Widget>[IconButton(
          padding: EdgeInsets.only(bottom:5.0),
          icon: Icon(Icons.add_a_photo_rounded, size: 45.0,),
          onPressed: (){_showChoiceDialog(context);}
      ),
        Text('Would you like to add a image to this post?'),]);

  }}


  _showChoiceDialog(BuildContext context){
    return showDialog(context: context, builder: (BuildContext context){
      return AlertDialog(
        title: Text('Make a Choice!'),
        content: SingleChildScrollView(
            child: ListBody(
                children: <Widget>[
                  GestureDetector(
                    child: ListTile(
                        leading: Icon(Icons.photo),
                        title: Text('Gallery')
                    ),
                    onTap: (){openGallery(context);},
                  ),
                  GestureDetector(
                    child: ListTile(
                        leading: Icon(Icons.camera_alt_rounded),
                        title: Text('Camera')
                    ),
                    onTap: (){openCamera(context);},
                  )
                ]
            )
        ),
      );
    });
  }

 Future<void> openGallery(context) async{
   final PickedFile pickedFile=await picker.getImage(source: ImageSource.gallery);
   this.setState(() {
     if (pickedFile != null) {
       imageFile = File(pickedFile.path);
     } else {
       print('No image selected.');
     }
   });

   Navigator.of(context).pop();
  }

  Future<void> openCamera(context) async{
    final PickedFile pickedFile=await picker.getImage(source: ImageSource.camera);
    this.setState(() {
      if (pickedFile != null) {
        imageFile = File(pickedFile.path);
      } else {
        print('No image selected.');
      }
    });
    Navigator.of(context).pop();
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
          'Create New Post',
          style: TextStyle(
           fontWeight: FontWeight.bold, fontSize: 30),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
