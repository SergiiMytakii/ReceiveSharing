import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';

class FirebaseServise {
  static Future<String> uploadFile(File? file) async {
    String filePath = '';
    String url = '';

    final storageRef = FirebaseStorage.instance.ref();
    final screenshotRef = storageRef.child('screenshot');
    if (file != null) {
      filePath = file.path;
    } else {
      throw ('file is null');
    }

    try {
      await screenshotRef
          .putFile(file)
          .then((p0) async => url = await screenshotRef.getDownloadURL());
    } on FirebaseException catch (e) {
      print(e.message);
    }
    return url;
  }

  static Future<String> getUrl(String path, int imageName) async {
    final storage = FirebaseStorage.instance;
    final ref = storage.ref(path);
    final url = await ref.child('$imageName.jpeg').getDownloadURL();
    //Logger().e(url);

    return url;
  }
}
