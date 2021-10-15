import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable_list_view/flutter_slidable_list_view.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:todo_app/screens/PeekScreen.dart';
import 'package:todo_app/services/LocalNotifyManager.dart';
import 'package:todo_app/services/auth.dart';
import '../main.dart';
import 'AddTaskScreen.dart';

//This is the home screen hat displays all the tasks for the user.
//Expansion tile is used for abstract view of tasks which can be expanded on tap to get detailed version.
//Peek button is provided to view the full task in edit mode.

class HomeScreen extends StatefulWidget {
  final String userEmail;

  HomeScreen(this.userEmail);

  @override
  _HomeScreenState createState() => _HomeScreenState(userEmail);
}

class _HomeScreenState extends State<HomeScreen> {
  AuthMethods authMethods = new AuthMethods();
  CollectionReference cr = FirebaseFirestore.instance.collection('users');

  _HomeScreenState(this.userEmail) {
    localNotifyManager.setOnNotificationReceive(onNotificationReceive);
    localNotifyManager.setOnNotificationClick(onNotificationClick);
    fetchData();
  }

  onNotificationReceive(ReceivedNotification notification) {
    print('Notification received: ${notification.id}');
  }

  onNotificationClick(String payload) {
    print('Payload: $payload');
  }

  Map userTasks;
  String userEmail;

  fetchData() {
    cr.doc(userEmail).snapshots().listen((snapshot) {
      setState(() {
        userTasks = snapshot.data();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Image(
          image: AssetImage('assets/images/note.png'),
        ),
        title: Text(
          'To Do',
        ),
        toolbarHeight: 50,
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () async {
              authMethods.signOut();
              SharedPreferences prefs = await SharedPreferences.getInstance();
              prefs.remove('userEmail');
              prefs.remove('userPassword');
              Navigator.pushReplacement(context,
                  MaterialPageRoute(builder: (context) => new MyApp()));
            },
          ),
          SizedBox(
            width: 5,
          )
        ],
      ),
      floatingActionButton: FloatingActionButton(
          child: Icon(Icons.add),
          onPressed: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (BuildContext context) =>
                        AddTaskScreen(userEmail)));
          }),
      floatingActionButtonLocation: FloatingActionButtonLocation.miniEndFloat,
      body: displayTasks(),
      backgroundColor: Colors.white,
    );
  }

  Widget displayTasks() {
    if (userTasks == null) {
      return Container(
        child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  CircularProgressIndicator(),
                  SizedBox(height: 50.0),
                  Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                    Text(
                      'Loading Tasks',
                      style: TextStyle(
                        fontSize: 35.0,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ]),
                  SizedBox(height: 5.0),
                  Text(
                      '“Patience is bitter, but its fruit is sweet.” -Aristotle',
                      style: TextStyle(
                        fontSize: 17.0,
                      ))
                ])),
      );
    } else {
      if (userTasks.length == 0) {
        return Container(
          alignment: Alignment.center,
          child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Icon(
                  Icons.note_add,
                  size: 70,
                ),
                SizedBox(height: 10),
                Text(
                  'No tasks to display.',
                  textScaleFactor: 1.5,
                ),
              ]),
        );
      }
      return buildTaskColumn();
    }
  }

  Widget buildTaskColumn() {
    return Scaffold(
        backgroundColor: Colors.white,
        body: Container(
            padding: EdgeInsets.only(bottom: 7, top: 10),
            child: SlideListView(
              separatorBuilder: (context, index) =>
                  Divider(color: Colors.white),
              actionWidgetDelegate:
                  ActionWidgetDelegate(1, (actionIndex, listIndex) {
                return Container(
                    padding: EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.red, Colors.redAccent],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.red.withOpacity(0.4),
                          blurRadius: 5,
                          spreadRadius: 1,
                          offset: Offset(1, 1),
                        )
                      ],
                      borderRadius: BorderRadius.all(Radius.circular(10.0)),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[Icon(Icons.delete), Text('Delete')],
                    ));
              }, (int indexInList, int index, BaseSlideItem item) {
                var currentTask = userTasks.keys.toList()[indexInList];
                item.close();
                cr.doc(userEmail).update({currentTask: FieldValue.delete()});
                fetchData();
              }, [Colors.white]),
              refreshCallback: () async {
                fetchData();
              },
              dataList: userTasks.keys.toList()..sort(),
              itemBuilder: (context, index) {
                var currentCategory =
                    userTasks.values.toList()[index]['category'].toString();
                var currentTask = userTasks.keys.toList()[index];
                Timestamp createdOnT =
                    userTasks.values.toList()[index]['createdOn'];
                Timestamp reminder =
                    userTasks.values.toList()[index]['reminder'];
                String createdOn =
                    "   ${createdOnT.toDate().day.toString()}/${createdOnT.toDate().month.toString()}/${createdOnT.toDate().year.toString()} ${createdOnT.toDate().hour.toString()}:${createdOnT.toDate().minute.toString()}";

                localNotifyManager.showNotification(
                    currentTask, reminder, index);

                return Container(
                    margin: const EdgeInsets.only(left: 5, right: 5),
                    padding: EdgeInsets.symmetric(
                      horizontal: 5.0,
                    ),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: (currentCategory == 'Personal')
                            ? [Colors.grey[800], Colors.brown[300]]
                            : (currentCategory == 'Work')
                                ? [Colors.deepOrange[900], Colors.amberAccent]
                                : (currentCategory == 'Family')
                                    ? [Colors.teal[700], Colors.teal[200]]
                                    : [Colors.lightBlue[900], Colors.lightBlue],
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
                      borderRadius: BorderRadius.all(Radius.circular(10.0)),
                    ),
                    child: ExpansionTile(
                        title: Text(
                          userTasks.keys.toList()[index].toString(),
                          textScaleFactor: 1.3,
                          style: TextStyle(color: Colors.white),
                        ),
                        trailing:
                            Icon(Icons.arrow_drop_down, color: Colors.white),
                        children: <Widget>[
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Text(
                                createdOn,
                                style: TextStyle(color: Colors.white),
                              ),
                              checkReminder(index),
                              IconButton(
                                  icon: Icon(Icons.remove_red_eye_rounded),
                                  color: Colors.white,
                                  onPressed: () {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                new PeekScreen(
                                                    userEmail, index)));
                                  }),
                            ],
                          ),
                          displayContents(index),
                        ]));
              },
            )));
  }

  Widget checkReminder(index) {
    if (userTasks.values
        .toList()[index]['reminder']
        .toDate()
        .isAfter(DateTime.now()))
      return Icon(Icons.alarm, color: Colors.white);
    else
      return Container();
  }

  Widget displayContents(index) {
    String description =
        userTasks.values.toList()[index]['description'].toString();
    String image64 = userTasks.values.toList()[index]['image'];
    if (description != '' && image64 != null)
      return Padding(
        padding: EdgeInsets.all(10),
        child: Container(
            alignment: Alignment.topLeft,
            height: 100,
            child: Row(
              children: [
                Image.memory(base64Decode(image64),
                    width: 100, height: 100, fit: BoxFit.fill),
                SizedBox(width: 10),
                Container(
                  width: 250,
                  child: Text(
                    description,
                    maxLines: 6,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            )),
      );
    else if (description != '')
      return Padding(
        padding: EdgeInsets.all(5),
        child: Container(
          alignment: Alignment.topLeft,
          height: 60,
          child: Text(
            description,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            textScaleFactor: 1.1,
            style: TextStyle(color: Colors.white),
          ),
        ),
      );
    else if (image64 != null)
      return Padding(
        padding: EdgeInsets.all(5),
        child: Container(
          height: 240,
          child: Image.memory(base64Decode(image64),
              width: 320, height: 240, fit: BoxFit.fill),
        ),
      );
    return Container();
  }
}
