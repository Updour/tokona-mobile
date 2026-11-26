import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tokona/core/theme/app_colors.dart';
import 'package:tokona/core/theme/app_typography.dart';

class AuthTextField extends StatefulWidget {
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
  State<AuthTextField> createState() => _AuthTextFieldState();
}

class _AuthTextFieldState extends State<AuthTextField> {
  bool _isFocused = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.isRequired)
          Text.rich(
            TextSpan(
              text: widget.label,
              style: AppTypography.labelMedium.copyWith(
                color: _isFocused ? AppColors.primaryDark : const Color(0xFF334155),
                fontWeight: FontWeight.w700,
                fontSize: 12.5,
              ),
              children: const [
                TextSpan(
                  text: ' *',
                  style: TextStyle(color: AppColors.error, fontWeight: FontWeight.w700),
                ),
              ],
            ),
          )
        else
          Text(
            widget.label,
            style: AppTypography.labelMedium.copyWith(
              color: _isFocused ? AppColors.primaryDark : const Color(0xFF334155),
              fontWeight: FontWeight.w700,
              fontSize: 12.5,
            ),
          ),
        const SizedBox(height: 8),
        Focus(
          onFocusChange: (focused) => setState(() => _isFocused = focused),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOutCubic,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: _isFocused
                      ? AppColors.primary.withValues(alpha: 0.16)
                      : const Color(0xFF0F172A).withValues(alpha: 0.045),
                  blurRadius: _isFocused ? 16 : 12,
                  offset: Offset(0, _isFocused ? 5 : 4),
                ),
              ],
            ),
            child: TextFormField(
              controller: widget.controller,
              readOnly: widget.readOnly,
              obscureText: widget.isPassword ? widget.obscureText : false,
              keyboardType: widget.keyboardType,
              textInputAction: widget.textInputAction,
              textCapitalization: widget.textCapitalization,
              inputFormatters: widget.inputFormatters,
              validator: widget.validator,
              onChanged: widget.onChanged,
              scrollPadding: const EdgeInsets.only(bottom: 120),
              style: AppTypography.bodyLarge.copyWith(
                fontSize: 14.5,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF0F172A),
              ),
              decoration: InputDecoration(
                hintText: widget.hint,
                hintStyle: const TextStyle(
                  fontSize: 13.5,
                  color: Color(0xFF94A3B8),
                  fontWeight: FontWeight.w400,
                ),
                filled: true,
                fillColor: _isFocused ? Colors.white : const Color(0xFFFAFCFF),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(color: const Color(0xFFE2E8F0).withValues(alpha: 0.9), width: 1),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(color: AppColors.primary, width: 1.6),
                ),
                errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(color: AppColors.error, width: 1.2),
                ),
                focusedErrorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(color: AppColors.error, width: 1.6),
                ),
                prefixIcon: widget.prefixIcon != null
                    ? Icon(
                        widget.prefixIcon,
                        size: 20,
                        color: _isFocused ? AppColors.primary : const Color(0xFF64748B),
                      )
                    : null,
                suffixIcon: widget.isPassword
                    ? IconButton(
                        icon: Icon(
                          widget.obscureText ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                          size: 20,
                          color: _isFocused ? AppColors.primary : const Color(0xFF64748B),
                        ),
                        onPressed: widget.onToggleVisibility,
                      )
                    : widget.suffixIcon,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
