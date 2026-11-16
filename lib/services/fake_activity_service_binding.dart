import 'package:get/instance_manager.dart';
import 'package:volunteer/adapter/activity_repository/fake_activity_repository.dart';
import 'package:volunteer/services/activity_service.dart';

class FakeActivityServiceBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<FakeActivityRepository>(() => FakeActivityRepository());

    Get.lazyPut(() => ActivityService(Get.find<FakeActivityRepository>()));
  }
}
