import 'package:flutter_test/flutter_test.dart';

import 'package:volunteer/adapter/profile_repository/fake_profile_repository.dart';
import 'package:volunteer/adapter/session_manager/fake_authenticator.dart';
import 'package:volunteer/adapter/user_repository/fake_user_repository.dart';
import 'package:volunteer/dtos/register_request_dto.dart';
import 'package:volunteer/entities/role.dart';
import 'package:volunteer/services/auth_service.dart';
import 'package:volunteer/statuses/login_status.dart';

void main() {
  late AuthService service;
  late FakeProfileRepository profiles;
  late FakeSessionManager session;
  late FakeUserRepository users;

  setUp(() {
    profiles = FakeProfileRepository();
    users = FakeUserRepository();

    session = FakeSessionManager(profiles, users);
    service = AuthService(profiles, session, users);
  });

  test('when no credential provided, should not log the user in', () async {
    final status = await service.loginAsync('', '');

    expect(status, LoginStatus.noCredentialProvided);
  });

  test('when password is incorrect, should not log the user in', () async {
    await service.registerAsync(
      RegisterRequestDto(
        'achilles',
        'achilles@gmail.com',
        'Password123',
        'Password123',
        Role.donor,
      ),
    );

    final status = await service.loginAsync(
      'achilles',
      'incorrectPassword',
    );

    expect(status, LoginStatus.incorrectCredential);
  });

  test('when password is correct, should log the user in', () async {
    await service.registerAsync(
      RegisterRequestDto(
        'achilles',
        'achilles@gmail.com',
        'Password123',
        'Password123',
        Role.donor,
      ),
    );

    final status = await service.loginAsync(
      'achilles',
      'Password123',
    );

    final currentProfile = await profiles.getByUsernameAsync('achilles');

    expect(status, LoginStatus.success);
    expect(session.currentProfile, currentProfile);
  });
}
