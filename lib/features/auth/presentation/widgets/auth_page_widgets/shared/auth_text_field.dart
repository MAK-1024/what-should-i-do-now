import 'package:flutter/material.dart';
import 'package:wsidappp/config/theme/theme_extensions.dart';
import 'package:wsidappp/features/auth/presentation/widgets/auth_page_widgets/shared/auth_field_label.dart';

/// Bordered auth input with leading icon (Figma `input field` component).
class AuthTextField extends StatelessWidget {
  const AuthTextField({
    super.key,
    required this.controller,
    required this.label,
    required this.hintText,
    required this.prefixIcon,
    this.keyboardType,
    this.textInputAction,
    this.obscureText = false,
    this.onToggleObscure,
    this.onFieldSubmitted,
    this.validator,
  });

  final TextEditingController controller;
  final String label;
  final String hintText;
  final IconData prefixIcon;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final bool obscureText;
  final VoidCallback? onToggleObscure;
  final void Function(String)? onFieldSubmitted;
  final String? Function(String?)? validator;

  @override
  Widget build(BuildContext context) {
    final brand = context.brand;
    final TextStyle hintStyle =
        context.typo.body.copyWith(color: brand.hintText);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        AuthFieldLabel(label: label),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          textInputAction: textInputAction,
          obscureText: obscureText,
          onFieldSubmitted: onFieldSubmitted,
          validator: validator,
          style: context.typo.body.copyWith(color: brand.fieldValue),
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: hintStyle,
            filled: true,
            fillColor: brand.inputFill,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
            prefixIcon: Icon(prefixIcon, color: brand.iconMuted, size: 24),
            suffixIcon: onToggleObscure == null
                ? null
                : IconButton(
                    icon: Icon(
                      obscureText
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                      color: brand.iconMuted,
                      size: 24,
                    ),
                    onPressed: onToggleObscure,
                  ),
            border: OutlineInputBorder(
              borderRadius: context.radius.md,
              borderSide: BorderSide(color: brand.inputBorder),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: context.radius.md,
              borderSide: BorderSide(color: brand.inputBorder),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: context.radius.md,
              borderSide: BorderSide(
                color: brand.inputBorderFocused,
                width: 1.5,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: context.radius.md,
              borderSide: BorderSide(color: context.colors.error),
            ),
          ),
        ),
      ],
    );
  }
}