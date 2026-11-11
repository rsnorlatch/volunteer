import 'package:flutter_test/flutter_test.dart';
import 'package:volunteer/adapter/authenticator/fake_authenticator.dart';
import 'package:volunteer/adapter/profile_repository/fake_profile_repository.dart';
import 'package:volunteer/services/auth_service.dart';
import 'package:volunteer/statuses/login_status.dart';

void main() {
  late AuthService service;
  late FakeProfileRepository profiles;
  late FakeSessionManager auth;

  setUp(() {
    profiles = FakeProfileRepository();
    auth = FakeSessionManager(profiles);
    service = AuthService(profiles, auth);
  });

  test("when no credential provided, should not logged the user in", () async {
    final status = await service.loginAsync("", "");

    expect(status, LoginStatus.noCredentialProvided);
  });

  test("when password is incorrect, should not logged the user in", () async {
    await service.registerAsync("achilles", "Password123", "Password123");
    final status = await service.loginAsync("achilles", "incorrectPassword");

    expect(status, LoginStatus.incorrectCredential);
  });

  test("when password is correct, should logged the user in", () async {
    await service.registerAsync("tortoise", "Password123", "Password123");
    final status = await service.loginAsync("tortoise", "Password123");

    final currentProfile = await profiles.getByUsernameAsync("tortoise");

    expect(status, LoginStatus.success);
    expect(auth.currentProfile, currentProfile);
  });
}
