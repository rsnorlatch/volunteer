import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:volunteer/shared/constants/app_colors.dart';

void showAppSnack(String message, {bool error = false}) {
  Get.rawSnackbar(
    message: message,
    backgroundColor: error ? AppColors.danger : AppColors.textPrimary,
    margin: const EdgeInsets.all(16),
    borderRadius: 12,
    snackPosition: SnackPosition.BOTTOM,
    duration: const Duration(seconds: 3),
  );
}
