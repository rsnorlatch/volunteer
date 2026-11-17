import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:volunteer/adapter/profile_repository/fake_profile_repository.dart';
import 'package:volunteer/adapter/profile_repository/profile_repository_interface.dart';
import 'package:volunteer/adapter/session_manager/local_session_manager.dart';
import 'package:volunteer/adapter/session_manager/session_manager_interface.dart';
import 'package:volunteer/adapter/user_repository/fake_user_repository.dart';
import 'package:volunteer/core/constants/app_constants.dart';
import 'package:volunteer/core/routes/app_pages.dart';
import 'package:volunteer/core/routes/app_routes.dart';
import 'package:volunteer/core/routes/initial_binding.dart';
import 'package:volunteer/core/theme/app_theme.dart';
import 'package:volunteer/services/auth_service.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  final profiles = FakeProfileRepository();
  final users = FakeUserRepository();
  final session = LocalSessionManager(profiles, users);

  Get.put<ProfileRepositoryInterface>(profiles, permanent: true);
  Get.put<SessionManagerInterface>(session, permanent: true);
  Get.put<AuthService>(AuthService(profiles, session, users), permanent: true);

  runApp(const VolunteerApp());
}

class VolunteerApp extends StatelessWidget {
  const VolunteerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      initialRoute: AppRoutes.splash,
      initialBinding: InitialBinding(),
      getPages: AppPages.pages,
    );
  }
}
