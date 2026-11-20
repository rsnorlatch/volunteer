import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:volunteer/core/constants/app_constants.dart';
import 'package:volunteer/core/routes/app_routes.dart';
import 'package:volunteer/shared/constants/app_colors.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 2), () {
      if (!mounted) return;
      Get.offNamed(AppRoutes.login);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryColor,
      body: SafeArea(
        child: Stack(
          children: [
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      height: 180,
                      width: 180,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(48),
                      ),
                      child: const Icon(
                        Icons.favorite,
                        color: AppColors.primaryColor,
                        size: 84,
                      ),
                    ),
                    const SizedBox(height: 36),
                    const Text(
                      'Volunteer',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 48,
                        fontWeight: FontWeight.w800,
                        height: 1,
                      ),
                    ),
                    const Text(
                      'BloodDonor',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.w700,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 18),
                    const Text(
                      AppConstants.tagline,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Color(0xFFF4C8D1),
                        fontSize: 18,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const Positioned(
              left: 0,
              right: 0,
              bottom: 40,
              child: Center(
                child: Text(
                  'DONOR  •  ORGANIZER',
                  style: TextStyle(
                    color: Color(0xFFF4C8D1),
                    fontSize: 18,
                    letterSpacing: 4,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
