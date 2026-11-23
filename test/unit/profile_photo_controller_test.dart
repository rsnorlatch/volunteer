import 'package:flutter_test/flutter_test.dart';
import 'package:image_picker/image_picker.dart';
import 'package:volunteer/controllers/profile_controller.dart';
import 'package:volunteer/entities/profile.dart';
import 'package:volunteer/entities/role.dart';
import 'package:volunteer/services/profile_photo_service.dart';

void main() {
  test('profile photo is loaded, updated, and removed for the current account',
      () async {
    final photoService = _FakeProfilePhotoService()
      ..savedByEmail['donor@example.com'] = '/photos/avatar.jpg';
    final profile = ProfileController(photoService: photoService)
      ..setFromProfile(Profile('Donor', 'donor@example.com', Role.donor));

    await profile.loadProfilePhoto();
    expect(profile.avatarPath.value, '/photos/avatar.jpg');

    photoService.nextPickedPath = '/photos/new-avatar.jpg';
    expect(await profile.updateProfilePhoto(ImageSource.gallery), isTrue);
    expect(profile.avatarPath.value, '/photos/new-avatar.jpg');

    photoService.nextFilePath = '/photos/file-avatar.jpg';
    expect(await profile.updateProfilePhotoFromFile(), isTrue);
    expect(profile.avatarPath.value, '/photos/file-avatar.jpg');

    await profile.removeProfilePhoto();
    expect(profile.avatarPath.value, isNull);
    expect(photoService.savedByEmail, isEmpty);
  });

  test('cancelling photo selection keeps the existing avatar', () async {
    final photoService = _FakeProfilePhotoService()
      ..savedByEmail['donor@example.com'] = '/photos/avatar.jpg';
    final profile = ProfileController(photoService: photoService)
      ..setFromProfile(Profile('Donor', 'donor@example.com', Role.donor));
    await profile.loadProfilePhoto();

    expect(await profile.updateProfilePhoto(ImageSource.gallery), isFalse);
    expect(profile.avatarPath.value, '/photos/avatar.jpg');
  });
}

class _FakeProfilePhotoService extends ProfilePhotoService {
  final savedByEmail = <String, String>{};
  String? nextPickedPath;
  String? nextFilePath;

  @override
  Future<String?> loadPath(String email) async => savedByEmail[email];

  @override
  Future<String?> pickAndSave(String email, ImageSource source) async {
    final path = nextPickedPath;
    if (path != null) savedByEmail[email] = path;
    return path;
  }

  @override
  Future<String?> pickFileAndSave(String email) async {
    final path = nextFilePath;
    if (path != null) savedByEmail[email] = path;
    return path;
  }

  @override
  Future<void> remove(String email) async {
    savedByEmail.remove(email);
  }
}
