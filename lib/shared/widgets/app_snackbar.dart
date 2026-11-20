import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:volunteer/shared/constants/app_colors.dart';

void showAppSnack(String message, {bool error = false, bool success = false}) {
  Get.rawSnackbar(
    icon: success
        ? const Icon(Icons.check_circle, color: Colors.white)
        : null,
    message: message,
    backgroundColor: error
        ? AppColors.danger
        : success
            ? AppColors.success
            : AppColors.textPrimary,
    margin: const EdgeInsets.all(16),
    borderRadius: 12,
    snackPosition: SnackPosition.BOTTOM,
    duration: const Duration(seconds: 3),
  );
}
