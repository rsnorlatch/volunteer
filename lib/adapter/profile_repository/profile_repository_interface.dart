import 'package:volunteer/entities/profile.dart';

abstract interface class ProfileRepositoryInterface {
  Future<void> insertAsync(Profile profile);

  Future<void> updateAsync(Profile profile);

  Future<List<Profile>> getAllAsync();

  Future<Profile?> getByUsernameAsync(String username);

  Future<Profile?> getByEmailAsync(String email);
}
