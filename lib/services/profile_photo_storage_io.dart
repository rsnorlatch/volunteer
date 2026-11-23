import 'dart:io';

import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

import 'profile_photo_errors.dart';

Future<String> saveProfilePhotoFile(XFile image, String email) async {
  try {
    final supportDirectory = await getApplicationSupportDirectory();
    final photoDirectory = Directory(
      '${supportDirectory.path}${Platform.pathSeparator}profile_photos',
    );
    await photoDirectory.create(recursive: true);

    final extension = _extensionFor(image.name);
    final target = File(
      '${photoDirectory.path}${Platform.pathSeparator}'
      '${_safeFileName(email)}_${DateTime.now().microsecondsSinceEpoch}'
      '.$extension',
    );
    await image.saveTo(target.path);
    return target.path;
  } on FileSystemException catch (error) {
    throw ProfilePhotoStorageException(
      'Foto profil tidak dapat disimpan di perangkat: ${error.message}',
    );
  }
}

Future<bool> profilePhotoFileExists(String path) async {
  try {
    return await File(path).exists();
  } on FileSystemException catch (error) {
    throw ProfilePhotoStorageException(
      'Foto profil tidak dapat diakses: ${error.message}',
    );
  }
}

Future<void> deleteProfilePhotoFile(String path) async {
  try {
    final file = File(path);
    if (await file.exists()) await file.delete();
  } on FileSystemException catch (error) {
    throw ProfilePhotoStorageException(
      'Foto profil tidak dapat dihapus: ${error.message}',
    );
  }
}

String _safeFileName(String email) =>
    email.trim().toLowerCase().replaceAll(RegExp(r'[^a-z0-9._-]'), '_');

String _extensionFor(String name) {
  final dot = name.lastIndexOf('.');
  if (dot < 0 || dot == name.length - 1) return 'jpg';
  final extension = name.substring(dot + 1).toLowerCase();
  const supported = {'jpg', 'jpeg', 'png', 'webp', 'heic'};
  return supported.contains(extension) ? extension : 'jpg';
}
