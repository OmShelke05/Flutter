import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:insta_post/main.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:insta_post/network.dart';
import 'AddPostScreen.dart';
import 'ListScreen.dart';

class HomeScreen extends StatefulWidget {

  final String userEmail, userPassword;

  HomeScreen(this.userEmail,this.userPassword);

  @override
  HomeScreenState createState() => HomeScreenState(userEmail,userPassword);
}

class HomeScreenState extends State<HomeScreen> {
  HomeScreenState(this.userEmail, this.userPassword);
  Image imageOfTheDay= Image.network('https://source.unsplash.com/daily',
      width: 400.0, height: 400.0, fit: BoxFit.fill);
  String userEmail, userPassword;

  @override
  void initState() {
    super.initState();
    tryToPost();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar( leading: Icon(Icons.home_rounded),title: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,children: <Widget>[
          Text('My Wall',),
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () async{
              SharedPreferences prefs=await SharedPreferences.getInstance();
              prefs.remove('userEmail');
              prefs.remove('userPassword');
              Navigator.push(context, new MaterialPageRoute(builder: (context) => new MyApp()));
              },
          )
        ]
          ,)
        ),
                body: ListView(children: <Widget>[
          Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                Container(
                  padding: EdgeInsets.only(left: 15.0, right: 15.0),
                ),
                Container(
                    height: 550.0,
                    decoration: BoxDecoration(
                    ),
                    margin: EdgeInsets.all(1.0),
                    padding:
                        EdgeInsets.only(top: 10.0,),
                    child: displayWallImage(),
                ),
                Container(
                  height: 50.0,
                    padding: EdgeInsets.all(1.0),
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: <Widget>[
                          RaisedButton(
                              color: Colors.grey,
                              child: Text(
                                "Nick Names",
                                style: TextStyle(
                                                                    fontWeight: FontWeight.bold,
                                    fontSize: 20),
                              ),
                              onPressed: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            ListScreen('NickNames', userEmail, userPassword)));
                              }),
                          SizedBox(),
                          IconButton(
                            padding: EdgeInsets.only(bottom:5.0),
                            icon: Icon(Icons.add_box_rounded, size: 45.0,),
                            onPressed: (){Navigator.push(context,
                              MaterialPageRoute(
                              builder: (context) =>
                              AddPostScreen(userEmail, userPassword)));}
                          ),
                          SizedBox(width: 5),
                          RaisedButton(
                            color: Colors.grey,
                            child: Text(
                              " Hash Tags  ",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20),
                            ),
                            onPressed: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          ListScreen('HashTags', userEmail, userPassword)));
                            },
                          ),
                        ])),
              ]))
        ]));
  }

  displayWallImage() {
     return Container(
      child: Column(children: <Widget> [
        Text('Image of the Day',textScaleFactor: 2.0),
       imageOfTheDay,
      ListTile(title: Text('A picture is worth a thousand words!', style: TextStyle(fontSize: 20.0)),
        subtitle: Text('A graphic illustration conveys a stronger message than words. This saying was invented by an advertising executive, Fred R. Barnard.'),)]));
  }
}
