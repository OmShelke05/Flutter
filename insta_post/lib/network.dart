import 'dart:io';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

import 'Post.dart';

const String authenticateURL         =    'https://bismarck.sdsu.edu/api/instapost-query/authenticate?email=';
const String nicknameExistsURL       =    'https://bismarck.sdsu.edu/api/instapost-query/nickname-exists?nickname=';
const String emailExistsURL          =    'https://bismarck.sdsu.edu/api/instapost-query/email-exists?email=';
const String nickNamesURL            =    'https://bismarck.sdsu.edu/api/instapost-query/nicknames';
const String hashTagsURL             =    'https://bismarck.sdsu.edu/api/instapost-query/hashtags';
const String postIdsFromNickNameURL  =    'https://bismarck.sdsu.edu/api/instapost-query/nickname-post-ids?nickname=';
const String postIdsFromHashTagURL   =    'https://bismarck.sdsu.edu/api/instapost-query/hashtags-post-ids?hashtag=';
const String postFromPostIdURL       =    'https://bismarck.sdsu.edu/api/instapost-query/post?post-id=';
const String imageFromImageIdURL     =    'https://bismarck.sdsu.edu/api/instapost-query/image?id=';

const String newUserURL              =    'https://bismarck.sdsu.edu/api/instapost-upload/newuser';
const String ratingURL               =    'https://bismarck.sdsu.edu/api/instapost-upload/rating';
const String commentURL              =    'https://bismarck.sdsu.edu/api/instapost-upload/comment';
const String newPostURL              =    'https://bismarck.sdsu.edu/api/instapost-upload/post';
const String uploadImageURL          =    'https://bismarck.sdsu.edu/api/instapost-upload/image';

Future<bool> authenticateUser(email, password) async {
  final response =
      await http.get(authenticateURL + email + '&password=' + password);
  if (response.statusCode == 200) {
    return jsonDecode(response.body)['result'];
  } else {
    throw Exception('Failed to get authenticate.');
  }
}

Future<List<Post>> getPostsFromServer(searchEntity) async {
  List<Post> posts = List();
  String text, imageId, ratingsCount, ratingsAverage;
  int postId;
  List hashTags = List();
  List comments = List();
  String postImage;

  final List postIds = await getPostIds(searchEntity);

  for (int i = 0; i < postIds.length; i++) {
    final response = await http.get(postFromPostIdURL + postIds[i].toString());
    if (response.statusCode == 200) {
      comments = jsonDecode(response.body)['post']['comments'];

      text = jsonDecode(response.body)['post']['text'];
      imageId = jsonDecode(response.body)['post']['image'].toString();
      ratingsCount =
          jsonDecode(response.body)['post']['ratings-count'].toString();
      ratingsAverage =
          jsonDecode(response.body)['post']['ratings-average'].toString();
      hashTags = jsonDecode(response.body)['post']['hashtags'];
      postId = postIds[i];

      if (imageId != '-1') {
        postImage = await getImageFromImageId(imageId);
      } else {
        postImage = "No image for this post";
      }
      Post currentPost = Post(comments, text, postImage, ratingsCount,
          ratingsAverage, hashTags, postId);

      posts.add(currentPost);
      print(currentPost.text);
    } else {
      throw Exception('Failed to get post.');
    }
  }
  return posts;
}

Future<String> getImageFromImageId(imageId) async {
  final response = await http.get(imageFromImageIdURL + imageId);
  if (response.statusCode == 200) {
    return jsonDecode(response.body)['image'];
  } else {
    throw Exception('Failed to get image.');
  }
}

Future<List> getPostIds(searchEntity) async {
  if (searchEntity[0] == '#') {
    final List postIds = await getPostIdsFromHashTag(searchEntity);
    return postIds;
  } else {
    final List postIds = await getPostIdsFromNickName(searchEntity);
    return postIds;
  }
}

Future<bool> nicknameExists(nickName) async {
  final response = await http.get(nicknameExistsURL + nickName);
  if (response.statusCode == 200) {
    return jsonDecode(response.body)['result'];
  } else {
    throw Exception('Failed to get nicknames.');
  }
}

Future<bool> emailExists(email) async {
  final response = await http.get(emailExistsURL + email);
  if (response.statusCode == 200) {
    return jsonDecode(response.body)['result'];
  } else {
    throw Exception('Failed to get emails');
  }
}

Future<List> getNickNames() async {
  final response = await http.get(nickNamesURL);
  if (response.statusCode == 200) {
    return json.decode(response.body)['nicknames'];
  } else {
    throw Exception('Failed to get nick names.');
  }
}

Future<List> getHashTags() async {
  final response = await http.get(hashTagsURL);
  if (response.statusCode == 200) {
    return json.decode(response.body)['hashtags'];
  } else {
    throw Exception('Failed to get hash tags.');
  }
}

Future<List> getPostIdsFromNickName(nickName) async {
  final response = await http.get(postIdsFromNickNameURL + nickName);
  if (response.statusCode == 200) {
    return json.decode(response.body)['ids'];
  } else {
    throw Exception('Failed to get post ids from nick name.');
  }
}

Future<List> getPostIdsFromHashTag(hashTag) async {
  String formattedHashTag = checkHashTag(hashTag);

  final response = await http.get(postIdsFromHashTagURL + formattedHashTag);
  if (response.statusCode == 200) {
    return json.decode(response.body)['ids'];
  } else {
    throw Exception('Failed to get post ids from hash tag.');
  }
}

String checkHashTag(String hashTag) {
  if (hashTag.length == 2) {
    hashTag = '%23' + hashTag.substring(1);
  } else {
    int i = 0;
    String replaceString = '';
    while (i < hashTag.length) {
      if (hashTag[0] == '#') {
        hashTag = hashTag.substring(1);
        replaceString += '%23';
      } else {
        hashTag = replaceString + hashTag;
        break;
      }
      i++;
    }
  }
  return hashTag;
}

Future<http.Response> newUser(
    firstName, lastName, nickName, email, password) async {
  final response = await http.post(
    newUserURL,
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    },
    body: jsonEncode(<String, String>{
      "firstname": firstName,
      "lastname": lastName,
      "nickname": nickName,
      "email": email,
      "password": password
    }),
  );
  if (response.statusCode == 200) {
    return jsonDecode(response.body);
  } else {
    throw Exception('Failed to create user');
  }
}

Future ratingPost(email, password, rating, postId) async {
  final response = await http.post(
    ratingURL,
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    },
    body: jsonEncode(<String, dynamic>{
      "email": email,
      "password": password,
      "rating": int.parse(rating),
      "post-id": postId,
    }),
  );
  if (response.statusCode == 200) {
    return jsonDecode(response.body);
  } else {
    throw Exception('Failed to rate the post');
  }
}

Future commentingPost(email, password, comment, postId) async {
  final response = await http.post(commentURL,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, dynamic>{
        "email": email,
        "password": password,
        "comment": comment,
        "post-id": postId
      }));
  if (response.statusCode == 200) {
    return jsonDecode(response.body);
  } else {
    throw Exception('Failed to comment the post');
  }
}

Future newPost(email, password, text, hashTags) async {
  final response = await http.post(newPostURL,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, dynamic>{
        "email": email,
        "password": password,
        "text": text,
        "hashtags": hashTags
      }));
  if (response.statusCode == 200) {
    int postId = jsonDecode(response.body)['id'];
    return postId;
  } else {
    throw Exception('Failed to post.');
  }
}

Future uploadImage(email, password, image64, postId) async {
  final response = await http.post(uploadImageURL,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, dynamic>{
        "email": email,
        "password": password,
        "image": image64,
        "post-id": postId
      }));
  if (response.statusCode == 200) {
    return jsonDecode(response.body);
  } else {
    throw Exception('Failed to post.');
  }
}

tryToPost() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String userEmail = prefs.getString('userEmail');
  String userPassword = prefs.getString('userPassword');

  String postText = prefs.getString('postText');
  String postHashTags = prefs.getString('postHashTags');
  String postImage = prefs.getString('postImage');

  if (postText != null) {
    try {
      final result = await InternetAddress.lookup('bismarck.sdsu.edu');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        print('Connected');
        List hashTags;
        hashTags = postHashTags.split(' ');
        int postId = await newPost(userEmail, userPassword, postText, hashTags);
        prefs.remove('postText');
        prefs.remove('postHashTags');
        Fluttertoast.showToast(
            msg: 'Post successful!',
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.TOP,
            backgroundColor: Colors.lightGreen,
            textColor: Colors.white);
        if (postImage != null) {
          uploadImage(userEmail, userPassword, postImage, postId);
          prefs.remove('postImage');
        }
      }
    } on SocketException catch (_) {
      print('Not connected');
    }
  }
}
