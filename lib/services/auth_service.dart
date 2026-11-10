import 'package:volunteer/adapter/profile_repository/fake_profile_repository.dart';
import 'package:volunteer/entities/profile.dart';
import 'package:volunteer/statuses/RegisterStatus.dart';

class AuthService {
  new(FakeProfileRepository this._profiles);

  final FakeProfileRepository _profiles;

  Future<Registerstatus> registerAsync(
    String username,
    String password,
    String confirmPassword,
  ) async {
    if (username == "" || password == "" || confirmPassword == "") {
      return Registerstatus.emptyCredential;
    }

    if (password != confirmPassword) {
      return Registerstatus.passwordDoNotMatch;
    }

    final profile = await _profiles.getByUsernameAsync(username);

    if (profile != null) {
      return Registerstatus.usernameTaken;
    }

    await _profiles.insertAsync(Profile(username));

    return Registerstatus.success;
  }
}
