// ignore_for_file: avoid_classes_with_only_static_members

import 'dart:io';
import 'dart:math';

import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

class UrlToFile {
  static Future<File> urlToFile(String imageUrl) async {
// generate random number.
    final rng = Random();
// get temporary directory of device.
    final Directory tempDir = await getTemporaryDirectory();
// get temporary path from temporary directory.
    final String tempPath = tempDir.path;
// create a new file in temporary path with random file name.
    final File file = File('$tempPath${rng.nextInt(100)}.png');
// call http.get method and pass imageUrl into it to get response.
    final http.Response response = await http.get(Uri.parse(imageUrl));
// write bodyBytes received in response to file.
    await file.writeAsBytes(response.bodyBytes);
// now return the file which is created with random name in
// temporary directory and image bytes from response is written to // that file.
    return file;
  }
}
