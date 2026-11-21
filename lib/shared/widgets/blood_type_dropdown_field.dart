import 'package:flutter/material.dart';

import 'package:volunteer/core/constants/app_constants.dart';
import 'package:volunteer/shared/constants/app_colors.dart';

class BloodTypeDropdownField extends StatelessWidget {
  const BloodTypeDropdownField({
    super.key,
    required this.initialValue,
    required this.onChanged,
    this.validator,
  });

  final String? initialValue;
  final ValueChanged<String?> onChanged;
  final String? Function(String?)? validator;

  @override
  Widget build(BuildContext context) {
    return FormField<String>(
      initialValue: initialValue,
      validator: validator,
      builder: (field) => LayoutBuilder(
        builder: (context, constraints) => InputDecorator(
          decoration: InputDecoration(errorText: field.errorText),
          isEmpty: field.value == null,
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: field.value,
              isDense: true,
              isExpanded: true,
              itemHeight: 48,
              menuWidth: constraints.maxWidth,
              menuMaxHeight: 280,
              dropdownColor: AppColors.surface,
              borderRadius: BorderRadius.circular(12),
              hint: const Text('Pilih golongan darah'),
              items: [
                for (final bloodType in AppConstants.bloodTypes)
                  DropdownMenuItem(
                    value: bloodType,
                    child: Text(bloodType),
                  ),
              ],
              onChanged: (value) {
                field.didChange(value);
                onChanged(value);
              },
            ),
          ),
        ),
      ),
    );
  }
}
