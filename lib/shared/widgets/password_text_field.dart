import 'package:flutter/material.dart';

import 'package:volunteer/shared/widgets/custom_text_field.dart';

class PasswordTextField extends StatefulWidget {
  const PasswordTextField({
    super.key,
    required this.label,
    required this.hint,
    required this.controller,
    this.validator,
  });

  final String label;
  final String hint;
  final TextEditingController controller;
  final String? Function(String?)? validator;

  @override
  State<PasswordTextField> createState() => _PasswordTextFieldState();
}

class _PasswordTextFieldState extends State<PasswordTextField> {
  bool _obscurePassword = true;

  @override
  Widget build(BuildContext context) {
    return CustomTextField(
      label: widget.label,
      hint: widget.hint,
      controller: widget.controller,
      obscureText: _obscurePassword,
      keyboardType: TextInputType.visiblePassword,
      validator: widget.validator,
      suffixIcon: IconButton(
        tooltip: _obscurePassword
            ? 'Tampilkan kata sandi'
            : 'Sembunyikan kata sandi',
        onPressed: () => setState(() {
          _obscurePassword = !_obscurePassword;
        }),
        icon: Icon(
          _obscurePassword
              ? Icons.visibility_outlined
              : Icons.visibility_off_outlined,
        ),
      ),
    );
  }
}
