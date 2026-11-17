import 'package:get/get.dart';

import 'package:volunteer/controllers/activity_controller.dart';
import 'package:volunteer/controllers/facility_controller.dart';
import 'package:volunteer/controllers/notification_controller.dart';
import 'package:volunteer/controllers/profile_controller.dart';
import 'package:volunteer/pages/auth/auth_controller.dart';

class InitialBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(ProfileController(), permanent: true);
    Get.put(NotificationController(), permanent: true);
    Get.put(ActivityController(), permanent: true);
    Get.put(FacilityController(), permanent: true);
    Get.put(AuthController(), permanent: true);
  }
}
