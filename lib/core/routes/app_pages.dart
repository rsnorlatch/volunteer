import 'package:get/get.dart';

import 'package:volunteer/core/routes/app_routes.dart';
import 'package:volunteer/pages/auth/login_page.dart';
import 'package:volunteer/pages/auth/signup_page.dart';
import 'package:volunteer/pages/donor/activity_detail_page.dart';
import 'package:volunteer/pages/donor/facility_search_page.dart';
import 'package:volunteer/pages/donor/history_page.dart';
import 'package:volunteer/pages/donor/main_shell_page.dart';
import 'package:volunteer/pages/donor/notifications_page.dart';
import 'package:volunteer/pages/donor/registration_page.dart';
import 'package:volunteer/pages/donor/registration_status_page.dart';
import 'package:volunteer/pages/donor/shell_controller.dart';
import 'package:volunteer/pages/organizer/activity_form_page.dart';
import 'package:volunteer/pages/organizer/dashboard_page.dart';
import 'package:volunteer/pages/organizer/manage_activities_page.dart';
import 'package:volunteer/pages/organizer/registrants_page.dart';
import 'package:volunteer/pages/profile/edit_profile_page.dart';
import 'package:volunteer/pages/splash/splash_page.dart';

class AppPages {
  AppPages._();

  static final pages = <GetPage<dynamic>>[
    GetPage(name: AppRoutes.splash, page: () => const SplashPage()),
    GetPage(name: AppRoutes.login, page: () => const LoginPage()),
    GetPage(name: AppRoutes.signup, page: () => const SignUpPage()),
    GetPage(
      name: AppRoutes.home,
      page: () => const MainShellPage(),
      binding: ShellBinding(),
    ),
    GetPage(
        name: AppRoutes.activityDetail, page: () => const ActivityDetailPage()),
    GetPage(name: AppRoutes.registration, page: () => const RegistrationPage()),
    GetPage(
        name: AppRoutes.registrationStatus,
        page: () => const RegistrationStatusPage()),
    GetPage(
        name: AppRoutes.facilitySearch, page: () => const FacilitySearchPage()),
    GetPage(
        name: AppRoutes.notifications, page: () => const NotificationsPage()),
    GetPage(name: AppRoutes.history, page: () => const HistoryPage()),
    GetPage(name: AppRoutes.editProfile, page: () => const EditProfilePage()),
    GetPage(
        name: AppRoutes.organizerDashboard, page: () => const DashboardPage()),
    GetPage(
        name: AppRoutes.createActivity, page: () => const ActivityFormPage()),
    GetPage(
        name: AppRoutes.editActivity,
        page: () => const ActivityFormPage(isEdit: true)),
    GetPage(
        name: AppRoutes.manageActivities,
        page: () => const ManageActivitiesPage()),
    GetPage(
        name: AppRoutes.manageRegistrants, page: () => const RegistrantsPage()),
  ];
}
