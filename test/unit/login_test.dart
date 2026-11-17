import 'package:flutter_test/flutter_test.dart';
import 'package:get/get_common/get_reset.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/src/extension_instance.dart';

import 'package:volunteer/adapter/profile_repository/fake_profile_repository.dart';
import 'package:volunteer/adapter/profile_repository/profile_repository_interface.dart';
import 'package:volunteer/adapter/session_manager/fake_session_manager.dart';
import 'package:volunteer/adapter/session_manager/session_manager_interface.dart';
import 'package:volunteer/dtos/register_request_dto.dart';
import 'package:volunteer/entities/role.dart';
import 'package:volunteer/services/auth_service.dart';
import 'package:volunteer/services/fake_auth_service_binding.dart';
import 'package:volunteer/statuses/login_status.dart';

void main() {
  late AuthService service;
  late ProfileRepositoryInterface profiles;
  late SessionManagerInterface session;

  setUp(() {
    FakeAuthServiceBinding().dependencies();

    service = Get.find<AuthService>();
    session = Get.find<FakeSessionManager>();
    profiles = Get.find<FakeProfileRepository>();
  });

  tearDown(() {
    Get.reset();
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
      'achilles@gmail.com',
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
      'achilles@gmail.com',
      'Password123',
    );

    final currentProfile = await profiles.getByEmailAsync('achilles@gmail.com');

    expect(status, LoginStatus.success);
    expect(await session.getCurrentProfileAsync(), currentProfile);
  });

  test(
      "when user performs a login and then logs out, should have empty session data",
      () async {
    await service.registerAsync(
      RegisterRequestDto(
        'achilles',
        'achilles@gmail.com',
        'Password123',
        'Password123',
        Role.donor,
      ),
    );

    await service.loginAsync(
      'achilles@gmail.com',
      'Password123',
    );

    await service.logoutAsync();

    expect(await session.getCurrentProfileAsync(), isNull);
  });
}
