import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tokona/core/theme/app_colors.dart';
import 'package:tokona/core/theme/app_typography.dart';

class AuthTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String? hint;
  final IconData? prefixIcon;
  final bool isPassword;
  final bool obscureText;
  final bool isRequired;
  final VoidCallback? onToggleVisibility;
  final TextInputType keyboardType;
  final TextInputAction textInputAction;
  final Widget? suffixIcon;
  final List<TextInputFormatter>? inputFormatters;
  final String? Function(String?)? validator;
  final ValueChanged<String>? onChanged;
  final bool readOnly;
  final TextCapitalization textCapitalization;

  const AuthTextField({
    super.key,
    required this.controller,
    required this.label,
    this.hint,
    this.prefixIcon,
    this.suffixIcon,
    this.isPassword = false,
    this.obscureText = false,
    this.isRequired = false,
    this.onToggleVisibility,
    this.keyboardType = TextInputType.text,
    this.textInputAction = TextInputAction.next,
    this.inputFormatters,
    this.validator,
    this.onChanged,
    this.readOnly = false,
    this.textCapitalization = TextCapitalization.none,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (isRequired)
          Text.rich(
            TextSpan(
              text: label,
              style: AppTypography.labelMedium.copyWith(
                color: const Color(0xFF334155),
                fontWeight: FontWeight.w600,
                fontSize: 12.5,
              ),
              children: const [
                TextSpan(
                  text: ' *',
                  style: TextStyle(
                    color: AppColors.error,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          )
        else
          Text(
            label,
            style: AppTypography.labelMedium.copyWith(
              color: const Color(0xFF334155),
              fontWeight: FontWeight.w600,
              fontSize: 12.5,
            ),
          ),
        const SizedBox(height: 7),
        TextFormField(
          controller: controller,
          readOnly: readOnly,
          obscureText: isPassword ? obscureText : false,
          keyboardType: keyboardType,
          textInputAction: textInputAction,
          textCapitalization: textCapitalization,
          inputFormatters: inputFormatters,
          validator: validator,
          onChanged: onChanged,
          scrollPadding: const EdgeInsets.only(bottom: 120),
          style: AppTypography.bodyLarge.copyWith(
            fontSize: 14.5,
            fontWeight: FontWeight.w500,
            color: const Color(0xFF0F172A),
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(
              fontSize: 13.5,
              color: Color(0xFF94A3B8),
              fontWeight: FontWeight.w400,
            ),
            filled: true,
            fillColor: const Color(0xFFF1F5F9).withValues(alpha: 0.75),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(
                color: const Color(0xFFE2E8F0).withValues(alpha: 0.8),
                width: 1,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: AppColors.primary, width: 1.6),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: AppColors.error, width: 1),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: AppColors.error, width: 1.5),
            ),
            prefixIcon: prefixIcon != null
                ? Icon(prefixIcon, size: 19, color: const Color(0xFF64748B))
                : null,
            suffixIcon: isPassword
                ? IconButton(
                    icon: Icon(
                      obscureText
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                      size: 19,
                      color: const Color(0xFF64748B),
                    ),
                    onPressed: onToggleVisibility,
                  )
                : suffixIcon,
          ),
        ),
      ],
    );
  }
}
