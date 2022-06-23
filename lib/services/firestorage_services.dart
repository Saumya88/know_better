import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

Future<Widget> getImage(BuildContext context, String imageName) async {
  Image image = Image.asset('asstes/images/a.png');
  await FireStorageService.loadImage(context, imageName).then((value) {
    image = Image.network(
      value.toString(),
      fit: BoxFit.scaleDown,
    );
  });
  return image;
}

class FireStorageService extends ChangeNotifier {
  FireStorageService();
  // ignore: non_constant_identifier_names
  static Future<dynamic> loadImage(BuildContext context, String Image) async {
    return FirebaseStorage.instance.ref().child(Image).getDownloadURL();
  }
}
