import 'dart:io';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:insta_post/file_utils.dart';
import 'package:insta_post/network.dart';
import 'PostsScreen.dart';

class ListScreen extends StatefulWidget {
  final String entityType, userEmail, userPassword;

  ListScreen(this.entityType, this.userEmail, this.userPassword);

  @override
  ListScreenState createState() =>
      ListScreenState(entityType, userEmail, userPassword);
}

class ListScreenState extends State<ListScreen> {
  ListScreenState(this.entityType, this.userEmail, this.userPassword);

  String entityType, userEmail, userPassword;

  @override
  void initState() {
    super.initState();
    tryToPost();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Entities"),
        ),
        body: FutureBuilder(
            future: getElements(entityType),
            builder: (_, AsyncSnapshot snapshot) {
              if (snapshot.data == null)
                return Container(
                  decoration: BoxDecoration(
                      image: DecorationImage(
                          fit: BoxFit.cover,
                          image: AssetImage('asset/images/abstract.png'))),
                  child: Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            CircularProgressIndicator(),
                            SizedBox(height: 50.0),
                            Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text('Loading',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontSize: 35.0,
                                      )),
                                ]),
                            SizedBox(height: 5.0),
                            Text(
                                '“Patience is bitter, but its fruit is sweet.” -Aristotle',
                                style: TextStyle(
                                  fontSize: 17.0,
                                ))
                          ])),
                );
              return ListView.builder(
                padding: EdgeInsets.all(10.0),
                itemCount: snapshot.data.length,
                itemBuilder: (_, index) {
                  return GestureDetector(
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => PostsScreen(
                                    snapshot.data[index].toString(),
                                    userEmail,
                                    userPassword)));
                      },
                      child: Container(
                          margin: const EdgeInsets.only(top: 15.0),
                          padding: EdgeInsets.symmetric(
                              horizontal: 16.0, vertical: 8.0),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            gradient: LinearGradient(
                              colors: [Colors.grey, Colors.white70],
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.teal.withOpacity(0.4),
                                blurRadius: 8,
                                spreadRadius: 2,
                                offset: Offset(4, 4),
                              )
                            ],
                            borderRadius:
                                BorderRadius.all(Radius.circular(10.0)),
                          ),
                          child: Column(children: <Widget>[
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Text(
                                  snapshot.data[index],
                                  style: TextStyle(
                                    fontSize: 20.0,
                                  ),
                                ),
                                SizedBox(width: 8.0),
                                Icon(Icons.arrow_forward),
                              ],
                            ),
                          ])));
                },
              );
            }));
  }

  Future<List> getElements(String entityType) async {
    try {
      final result = await InternetAddress.lookup('google.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        //Storing data for offline use
        if (entityType == 'NickNames') {
          List nickNames = await getNickNames();
          String nickNamesString =
              nickNames.reduce((value, element) => value + ' ' + element);
          FileUtils.saveToNickNamesFile(nickNamesString);
          return nickNames;
        } else {
          List hashTags = await getHashTags();
          String hashTagsString =
              hashTags.reduce((value, element) => value + ' ' + element);
          FileUtils.saveToHashTagsFile(hashTagsString);
          return hashTags;
        }
      }
    } on SocketException catch (_) {
      print('not connected');
      Fluttertoast.showToast(
        msg:
        'No internet connection ',
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
      );
      //retrieving offline data when no internet
      if (entityType == 'NickNames') {
        String nickNamesString = await FileUtils.readFromNickNamesFile();
        final List nickNames = nickNamesString.split(' ');
        return nickNames;
      } else {
        String hashTagsString = await FileUtils.readFromHashTagsFile();
        final List nickNames = hashTagsString.split(' ');
        return nickNames;
      }
    }
  }
}
