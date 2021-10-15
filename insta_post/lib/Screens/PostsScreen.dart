import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:insta_post/Post.dart';
import 'package:insta_post/network.dart';
import 'package:flutter_simple_rating_bar/flutter_simple_rating_bar.dart';
import 'package:insta_post/validation.dart';

class PostsScreen extends StatefulWidget {
  final String searchEntity, userEmail, userPassword;

  PostsScreen(this.searchEntity, this.userEmail, this.userPassword);

  @override
  PostsScreenState createState() =>
      PostsScreenState(searchEntity, userEmail, userPassword);
}

class PostsScreenState extends State<PostsScreen> {
  PostsScreenState(this.searchEntity, this.userEmail, this.userPassword);

  String ratingValidationString;
  TextEditingController ratingController = TextEditingController();
  TextEditingController commentController = TextEditingController();
  String searchEntity, userEmail, userPassword;
  List<Post> posts;
  int postId;
  List postIds;
  var _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    this.getPosts();
    tryToPost();
  }

  Future getPosts() async {
    List<Post> retrievedPosts = await getPostsFromServer(searchEntity);
    final List retrievedPostIds = await getPostIds(searchEntity);
    setState(() {
      postIds = retrievedPostIds;
      posts = retrievedPosts;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text('Posts')),
        body: Form(
          key: _formKey,
          child: displayContent(),
        ));
  }

  Widget displayContent() {
    if (posts == null){
      Fluttertoast.showToast(
        msg:
        'All the posts will be loaded at once.',
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
      );
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
                  Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                    Text(
                      'Loading Posts',
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
      );}
    else {
      if (posts.length == 0) {
        return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text(
                      'Ops! No posts to display.',
                      textScaleFactor: 1.7,
                    ),
                  ]),
            ]);
      }

      return Scaffold(
        body: ListView.builder(
            itemCount: posts == null ? 0 : posts.length,
            itemBuilder: (context, index) {
              return buildPostColumn(posts[index]);
            }),
      );
    }
  }

  Widget buildPostColumn(post) {
    return Container(
        decoration: BoxDecoration(),
        margin: EdgeInsets.all(5.0),
        padding: EdgeInsets.only(top: 5.0, left: 5.0, right: 5.0, bottom: 15.0),
        child: Column(children: <Widget>[
          imageCheck(post),
          ExpansionTile(
            title: Text(
              post.text,
              textScaleFactor: 1.7,
            ),
            subtitle: Row(
              children: <Widget>[
                Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Row(children: <Widget>[
                        RatingBar(
                          allowHalfRating: true,
                          rating: double.parse(post.ratingsAverage),
                          icon: Icon(Icons.star_purple500_sharp,
                              color: Colors.white),
                          starCount: 5,
                          size: 25,
                          color: Colors.yellow,
                        ),
                        Text(
                          '  ( ' + post.ratingsCount + ' )',
                        ),
                      ]),
                      hashTags(post.hashTags),
                    ])
              ],
            ),
            trailing: Icon(Icons.comment_rounded, size: 30),
            children: <Widget>[
              Row(
                children: <Widget>[
                  IconButton(
                      icon: Icon(Icons.rate_review_rounded), onPressed: null),
                  Expanded(
                      child: Container(
                          margin: EdgeInsets.only(right: 20, left: 10),
                          child: TextFormField(
                            controller: ratingController,
                            validator: (String enteredNumber) {
                              return validateNumber(enteredNumber);
                            },
                            decoration: InputDecoration(
                                hintText: 'How would you rate it?'),
                            keyboardType: TextInputType.number,
                          ))),
                  RaisedButton(
                    color: Colors.grey,
                    child: Text(
                      '  Submit  ',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                    ),
                    onPressed: () async {
                      postId = post.postId;
                      setState(() {
                        // Check for blank fields
                        if ((ratingController.text == '' &&
                            commentController.text == ''))
                          Fluttertoast.showToast(
                            msg: 'Enter at least one field!',
                            toastLength: Toast.LENGTH_LONG,
                            gravity: ToastGravity.TOP,
                          );
                        else if (_formKey.currentState.validate()) {
                          //check for Ratings value
                          if (ratingController.text != null)
                            ratingPost(userEmail, userPassword,
                                ratingController.text, postId);
                          //Check for Comments value
                          if (commentController.text != null)
                            commentingPost(userEmail, userPassword,
                                commentController.text, postId);
                          Fluttertoast.showToast(
                            msg:
                                'Data added successfully.\nUpdates will be reflected after revisiting the page. ',
                            toastLength: Toast.LENGTH_LONG,
                            gravity: ToastGravity.TOP,
                          );
                        }
                      });
                    },
                  ),
                  SizedBox(width: 20.0),
                ],
              ),
              Row(
                children: <Widget>[
                  IconButton(
                      icon: Icon(Icons.add_comment_rounded), onPressed: null),
                  Expanded(
                      child: Container(
                          margin: EdgeInsets.only(right: 20, left: 10),
                          child: TextFormField(
                            controller: commentController,
                            decoration:
                                InputDecoration(hintText: 'Any Comments?'),
                          ))),
                ],
              ),
              SizedBox(height: 10.0),
              Text(
                '--------------------------------Comments--------------------------------',
                textScaleFactor: 1.2,
              ),
              Container(
                  height: 100,
                  child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: post.comments.length,
                      itemBuilder: (context, index) {
                        return Text(
                          ' ~' + post.comments[index],
                          textScaleFactor: 1.2,
                        );
                      })),
              SizedBox(height: 5.0)
            ],
          ),
        ]));
  }

  Widget imageCheck(post) {
    Uint8List decodedBytes;

    if (post.postImage == 'No image for this post') {
      return Row();
    } else {
      decodedBytes = base64Decode(post.postImage);
      return ClipRRect(
          child: new Image.memory(decodedBytes,
              width: 400.0, height: 300.0, fit: BoxFit.fill));
    }
  }

  Widget hashTags(postHashTags) {
    String displayHashTags = '';
    for (int i = 0; i < postHashTags.length; i++) {
      displayHashTags += ' ' + postHashTags[i];
    }
    return Text(displayHashTags);
  }
}
