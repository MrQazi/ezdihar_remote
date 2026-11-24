import 'dart:ui';

import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// The frosted backdrop behind every modal: the screen underneath is blurred
/// and darkened with [AppColors.scrim], then [child] is drawn on top. The
/// backdrop itself takes no taps, so a dialog barrier under it still works.
class ModalBackdrop extends StatelessWidget {
  const ModalBackdrop({super.key, required this.child});

  /// Blur of the screen behind the modal.
  static const sigma = 16.0;

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        IgnorePointer(
          child: ClipRect(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: sigma, sigmaY: sigma),
              child: const ColoredBox(color: AppColors.scrim),
            ),
          ),
        ),
        child,
      ],
    );
  }
}
