/// Design System Text Field Component
import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../tokens/tokens.dart';

class DSTextField extends StatelessWidget {
  final String? label;
  final String? hint;
  final String? helperText;
  final String? errorText;
  final TextEditingController? controller;
  final String? initialValue;
  final bool obscureText;
  final bool readOnly;
  final bool enabled;
  final int? maxLines;
  final int? minLines;
  final int? maxLength;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final TextCapitalization textCapitalization;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final VoidCallback? onTap;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final FormFieldValidator<String>? validator;
  final List<TextInputFormatter>? inputFormatters;
  final AutovalidateMode autovalidateMode;

  const DSTextField({
    super.key,
    this.label,
    this.hint,
    this.helperText,
    this.errorText,
    this.controller,
    this.initialValue,
    this.obscureText = false,
    this.readOnly = false,
    this.enabled = true,
    this.maxLines = 1,
    this.minLines,
    this.maxLength,
    this.keyboardType,
    this.textInputAction,
    this.textCapitalization = TextCapitalization.none,
    this.prefixIcon,
    this.suffixIcon,
    this.onTap,
    this.onChanged,
    this.onSubmitted,
    this.validator,
    this.inputFormatters,
    this.autovalidateMode = AutovalidateMode.onUserInteraction,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final hasError = errorText != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (label != null) ...[
          Text(
            label!,
            style: AppTypography.labelMedium.copyWith(
              color: hasError ? AppColors.error : (isDark ? Colors.white : AppColors.textPrimary),
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
        ],
        TextFormField(
          controller: controller,
          initialValue: controller == null ? initialValue : null,
          obscureText: obscureText,
          readOnly: readOnly,
          enabled: enabled,
          maxLines: maxLines,
          minLines: minLines,
          maxLength: maxLength,
          keyboardType: keyboardType,
          textInputAction: textInputAction,
          textCapitalization: textCapitalization,
          onTap: onTap,
          onChanged: onChanged,
          onFieldSubmitted: onSubmitted,
          validator: validator,
          inputFormatters: inputFormatters,
          autovalidateMode: autovalidateMode,
          style: AppTypography.bodyLarge.copyWith(
            color: isDark ? Colors.white : AppColors.textPrimary,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: AppTypography.bodyMedium.copyWith(
              color: isDark ? Colors.white.withOpacity(0.5) : AppColors.textMuted,
            ),
            helperText: helperText,
            helperStyle: AppTypography.bodySmall.copyWith(
              color: isDark ? Colors.white.withOpacity(0.6) : AppColors.textSecondary,
            ),
            errorText: errorText,
            errorStyle: AppTypography.bodySmall.copyWith(color: AppColors.error),
            errorMaxLines: 3,
            counterText: '',
            filled: true,
            fillColor: isDark ? AppColors.surfaceDark : AppColors.surface,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
              vertical: AppSpacing.md,
            ),
            prefixIcon: prefixIcon != null
                ? Padding(
                    padding: const EdgeInsets.only(left: AppSpacing.lg, right: AppSpacing.md),
                    child: prefixIcon,
                  )
                : null,
            suffixIcon: suffixIcon != null
                ? Padding(
                    padding: const EdgeInsets.only(right: AppSpacing.lg),
                    child: suffixIcon,
                  )
                : null,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppBorderRadius.input),
              borderSide: BorderSide(
                color: hasError
                    ? AppColors.error
                    : (isDark ? AppColors.surfaceVariantDark : AppColors.surfaceVariant),
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppBorderRadius.input),
              borderSide: BorderSide(
                color: hasError
                    ? AppColors.error
                    : (isDark ? AppColors.surfaceVariantDark : AppColors.surfaceVariant),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppBorderRadius.input),
              borderSide: BorderSide(
                color: hasError ? AppColors.error : AppColors.primary,
                width: 2,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppBorderRadius.input),
              borderSide: const BorderSide(color: AppColors.error),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppBorderRadius.input),
              borderSide: const BorderSide(color: AppColors.error, width: 2),
            ),
            disabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppBorderRadius.input),
              borderSide: BorderSide(
                color: isDark
                    ? AppColors.surfaceVariantDark.withOpacity(0.5)
                    : AppColors.surfaceVariant.withOpacity(0.5),
              ),
            ),
          ),
        ),
      ],
    );
  }
}