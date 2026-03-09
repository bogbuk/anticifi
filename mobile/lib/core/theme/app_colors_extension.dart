import 'package:flutter/material.dart';

import 'app_colors.dart';

/// Theme extension for custom app colors that adapt to dark/light mode.
///
/// Usage: `Theme.of(context).extension<AppColorsExtension>()!`
/// Or shorthand: `context.appColors`
class AppColorsExtension extends ThemeExtension<AppColorsExtension> {
  final Color card;
  final Color textSecondary;
  final Color textMuted;
  final Color border;

  const AppColorsExtension({
    required this.card,
    required this.textSecondary,
    required this.textMuted,
    required this.border,
  });

  static const dark = AppColorsExtension(
    card: AppColors.card,
    textSecondary: AppColors.textSecondary,
    textMuted: AppColors.textMuted,
    border: AppColors.border,
  );

  static const light = AppColorsExtension(
    card: AppColorsLight.card,
    textSecondary: AppColorsLight.textSecondary,
    textMuted: AppColorsLight.textMuted,
    border: AppColorsLight.border,
  );

  @override
  AppColorsExtension copyWith({
    Color? card,
    Color? textSecondary,
    Color? textMuted,
    Color? border,
  }) {
    return AppColorsExtension(
      card: card ?? this.card,
      textSecondary: textSecondary ?? this.textSecondary,
      textMuted: textMuted ?? this.textMuted,
      border: border ?? this.border,
    );
  }

  @override
  AppColorsExtension lerp(AppColorsExtension? other, double t) {
    if (other is! AppColorsExtension) return this;
    return AppColorsExtension(
      card: Color.lerp(card, other.card, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      textMuted: Color.lerp(textMuted, other.textMuted, t)!,
      border: Color.lerp(border, other.border, t)!,
    );
  }
}

/// Shorthand for accessing AppColorsExtension from BuildContext.
extension AppColorsContext on BuildContext {
  AppColorsExtension get appColors =>
      Theme.of(this).extension<AppColorsExtension>()!;
}
