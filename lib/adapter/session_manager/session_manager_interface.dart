import 'package:volunteer/entities/profile.dart';

abstract interface class SessionManagerInterface {
  Future<bool> validateAndSetCurrentUserAsync(String username, String password);

  Future<void> destroyAsync();

  Future<Profile?> getCurrentProfileAsync();
}
