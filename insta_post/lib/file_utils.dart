import 'package:path_provider/path_provider.dart';
import 'dart:io';

class FileUtils {
  static Future<String> get getFilePath async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  static Future<File> get getNickNamesFile async {
    final path = await getFilePath;
    print('$path/nickNames.txt');
    return File('$path/nickNames.txt');
  }

  static Future<File> saveToNickNamesFile(nickNames) async {
    final file = await getNickNamesFile;
    return file.writeAsString(nickNames);
  }

  static Future<String> readFromNickNamesFile() async {
    final file = await getNickNamesFile;
    String nickNames = await file.readAsString();
    return nickNames;
  }

  static Future<File> get getHashTagsFile async {
    final path = await getFilePath;
    return File('$path/hashTags.txt');
  }

  static Future<File> saveToHashTagsFile(hashTags) async {
    final file = await getHashTagsFile;
    return file.writeAsString(hashTags);
  }

  static Future<String> readFromHashTagsFile() async {
    final file = await getHashTagsFile;
    String hashTags = await file.readAsString();
    return hashTags;
  }
}
