import 'package:volunteer/entities/profile.dart';

abstract interface class SessionManagerInterface {
  Future<bool> validateAndSetCurrentUserAsync(String email, String password);

  Future<void> destroyAsync();

  Future<Profile?> getCurrentProfileAsync();
}
