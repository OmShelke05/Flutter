import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:todo_app/screens/DrawNote.dart';

//This screen is used to add new task with required title and category and optional additional parameters.
//Optional parameters can be detailed text description, reminder, hand drawn note or image from gallery or camera.
//Image is displayed once selected or drawn. Similarly, reminder time is displayed if set.

class AddTaskScreen extends StatefulWidget {
  final String userEmail;

  AddTaskScreen(this.userEmail);

  @override
  AddTaskScreenState createState() => AddTaskScreenState(userEmail);
}

class AddTaskScreenState extends State<AddTaskScreen> {
  AddTaskScreenState(this.userEmail);

  String userEmail;
  TextEditingController taskController = TextEditingController();
  TextEditingController taskDetailsController = TextEditingController();
  TextEditingController taskCategoryController = TextEditingController();

  var _formKey = GlobalKey<FormState>();
  DateTime pickedDate;
  TimeOfDay pickedTime;
  bool reminderFlag;
  final picker = ImagePicker();
  File imageFile;
  var noteDrawn;
  String image64;
  List _categories = ['Personal', 'Work', 'Family', 'Other'];
  List<DropdownMenuItem> _dropdownMenuItems;
  var _selectedCategory;

  @override
  void initState() {
    _dropdownMenuItems = buildDropdownMenuItems(_categories);
    _selectedCategory = _dropdownMenuItems[0].value;
    pickedDate = DateTime(2020, 1, 1);
    pickedTime = TimeOfDay.now();
    reminderFlag = false;
    noteDrawn = false;
    super.initState();
  }

  List<DropdownMenuItem> buildDropdownMenuItems(List categories) {
    List<DropdownMenuItem> items = List();
    for (var category in categories) {
      items.add(
        DropdownMenuItem(
          value: category,
          child: Text(category),
        ),
      );
    }
    return items;
  }

  onChangeDropdownItem(var selectedCategory) {
    setState(() {
      _selectedCategory = selectedCategory;
    });
  }

  addTask() {
    Map<String, dynamic> task = {
      "title": taskController.text,
      "description": taskDetailsController.text,
      "category": _selectedCategory.toString(),
      "reminder": pickedDate,
      "image": image64,
      'createdOn': DateTime.now()
    };
    Map<String, dynamic> userTask = {task['title']: task};
    CollectionReference users = FirebaseFirestore.instance.collection('users');
    DocumentReference currentUser = users.doc(userEmail);
    currentUser.set(userTask, SetOptions(merge: true));
    Fluttertoast.showToast(
        msg: 'Task added',
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.green,
        textColor: Colors.white);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: EdgeInsets.only(top: 25.0, left: 5, right: 5, bottom: 5),
        child: Container(
          decoration: BoxDecoration(
              color: Colors.blueGrey,
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20.0),
                  topRight: Radius.circular(20.0))),
          child: Padding(
            padding: EdgeInsets.fromLTRB(5.0, 10.0, 5.0, 5.0),
            child: Container(
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(20.0),
                      topRight: Radius.circular(20.0))),
              child: Form(
                key: _formKey,
                child: Padding(
                  padding: EdgeInsets.all(0.0),
                  child: ListView(
                    children: <Widget>[
                      Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                Icon(Icons.note_add, size: 30),
                                Text(
                                  'Create Your task here !!!',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 20),
                                  textAlign: TextAlign.center,
                                ),
                              ])),
                      SizedBox(
                        height: 10,
                      ),
                      Padding(
                        padding: const EdgeInsets.all(15.0),
                        child: Row(
                          children: <Widget>[
                            Expanded(
                                child: Container(
                                    margin:
                                        EdgeInsets.only(right: 20, left: 10),
                                    child: TextFormField(
                                        decoration: InputDecoration(
                                            hintStyle: TextStyle(
                                                fontStyle: FontStyle.italic,
                                                fontSize: 18,
                                                color: Colors.black,
                                                fontWeight: FontWeight.bold),
                                            hintText: 'Title'),
                                        controller: taskController,
                                        validator: (String enteredText) {
                                          return enteredText.isEmpty ||
                                                  enteredText.length < 2
                                              ? "Please provide valid task"
                                              : null;
                                        }))),
                          ],
                        ),
                      ),
                      Padding(
                          padding: const EdgeInsets.all(15.0),
                          child: Row(children: <Widget>[
                            // Icon(Icons.note, size: 35),
                            Expanded(
                                child: Container(
                                    margin:
                                        EdgeInsets.only(right: 20, left: 10),
                                    child: TextField(
                                      keyboardType: TextInputType.multiline,
                                      minLines: 1,
                                      maxLines: 5,
                                      decoration: InputDecoration(
                                          hintStyle: TextStyle(
                                              fontStyle: FontStyle.italic,
                                              fontSize: 18,
                                              color: Colors.black,
                                              fontWeight: FontWeight.bold),
                                          hintText: "Description"),
                                      controller: taskDetailsController,
                                    ))),
                          ])),
                      Padding(
                          padding: const EdgeInsets.all(7.0),
                          child: Row(children: <Widget>[
                            Icon(
                              Icons.grid_view,
                              size: 30,
                            ),
                            Container(
                              height: 25,
                              width: 100,
                              decoration: BoxDecoration(
                                  color: Colors.blueGrey,
                                  borderRadius: BorderRadius.circular(5)),
                              child: Padding(
                                padding: const EdgeInsets.only(left: 7),
                                child: DropdownButton(
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold),
                                  dropdownColor: Colors.blueGrey,
                                  value: _selectedCategory,
                                  items: _dropdownMenuItems,
                                  onChanged: onChangeDropdownItem,
                                ),
                              ),
                            ),
                            remindAdder(),
                            IconButton(
                                icon: Icon(Icons.brush_rounded, size: 30),
                                onPressed: () async {
                                  image64 = await Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => DrawNote()));
                                  this.setState(() {
                                    if (image64 != null) {
                                      noteDrawn = true;
                                      imageFile = null;
                                    } else {
                                      print('Nothing drawn.');
                                    }
                                  });
                                }),
                            IconButton(
                                icon: Icon(
                                  Icons.add_a_photo,
                                  size: 30.0,
                                ),
                                onPressed: () {
                                  _showChoiceDialog(context);
                                }),
                          ])),
                      imageAdder(),
                      Padding(
                        padding:
                            const EdgeInsets.fromLTRB(110.0, 15.0, 110.0, 15.0),
                        child: Container(
                          height: 45,
                          child: RaisedButton(
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10)),
                            color: Colors.blueGrey,
                            onPressed: () async {
                              if (_formKey.currentState.validate()) {
                                addTask();
                              }
                            },
                            child: Text(
                              'Add Task',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget remindAdder() {
    return Container(
        child: Row(children: <Widget>[
      IconButton(
          icon: Icon(Icons.alarm_add),
          iconSize: 30,
          hoverColor: Colors.blue[900],
          onPressed: () async {
            DateTime selectedDate = await showDatePicker(
              context: context,
              firstDate: DateTime(DateTime.now().year),
              lastDate: DateTime(DateTime.now().year + 20),
              initialDate: DateTime.now(),
            );
            TimeOfDay selectedTime = await showTimePicker(
              context: context,
              initialTime: pickedTime,
            );
            if (selectedTime != null)
              setState(() {
                pickedTime = selectedTime;
                pickedDate = DateTime(selectedDate.year, selectedDate.month,
                    selectedDate.day, selectedTime.hour, selectedTime.minute);
                reminderFlag = true;
              });
          }),
      dateViewDecider(),
    ]));
  }

  Widget dateViewDecider() {
    if (!reminderFlag)
      return Text("Remind me at?");
    else {
      return Text(
          "${pickedDate.day}/${pickedDate.month}/${pickedDate.year} ${pickedTime.hour}:${pickedTime.minute}",
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold));
    }
  }

  Widget imageAdder() {
    return Container(
        child: Column(children: <Widget>[
      imageViewDecider(),
    ]));
  }

  Widget imageViewDecider() {
    if (imageFile != null)
      return ClipRRect(
          child: new Image.file(imageFile,
              width: 380.0, height: 240.0, fit: BoxFit.fill));
    else if (noteDrawn == true) {
      Uint8List uInt8List = base64Decode(image64);
      return ClipRRect(
          child: new Image.memory(uInt8List,
              width: 380.0, height: 240.0, fit: BoxFit.fill)
          //Image.file(imageFile,
          // width: 300.0, height: 300.0, fit: BoxFit.fill)
          );
    } else {
      return Container(
        height: 240,
        child: Text(""),
      );
    }
  }

  _showChoiceDialog(BuildContext context) {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Make a Choice!'),
            content: SingleChildScrollView(
                child: ListBody(children: <Widget>[
              GestureDetector(
                child: ListTile(
                    leading: Icon(Icons.photo), title: Text('Gallery')),
                onTap: () {
                  openGallery(context);
                },
              ),
              GestureDetector(
                child: ListTile(
                    leading: Icon(Icons.camera_alt), title: Text('Camera')),
                onTap: () {
                  openCamera(context);
                },
              )
            ])),
          );
        });
  }

  Future<void> openGallery(context) async {
    final PickedFile pickedFile =
        await picker.getImage(source: ImageSource.gallery);
    this.setState(() {
      if (pickedFile != null) {
        imageFile = File(pickedFile.path);
        image64 = base64Encode(imageFile.readAsBytesSync());
      } else {
        print('No image selected.');
      }
    });
    Navigator.of(context).pop();
  }

  Future<void> openCamera(context) async {
    final PickedFile pickedFile =
        await picker.getImage(source: ImageSource.camera);
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
