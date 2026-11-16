import 'package:get/instance_manager.dart';
import 'package:volunteer/adapter/profile_repository/fake_profile_repository.dart';
import 'package:volunteer/adapter/profile_repository/profile_repository_interface.dart';
import 'package:volunteer/adapter/session_manager/fake_session_manager.dart';
import 'package:volunteer/adapter/session_manager/session_manager_interface.dart';
import 'package:volunteer/adapter/user_repository/fake_user_repository.dart';
import 'package:volunteer/adapter/user_repository/user_repository_interface.dart';
import 'package:volunteer/services/auth_service.dart';

class FakeAuthServiceBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<FakeUserRepository>(() => FakeUserRepository());

    Get.lazyPut<FakeProfileRepository>(() => FakeProfileRepository());

    Get.lazyPut<FakeSessionManager>(() => FakeSessionManager(
        Get.find<FakeProfileRepository>(), Get.find<FakeUserRepository>()));

    Get.lazyPut<ProfileRepositoryInterface>(() => FakeProfileRepository());

    Get.lazyPut<AuthService>(() => AuthService(
        Get.find<FakeProfileRepository>(),
        Get.find<FakeSessionManager>(),
        Get.find<FakeUserRepository>()));
  }
}
