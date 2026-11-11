import 'package:flutter_test/flutter_test.dart';
import 'package:volunteer/adapter/authenticator/fake_authenticator.dart';
import 'package:volunteer/adapter/profile_repository/fake_profile_repository.dart';
import 'package:volunteer/services/auth_service.dart';
import 'package:volunteer/statuses/register_status.dart';

void main() {
  late AuthService service;
  late FakeProfileRepository profiles;
  late FakeAuthenticator auth;

  setUp(() {
    profiles = FakeProfileRepository();
    auth = FakeAuthenticator(profiles);
    service = AuthService(profiles, auth);
  });

  test(
    "when no credential is provided, should not create an account",
    () async {
      final status = await service.registerAsync("", "", "");

      expect(status, Registerstatus.emptyCredential);
      expect(await profiles.getAllAsync(), isEmpty);
    },
  );

  test("when password do not match, should not create an account", () async {
    final status = await service.registerAsync(
      "achilles",
      "password",
      "notpassword",
    );

    expect(status, Registerstatus.passwordDoNotMatch);
    expect(await profiles.getAllAsync(), isEmpty);
  });

  test("when password does match, should create account", () async {
    final status = await service.registerAsync(
      "tortoise",
      "mypassword",
      "mypassword",
    );

    expect(status, Registerstatus.success);
    expect(await profiles.getAllAsync(), isNotEmpty);
  });

  test("when username is already taken, should not create account", () async {
    await service.registerAsync("achilles", "password", "password");

    final status = await service.registerAsync(
      "achilles",
      "password",
      "password",
    );

    expect(status, Registerstatus.usernameTaken);
    expect((await profiles.getAllAsync()).length, 1);
  });
}
