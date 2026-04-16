import 'package:flutter/material.dart';

import '../../core/constants/app_tokens.dart';

class AppTextField extends StatefulWidget {
  const AppTextField({
    required this.label,
    super.key,
    this.controller,
    this.placeholder,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.prefixIcon,
    this.helperText,
  });

  final String label;
  final TextEditingController? controller;
  final String? placeholder;
  final bool obscureText;
  final TextInputType keyboardType;
  final IconData? prefixIcon;
  final String? helperText;

  @override
  State<AppTextField> createState() => _AppTextFieldState();
}

class _AppTextFieldState extends State<AppTextField> {
  bool _showPassword = false;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: TextFormField(
        controller: widget.controller,
        keyboardType: widget.keyboardType,
        obscureText: widget.obscureText && !_showPassword,
        decoration: InputDecoration(
          labelText: widget.label,
          hintText: widget.placeholder,
          helperText: widget.helperText,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppRadius.md)),
          prefixIcon: widget.prefixIcon != null
              ? Icon(
                  widget.prefixIcon,
                  color: AppColors.violet.withOpacity(0.6),
                  size: 20,
                )
              : null,
          suffixIcon: widget.obscureText
              ? IconButton(
                  onPressed: () => setState(() => _showPassword = !_showPassword),
                  icon: Icon(_showPassword ? Icons.visibility_off : Icons.visibility),
                )
              : null,
        ),
      ),
    );
  }
}
