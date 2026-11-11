import 'package:volunteer/adapter/profile_repository/profile_repository_interface.dart';
import 'package:volunteer/entities/profile.dart';

class FakeProfileRepository implements ProfileRepositoryInterface {
  List<Profile> profiles = [];

  @override
  Future<void> insertAsync(Profile profile) async {
    profiles.add(profile);
  }

  @override
  Future<List<Profile>> getAllAsync() async {
    return profiles;
  }

  @override
  Future<Profile?> getByUsernameAsync(String username) async {
    return profiles
        .where((profile) => profile.username == username)
        .firstOrNull;
  }
}
