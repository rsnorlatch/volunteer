import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:volunteer/core/routes/app_routes.dart';
import 'package:volunteer/shared/constants/app_colors.dart';

class OrganizerBottomNavigationBar extends StatelessWidget {
  const OrganizerBottomNavigationBar({super.key, required this.currentIndex});

  final int currentIndex;

  void _navigate(int index) {
    final route = switch (index) {
      0 => AppRoutes.organizerDashboard,
      1 => AppRoutes.manageActivities,
      2 => AppRoutes.manageRegistrants,
      _ => AppRoutes.organizerProfile,
    };
    if (Get.currentRoute != route || index == 2) {
      Get.offAllNamed(route);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: _navigate,
        type: BottomNavigationBarType.fixed,
        backgroundColor: AppColors.surface,
        elevation: 0,
        selectedItemColor: AppColors.primaryColor,
        unselectedItemColor: AppColors.textPrimary,
        selectedFontSize: 11,
        unselectedFontSize: 11,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            label: 'Beranda',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.format_list_bulleted),
            label: 'Kegiatan',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.check),
            label: 'Konfirmasi',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            label: 'Profil',
          ),
        ],
      ),
    );
  }
}
