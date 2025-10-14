import 'package:flutter/material.dart';

class AppColors extends ThemeExtension<AppColors> {
  const AppColors({
    required this.success,
    required this.warning,
    required this.danger,
  });

  final Color success;
  final Color warning;
  final Color danger;

  static const AppColors light = AppColors(
    success: Color(0xFF22C55E),
    warning: Color(0xFFF59E0B),
    danger: Color(0xFFEF4444),
  );

  static const AppColors dark = AppColors(
    success: Color(0xFF4ADE80),
    warning: Color(0xFFFBBF24),
    danger: Color(0xFFF87171),
  );

  @override
  AppColors copyWith({Color? success, Color? warning, Color? danger}) {
    return AppColors(
      success: success ?? this.success,
      warning: warning ?? this.warning,
      danger: danger ?? this.danger,
    );
  }

  @override
  AppColors lerp(ThemeExtension<AppColors>? other, double t) {
    if (other is! AppColors) {
      return this;
    }
    return AppColors(
      success: Color.lerp(success, other.success, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      danger: Color.lerp(danger, other.danger, t)!,
    );
  }
}

class AppTextStyles extends ThemeExtension<AppTextStyles> {
  const AppTextStyles({
    required this.sectionTitle,
    required this.supporting,
    required this.badge,
  });

  final TextStyle sectionTitle;
  final TextStyle supporting;
  final TextStyle badge;

  static const AppTextStyles light = AppTextStyles(
    sectionTitle: TextStyle(fontWeight: FontWeight.w600, letterSpacing: 0.2),
    supporting: TextStyle(fontWeight: FontWeight.w400, letterSpacing: 0.1),
    badge: TextStyle(
      fontWeight: FontWeight.w600,
      letterSpacing: 0.4,
      textBaseline: TextBaseline.alphabetic,
    ),
  );

  static const AppTextStyles dark = AppTextStyles(
    sectionTitle: TextStyle(fontWeight: FontWeight.w600, letterSpacing: 0.2),
    supporting: TextStyle(fontWeight: FontWeight.w400, letterSpacing: 0.1),
    badge: TextStyle(
      fontWeight: FontWeight.w600,
      letterSpacing: 0.4,
      textBaseline: TextBaseline.alphabetic,
    ),
  );

  @override
  AppTextStyles copyWith({
    TextStyle? sectionTitle,
    TextStyle? supporting,
    TextStyle? badge,
  }) {
    return AppTextStyles(
      sectionTitle: sectionTitle ?? this.sectionTitle,
      supporting: supporting ?? this.supporting,
      badge: badge ?? this.badge,
    );
  }

  @override
  AppTextStyles lerp(ThemeExtension<AppTextStyles>? other, double t) {
    if (other is! AppTextStyles) {
      return this;
    }
    return AppTextStyles(
      sectionTitle: TextStyle.lerp(sectionTitle, other.sectionTitle, t)!,
      supporting: TextStyle.lerp(supporting, other.supporting, t)!,
      badge: TextStyle.lerp(badge, other.badge, t)!,
    );
  }
}

extension AppThemeExtensions on BuildContext {
  AppColors get appColors =>
      Theme.of(this).extension<AppColors>() ?? AppColors.light;

  AppTextStyles get appTextStyles =>
      Theme.of(this).extension<AppTextStyles>() ?? AppTextStyles.light;
}
