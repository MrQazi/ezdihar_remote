import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../l10n/app_strings.dart';
import '../services/lead_store.dart';
import '../services/storage_access.dart';
import '../theme/app_colors.dart';
import '../theme/app_text.dart';
import '../widgets/overlay_background.dart';
import '../widgets/pill_button.dart';

/// Shown instead of the app until storage access is granted (`StorageAccess`):
/// says where the leads are saved and asks for access. Refusing closes the app.
///
/// It replaces the navigator (`MyApp`'s builder), so it uses no Scaffold,
/// Navigator or Overlay.
class StorageAccessScreen extends StatefulWidget {
  const StorageAccessScreen({super.key, required this.access});

  final StorageAccess access;

  @override
  State<StorageAccessScreen> createState() => _StorageAccessScreenState();
}

class _StorageAccessScreenState extends State<StorageAccessScreen> {
  bool _asking = false;

  Future<void> _allow() async {
    if (_asking) return;
    setState(() => _asking = true);
    try {
      await widget.access.request();
    } finally {
      if (mounted) setState(() => _asking = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);
    // Material: the text style a page normally gets from its Scaffold.
    return Material(
      color: AppColors.screenBackground,
      child: OverlayBackground(
        image: 'assets/images/initial_screen.png',
        overlayImage: 'assets/images/overlay_frame.png',
        overlayColor: AppColors.scrim,
        child: SafeArea(
          minimum: const EdgeInsets.all(32),
          child: Stack(
            children: [
              Align(
                alignment: AlignmentDirectional.topStart,
                child: SvgPicture.asset('assets/images/logo.svg'),
              ),
              Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 880),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        strings.storageAccessTitle,
                        textAlign: TextAlign.center,
                        style: appText(strings, 40, FontWeight.w500),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        strings.storageAccessBody,
                        textAlign: TextAlign.center,
                        style: appText(strings, 22, FontWeight.w400, color: AppColors.textSecondary)
                            .copyWith(height: 1.5),
                      ),
                      const SizedBox(height: 16),
                      // The folder as the tablet's Files app shows it (› mirrors in RTL).
                      Text(
                        '${strings.internalStorage} › ${LeadStore.folderName}',
                        textAlign: TextAlign.center,
                        style: appText(strings, 22, FontWeight.w500),
                      ),
                      const SizedBox(height: 48),
                      PillButton(
                        label: strings.storageAccessAllow,
                        width: 280,
                        onPressed: _asking ? null : _allow,
                      ),
                    ],
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
