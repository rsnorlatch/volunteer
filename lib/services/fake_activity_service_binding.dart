import 'package:get/instance_manager.dart';
import 'package:volunteer/adapter/activity_repository/fake_activity_repository.dart';
import 'package:volunteer/adapter/profile_repository/fake_profile_repository.dart';
import 'package:volunteer/adapter/session_manager/fake_session_manager.dart';
import 'package:volunteer/services/activity_service.dart';

class FakeActivityServiceBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<FakeActivityRepository>(() => FakeActivityRepository());

    Get.lazyPut<FakeProfileRepository>(() => FakeProfileRepository());

    Get.lazyPut<FakeSessionManager>(() =>
        FakeSessionManager(Get.find<FakeProfileRepository>(), "Password123"));

    Get.lazyPut(() => ActivityService(
        Get.find<FakeActivityRepository>(), Get.find<FakeSessionManager>()));
  }
}
