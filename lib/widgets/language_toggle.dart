import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../services/ui_feedback.dart';
import '../theme/app_colors.dart';

enum AppLanguage { english, arabic }

/// Two-segment pill used to switch between English and Arabic.
class LanguageToggle extends StatelessWidget {
  const LanguageToggle({
    super.key,
    required this.selected,
    required this.onChanged,
    this.darkSelectedText = false,
  });

  final AppLanguage selected;
  final ValueChanged<AppLanguage> onChanged;

  /// Draws the selected segment's label in [AppColors.onLight] (dark on its
  /// light accent fill) instead of white. Used on the masterplan.
  final bool darkSelectedText;

  Color _labelColor(AppLanguage language) =>
      darkSelectedText && selected == language ? AppColors.onLight : Colors.white;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(56);
    return ClipRRect(
      borderRadius: radius,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5.25, sigmaY: 5.25),
        child: Container(
          // Figma 225:313: 48 high, 40 high segments.
          height: 48,
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: AppColors.glass,
            borderRadius: radius,
            border: Border.all(color: AppColors.glassBorder, width: 0.48),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _Segment(
                radius: 48,
                selected: selected == AppLanguage.english,
                onTap: () => onChanged(AppLanguage.english),
                child: Text(
                  'English',
                  style: GoogleFonts.rubik(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: _labelColor(AppLanguage.english),
                    letterSpacing: 0.24,
                    height: 1,
                  ),
                ),
              ),
              _Segment(
                radius: 48,
                selected: selected == AppLanguage.arabic,
                onTap: () => onChanged(AppLanguage.arabic),
                child: Text(
                  'العربية',
                  textDirection: TextDirection.rtl,
                  style: GoogleFonts.notoSansArabic(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: _labelColor(AppLanguage.arabic),
                    letterSpacing: 0.24,
                    height: 1,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Segment extends StatelessWidget {
  const _Segment({required this.radius, required this.selected, required this.onTap, required this.child});

  final double radius;
  final bool selected;
  final VoidCallback onTap;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final borderRadius = BorderRadius.circular(radius);
    return Material(
      color: selected ? AppColors.accent : Colors.transparent,
      borderRadius: borderRadius,
      child: InkWell(
        onTap: () {
          if (!selected) UiFeedback.select();
          onTap();
        },
        borderRadius: borderRadius,
        child: Container(height: 40, alignment: Alignment.center, padding: const EdgeInsets.symmetric(horizontal: 16), child: child),
      ),
    );
  }
}
