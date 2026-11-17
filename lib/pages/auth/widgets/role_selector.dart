import 'package:flutter/material.dart';

import 'package:volunteer/entities/role.dart';
import 'package:volunteer/shared/constants/app_colors.dart';

class RoleSelector extends StatelessWidget {
  const RoleSelector(
      {super.key, required this.selected, required this.onChanged});

  final Role selected;
  final ValueChanged<Role> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _card(
              Role.donor, Icons.favorite, 'Pendonor', 'Saya ingin mendonor'),
        ),
        const SizedBox(width: 12),
        Expanded(
          child:
              _card(Role.organizer, Icons.add, 'Organizer', 'Kelola kegiatan'),
        ),
      ],
    );
  }

  Widget _card(Role role, IconData icon, String title, String subtitle) {
    final isSelected = selected == role;
    return InkWell(
      onTap: () => onChanged(role),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryLight : AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppColors.primaryColor : AppColors.border,
          ),
        ),
        child: Column(
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon,
                    size: 16,
                    color: isSelected
                        ? AppColors.primaryColor
                        : AppColors.textPrimary),
                const SizedBox(width: 6),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: isSelected
                        ? AppColors.primaryColor
                        : AppColors.textPrimary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(subtitle,
                style: const TextStyle(
                    fontSize: 11, color: AppColors.textSecondary)),
          ],
        ),
      ),
    );
  }
}
