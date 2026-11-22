import 'package:flutter_test/flutter_test.dart';
import 'package:get/get_common/get_reset.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/src/extension_instance.dart';

import 'package:volunteer/adapter/profile_repository/fake_profile_repository.dart';
import 'package:volunteer/adapter/user_repository/fake_user_repository.dart';
import 'package:volunteer/adapter/session_manager/local_session_manager.dart';
import 'package:volunteer/dtos/register_request_dto.dart';
import 'package:volunteer/entities/role.dart';
import 'package:volunteer/services/auth_service.dart';
import 'package:volunteer/services/fake_auth_service_binding.dart';
import 'package:volunteer/statuses/register_status.dart';

void main() {
  late AuthService service;
  late FakeProfileRepository profiles;
  late FakeUserRepository users;

  setUp(() {
    FakeAuthServiceBinding().dependencies();

    service = Get.find<AuthService>();
    profiles = Get.find<FakeProfileRepository>();
    users = Get.find<FakeUserRepository>();
  });

  tearDown(() async {
    Get.reset();
  });

  test('when no credential is provided, should not create an account',
      () async {
    final status = await service.registerAsync(
      RegisterRequestDto('', '', '', '', Role.donor),
    );

    expect(status, Registerstatus.emptyCredential);
    expect(await profiles.getAllAsync(), isEmpty);
    expect(users.users, isEmpty);
  });

  test('when password does not match, should not create an account', () async {
    final status = await service.registerAsync(
      RegisterRequestDto(
        'achilles',
        'achilles@gmail.com',
        'password',
        'notpassword',
        Role.donor,
      ),
    );

    expect(status, Registerstatus.passwordDoNotMatch);
    expect(await profiles.getAllAsync(), isEmpty);
    expect(users.users, isEmpty);
  });

  test('when password matches, should create an account', () async {
    final status = await service.registerAsync(
      RegisterRequestDto(
        'tortoise',
        'tortoise@gmail.com',
        'password',
        'password',
        Role.donor,
      ),
    );

    expect(status, Registerstatus.success);
    expect(await profiles.getAllAsync(), isNotEmpty);
    expect(users.users, isNotEmpty);
  });

  test('when username is already taken, should not create an account',
      () async {
    await service.registerAsync(
      RegisterRequestDto(
        'achilles',
        'achilles@gmail.com',
        'password',
        'password',
        Role.donor,
      ),
    );

    final status = await service.registerAsync(
      RegisterRequestDto(
        'achilles',
        'achilles@gmail.com',
        'password',
        'password',
        Role.donor,
      ),
    );

    expect(status, Registerstatus.usernameTaken);
    expect((await profiles.getAllAsync()).length, 1);
    expect(users.users.length, 1);
  });

  test('when registering a valid credential, profile should reference a user',
      () async {
    await service.registerAsync(
      RegisterRequestDto(
        'achilles',
        'achilles@gmail.com',
        'password',
        'password',
        Role.donor,
      ),
    );

    final profile = await profiles.getByUsernameAsync('achilles');

    expect(profile, isNotNull);
    expect(profile!.userId, isNotNull);
  });

  test('when registering a donor, profile stores the selected blood type',
      () async {
    await service.registerAsync(
      RegisterRequestDto(
        'achilles',
        'achilles@gmail.com',
        'Password123',
        'Password123',
        Role.donor,
        bloodType: 'O+',
      ),
    );

    final profile = await profiles.getByEmailAsync('achilles@gmail.com');

    expect(profile, isNotNull);
    expect(profile!.bloodType, 'O+');
  });

  test('when registering an organizer, profile stores the selected blood type',
      () async {
    await service.registerAsync(
      RegisterRequestDto(
        'organizer',
        'organizer@gmail.com',
        'Password123',
        'Password123',
        Role.organizer,
        bloodType: 'AB-',
      ),
    );

    final profile = await profiles.getByEmailAsync('organizer@gmail.com');

    expect(profile, isNotNull);
    expect(profile!.bloodType, 'AB-');
  });

  test('reset password updates the existing account credentials', () async {
    await service.registerAsync(
      RegisterRequestDto(
        'achilles',
        'achilles@gmail.com',
        'Password123',
        'Password123',
        Role.donor,
      ),
    );

    expect(
      await service.resetPasswordAsync(' ACHILLES@gmail.com ', 'NewPass123'),
      isTrue,
    );
    final session = LocalSessionManager(profiles, users);
    expect(
      await session.validateAndSetCurrentUserAsync(
          'achilles@gmail.com', 'Password123'),
      isFalse,
    );
    expect(
      await session.validateAndSetCurrentUserAsync(
          'achilles@gmail.com', 'NewPass123'),
      isTrue,
    );
  });

  test('reset password does not modify an unknown account', () async {
    expect(
      await service.resetPasswordAsync('missing@example.com', 'NewPass123'),
      isFalse,
    );
    expect(users.users, isEmpty);
  });
}
