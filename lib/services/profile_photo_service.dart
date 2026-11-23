import 'package:file_selector/file_selector.dart' as file_selector;
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'profile_photo_errors.dart';
import 'profile_photo_storage.dart';

class ProfilePhotoService {
  ProfilePhotoService({ImagePicker? picker})
      : _picker = picker ?? ImagePicker();

  final ImagePicker _picker;
  static const _maxPhotoSizeBytes = 10 * 1024 * 1024;
  static const _imageExtensions = {'jpg', 'jpeg', 'png', 'webp'};

  String _keyFor(String email) => 'profile_photo_${email.trim().toLowerCase()}';

  Future<String?> loadPath(String email) async {
    final preferences = await SharedPreferences.getInstance();
    final path = preferences.getString(_keyFor(email));
    if (path == null || path.isEmpty) return null;

    if (!await profilePhotoFileExists(path)) {
      await preferences.remove(_keyFor(email));
      return null;
    }
    return path;
  }

  Future<String?> pickAndSave(
    String email,
    ImageSource source,
  ) async {
    if (email.trim().isEmpty) {
      throw const ProfilePhotoStorageException(
        'Masuk ke akun terlebih dahulu untuk menyimpan foto profil.',
      );
    }

    final selected = await _picker.pickImage(
      source: source,
      maxWidth: 1200,
      maxHeight: 1200,
      imageQuality: 85,
    );
    if (selected == null) return null;
    return _saveSelected(email, selected);
  }

  Future<String?> pickFileAndSave(String email) async {
    if (email.trim().isEmpty) {
      throw const ProfilePhotoStorageException(
        'Masuk ke akun terlebih dahulu untuk menyimpan foto profil.',
      );
    }

    final selected = await file_selector.openFile(
      acceptedTypeGroups: [_imageTypeGroup()],
    );
    if (selected == null) return null;
    if (!_isSupportedImage(selected.name)) {
      throw const ProfilePhotoStorageException(
        'Pilih file gambar JPG, PNG, atau WebP.',
      );
    }
    return _saveSelected(email, selected);
  }

  file_selector.XTypeGroup _imageTypeGroup() {
    if (kIsWeb) {
      return const file_selector.XTypeGroup(
        label: 'images',
        webWildCards: ['image/*'],
      );
    }
    return switch (defaultTargetPlatform) {
      TargetPlatform.android => const file_selector.XTypeGroup(
          label: 'images',
          mimeTypes: ['image/*'],
        ),
      TargetPlatform.iOS ||
      TargetPlatform.macOS =>
        const file_selector.XTypeGroup(
          label: 'images',
          uniformTypeIdentifiers: ['public.image'],
        ),
      _ => const file_selector.XTypeGroup(
          label: 'images',
          extensions: ['jpg', 'jpeg', 'png', 'webp'],
        ),
    };
  }

  bool _isSupportedImage(String name) {
    final dot = name.lastIndexOf('.');
    if (dot < 0 || dot == name.length - 1) return false;
    return _imageExtensions.contains(name.substring(dot + 1).toLowerCase());
  }

  Future<String> _saveSelected(String email, XFile selected) async {
    if (await selected.length() > _maxPhotoSizeBytes) {
      throw const ProfilePhotoStorageException(
        'Ukuran foto maksimal 10 MB.',
      );
    }

    final preferences = await SharedPreferences.getInstance();
    final path = await saveProfilePhotoFile(selected, email);
    final key = _keyFor(email);
    final previousPath = preferences.getString(key);
    if (!await preferences.setString(key, path)) {
      await deleteProfilePhotoFile(path);
      throw const ProfilePhotoStorageException(
        'Foto profil tidak dapat disimpan di perangkat.',
      );
    }

    if (previousPath != null && previousPath != path) {
      await deleteProfilePhotoFile(previousPath);
    }
    return path;
  }

  Future<void> remove(String email) async {
    final preferences = await SharedPreferences.getInstance();
    final path = preferences.getString(_keyFor(email));
    await preferences.remove(_keyFor(email));
    if (path == null || path.isEmpty) return;
    await deleteProfilePhotoFile(path);
  }
}
