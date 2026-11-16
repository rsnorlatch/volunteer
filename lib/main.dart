import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'adapter/profile_repository/fake_profile_repository.dart';
import 'adapter/session_manager/fake_authenticator.dart';
import 'adapter/user_repository/fake_user_repository.dart';
import 'core/theme/app_theme.dart';
import 'pages/splash/splash_page.dart';
import 'services/auth_service.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  final profiles = FakeProfileRepository();
  final users = FakeUserRepository();
  final session = FakeSessionManager(profiles, users);
  Get.put<AuthService>(AuthService(profiles, session, users), permanent: true);
  runApp(const VolunteerApp());
}

class VolunteerApp extends StatelessWidget {
  const VolunteerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Volunteer - BloodDonor',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const SplashPage(),
    );
  }
}
