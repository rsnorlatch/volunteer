import 'package:volunteer/adapter/profile_repository/profile_repository_interface.dart';
import 'package:volunteer/entities/profile.dart';

class FakeProfileRepository implements ProfileRepositoryInterface {
  final List<Profile> profiles = [];

  @override
  Future<void> insertAsync(Profile profile) async {
    profiles.add(profile);
  }

  @override
  Future<List<Profile>> getAllAsync() async => List.unmodifiable(profiles);

  @override
  Future<Profile?> getByUsernameAsync(String username) async {
    for (final profile in profiles) {
      if (profile.username.toLowerCase() == username.toLowerCase()) {
        return profile;
      }
    }
    return null;
  }

  @override
  Future<Profile?> getByEmailAsync(String email) async {
    for (final profile in profiles) {
      if (profile.email.toLowerCase() == email.toLowerCase()) {
        return profile;
      }
    }
    return null;
  }
}
