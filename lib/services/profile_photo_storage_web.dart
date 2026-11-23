import 'dart:convert';

import 'package:image_picker/image_picker.dart';

Future<String> saveProfilePhotoFile(XFile image, String email) async {
  final bytes = await image.readAsBytes();
  final mimeType = image.mimeType ?? 'image/jpeg';
  return 'data:$mimeType;base64,${base64Encode(bytes)}';
}

Future<bool> profilePhotoFileExists(String path) async =>
    path.startsWith('data:image/');

Future<void> deleteProfilePhotoFile(String path) async {}
