import 'package:flutter/material.dart';

import 'package:volunteer/data/models/registration.dart';
import 'package:volunteer/shared/constants/app_colors.dart';

/// Kartu putih dengan border tipis (dipakai di hampir semua layar).
class AppCard extends StatelessWidget {
  const AppCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.onTap,
    this.color,
    this.borderColor,
  });

  final Widget child;
  final EdgeInsets padding;
  final VoidCallback? onTap;
  final Color? color;
  final Color? borderColor;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Material(
        color: color ?? AppColors.surface,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: borderColor ?? AppColors.border),
        ),
        child: InkWell(
          onTap: onTap,
          child: Padding(padding: padding, child: child),
        ),
      ),
    );
  }
}

enum PillTone { primary, success, danger, neutral }

class StatusPill extends StatelessWidget {
  const StatusPill(this.text, {super.key, this.tone = PillTone.primary});

  final String text;
  final PillTone tone;

  factory StatusPill.registration(RegistrationStatus status) {
    final tone = switch (status) {
      RegistrationStatus.pending => PillTone.primary,
      RegistrationStatus.accepted => PillTone.success,
      RegistrationStatus.rejected => PillTone.danger,
    };
    return StatusPill(status.label, tone: tone);
  }

  @override
  Widget build(BuildContext context) {
    final (bg, fg) = switch (tone) {
      PillTone.primary => (AppColors.primaryLight, AppColors.primaryColor),
      PillTone.success => (AppColors.successLight, AppColors.success),
      PillTone.danger => (AppColors.dangerLight, AppColors.danger),
      PillTone.neutral => (const Color(0xFFEEF0F2), AppColors.textSecondary),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
      decoration:
          BoxDecoration(color: bg, borderRadius: BorderRadius.circular(20)),
      child: Text(
        text,
        style: TextStyle(color: fg, fontSize: 12, fontWeight: FontWeight.w700),
      ),
    );
  }
}

/// Chip filter. [white] = gaya putih untuk yang tidak terpilih (Cari fasilitas).
class AppChoicePill extends StatelessWidget {
  const AppChoicePill({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
    this.white = false,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;
  final bool white;

  @override
  Widget build(BuildContext context) {
    final bg = selected
        ? AppColors.primaryColor
        : (white ? AppColors.surface : AppColors.primaryLight);
    final fg = selected
        ? Colors.white
        : (white ? AppColors.textPrimary : AppColors.primaryColor);
    return Material(
      color: bg,
      clipBehavior: Clip.antiAlias,
      shape: StadiumBorder(
        side: (white && !selected)
            ? const BorderSide(color: AppColors.border)
            : BorderSide.none,
      ),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
          child: Text(
            label,
            style: TextStyle(
                color: fg, fontSize: 12.5, fontWeight: FontWeight.w600),
          ),
        ),
      ),
    );
  }
}

class AppSearchField extends StatelessWidget {
  const AppSearchField({
    super.key,
    required this.hint,
    this.onChanged,
    this.controller,
    this.icon = Icons.search,
  });

  final String hint;
  final ValueChanged<String>? onChanged;
  final TextEditingController? controller;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      onChanged: onChanged,
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: Icon(icon, size: 20, color: AppColors.textSecondary),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
    );
  }
}

class EmptyState extends StatelessWidget {
  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
  });

  final IconData icon;
  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 48, color: AppColors.disabled),
            const SizedBox(height: 12),
            Text(title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary)),
            const SizedBox(height: 4),
            Text(message,
                textAlign: TextAlign.center,
                style: const TextStyle(
                    fontSize: 13, color: AppColors.textSecondary)),
          ],
        ),
      ),
    );
  }
}
