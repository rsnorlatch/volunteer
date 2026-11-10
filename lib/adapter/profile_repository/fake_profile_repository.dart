import 'package:volunteer/entities/profile.dart';

class FakeProfileRepository {
  List<Profile> profiles = [];

  Future<void> insertAsync(Profile profile) async {
    profiles.add(profile);
  }

  Future<List<Profile>> getAllAsync() async {
    return profiles;
  }

  Future<Profile?> getByUsernameAsync(String username) async {
    return profiles
        .where((profile) => profile.username == username)
        .firstOrNull;
  }
}
