import 'package:flutter/material.dart';

import 'package:volunteer/core/constants/app_constants.dart';
import 'package:volunteer/shared/constants/app_colors.dart';

/// Grid 4 kolom pilihan golongan darah (dipakai multi/single oleh pemanggil).
class BloodTypeSelector extends StatelessWidget {
  const BloodTypeSelector(
      {super.key, required this.selected, required this.onTap});

  final Iterable<String> selected;
  final ValueChanged<String> onTap;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, c) {
      const gap = 10.0;
      final w = (c.maxWidth - gap * 3) / 4;
      return Wrap(
        spacing: gap,
        runSpacing: gap,
        children: [
          for (final t in AppConstants.bloodTypes)
            SizedBox(
              width: w,
              height: 38,
              child: Material(
                color: selected.contains(t)
                    ? AppColors.primaryLight
                    : AppColors.surface,
                clipBehavior: Clip.antiAlias,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(
                    color: selected.contains(t)
                        ? AppColors.primaryColor
                        : AppColors.border,
                  ),
                ),
                child: InkWell(
                  onTap: () => onTap(t),
                  child: Center(
                    child: Text(
                      t,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: selected.contains(t)
                            ? AppColors.primaryColor
                            : AppColors.textPrimary,
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      );
    });
  }
}

/// Field yang tampil seperti input, tapi membuka date/time picker saat diketuk.
class PickerField extends StatelessWidget {
  const PickerField({
    super.key,
    required this.label,
    required this.hint,
    required this.onTap,
    this.value,
    this.errorText,
  });

  final String label;
  final String hint;
  final String? value;
  final String? errorText;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary)),
        const SizedBox(height: 8),
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 17),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: errorText != null ? AppColors.danger : AppColors.border,
              ),
            ),
            child: Text(
              value ?? hint,
              style: TextStyle(
                fontSize: 16,
                color: value == null
                    ? AppColors.textSecondary
                    : AppColors.textPrimary,
              ),
            ),
          ),
        ),
        if (errorText != null)
          Padding(
            padding: const EdgeInsets.only(top: 6, left: 4),
            child: Text(errorText!,
                style: const TextStyle(fontSize: 12, color: AppColors.danger)),
          ),
      ],
    );
  }
}
