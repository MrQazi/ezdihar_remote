import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../l10n/app_strings.dart';
import '../services/player_connection.dart';
import '../services/ui_feedback.dart';
import '../theme/app_colors.dart';
import '../theme/app_text.dart';
import '../widgets/glass_icon_button.dart';
import '../widgets/modal_backdrop.dart';

/// One picture of an [ImageModal].
class ModalImage {
  const ModalImage({required this.asset, required this.mirror, this.title});

  final String asset;

  /// The main screen's modal while this picture is shown
  /// (`PlayerConnection.showModal`).
  final Map<String, Object?> mirror;

  /// Caption under the frame (e.g. the amenity's name).
  final String Function(AppStrings)? title;
}

/// Full-screen modal showing project pictures (masterplan gallery renders and
/// amenity photos), laid out like the brochure: the picture centred in a
/// padded, bordered frame over the blurred screen, Close top-end. With more
/// than one picture, swipe, the arrow buttons or the arrow keys change it.
class ImageModal extends StatefulWidget {
  const ImageModal({super.key, required this.images, this.initialIndex = 0});

  final List<ModalImage> images;
  final int initialIndex;

  static Future<void> open(
    BuildContext context, {
    required List<ModalImage> images,
    int initialIndex = 0,
  }) {
    return Navigator.of(context).push<void>(
      PageRouteBuilder<void>(
        opaque: false,
        pageBuilder: (_, _, _) => ImageModal(images: images, initialIndex: initialIndex),
        transitionsBuilder: (_, animation, _, child) =>
            FadeTransition(opacity: animation, child: child),
      ),
    );
  }

  @override
  State<ImageModal> createState() => _ImageModalState();
}

class _ImageModalState extends State<ImageModal> {
  static const _pageDuration = Duration(milliseconds: 300);
  static const _framePadding = 16.0;
  static const _frameBorder = 2.0;

  /// The renders and photos are all 16:9.
  static const _aspect = 16 / 9;

  late final PageController _pages = PageController(initialPage: widget.initialIndex);
  late int _index = widget.initialIndex;
  final _focus = FocusNode();

  bool get _multiple => widget.images.length > 1;

  @override
  void initState() {
    super.initState();
    _mirror();
  }

  /// The main screen shows the same picture while this modal is open.
  void _mirror() => PlayerConnection.instance.showModal(widget.images[_index].mirror);

  @override
  void dispose() {
    PlayerConnection.instance.hideModal();
    _pages.dispose();
    _focus.dispose();
    super.dispose();
  }

  void _go(int delta) {
    final target = _index + delta;
    if (target < 0 || target >= widget.images.length) return;
    _pages.animateToPage(target, duration: _pageDuration, curve: Curves.easeOut);
  }

  KeyEventResult _onKey(FocusNode _, KeyEvent event) {
    if (event is! KeyDownEvent) return KeyEventResult.ignored;
    final rtl = Directionality.of(context) == TextDirection.rtl;
    if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
      UiFeedback.step();
      _go(rtl ? -1 : 1);
    } else if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
      UiFeedback.step();
      _go(rtl ? 1 : -1);
    } else if (event.logicalKey == LogicalKeyboardKey.escape) {
      UiFeedback.dismiss();
      Navigator.of(context).pop();
    } else {
      return KeyEventResult.ignored;
    }
    return KeyEventResult.handled;
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);
    final title = widget.images[_index].title?.call(strings);
    return Focus(
      focusNode: _focus,
      autofocus: true,
      onKeyEvent: _onKey,
      child: Material(
        type: MaterialType.transparency,
        child: ModalBackdrop(
          child: SafeArea(
            child: Stack(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(112, 32, 112, 72),
                  child: Row(
                    children: [
                      _arrow(strings.previousImage, Icons.arrow_back_ios_new, -1),
                      Expanded(child: Center(child: _frame())),
                      _arrow(strings.nextImage, Icons.arrow_forward_ios, 1),
                    ],
                  ),
                ),
                PositionedDirectional(
                  top: 24,
                  end: 24,
                  child: GlassIconButton(
                    tooltip: strings.close,
                    onPressed: () => Navigator.of(context).pop(),
                    padding: const EdgeInsetsDirectional.only(start: 16, end: 24),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.close, color: Colors.white, size: 28),
                        const SizedBox(width: 8),
                        Text(strings.close, style: appText(strings, 18, FontWeight.w500)),
                      ],
                    ),
                  ),
                ),
                PositionedDirectional(
                  bottom: 24,
                  start: 0,
                  end: 0,
                  child: Center(
                    child: Text(
                      [?title, if (_multiple) '${_index + 1} / ${widget.images.length}'].join('  ·  '),
                      style: appText(strings, 16, FontWeight.w500, color: AppColors.textSecondary),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// The picture in a white-bordered frame, sized to the 16:9 picture.
  Widget _frame() {
    return LayoutBuilder(
      builder: (context, box) {
        const inset = _framePadding + _frameBorder;
        final availW = box.maxWidth - inset * 2;
        final availH = box.maxHeight - inset * 2;
        final h = availW / availH > _aspect ? availH : availW / _aspect;
        return DecoratedBox(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.white, width: _frameBorder),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(_framePadding),
            child: SizedBox(
              width: h * _aspect,
              height: h,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: PageView.builder(
                  controller: _pages,
                  itemCount: widget.images.length,
                  onPageChanged: (i) {
                    setState(() => _index = i);
                    _mirror();
                  },
                  itemBuilder: (_, i) => Image.asset(
                    widget.images[i].asset,
                    fit: BoxFit.cover,
                    // Full resolution: the frame is most of the screen.
                    filterQuality: FilterQuality.medium,
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  /// Round arrow button, faded and disabled at the first/last picture; an
  /// empty slot of the same width when there is only one picture.
  Widget _arrow(String tooltip, IconData icon, int delta) {
    final target = _index + delta;
    final on = target >= 0 && target < widget.images.length;
    return SizedBox(
      width: 80,
      child: !_multiple
          ? null
          : Center(
              child: Opacity(
                opacity: on ? 1 : 0.3,
                child: GlassIconButton(
                  tooltip: tooltip,
                  onPressed: on ? () => _go(delta) : null,
                  size: 56,
                  child: Icon(icon, color: Colors.white, size: 24),
                ),
              ),
            ),
    );
  }
}
