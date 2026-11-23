import 'package:image_picker/image_picker.dart';

import 'profile_photo_storage_io.dart'
    if (dart.library.js_interop) 'profile_photo_storage_web.dart' as storage;

Future<String> saveProfilePhotoFile(XFile image, String email) =>
    storage.saveProfilePhotoFile(image, email);

Future<bool> profilePhotoFileExists(String path) =>
    storage.profilePhotoFileExists(path);

Future<void> deleteProfilePhotoFile(String path) =>
    storage.deleteProfilePhotoFile(path);
