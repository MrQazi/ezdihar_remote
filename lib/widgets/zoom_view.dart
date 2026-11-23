import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

/// Zoom and pan for a full-screen [child] (the masterplan map). At rest (1x)
/// the child is shown exactly as laid out, so it matches its Figma frame.
///
/// - Pinch zooms from 1x to [maxZoom] around the fingers; while zoomed in, one
///   finger pans freely, kept within the view. At 1x a one-finger drag does
///   nothing (there is nothing to pan to).
/// - Double-tap zooms to [doubleTapZoom] at that point, or back out to 1x.
///
/// The zoom transforms [child] as a whole, so anything placed on it (building
/// buttons) stays in place and tappable. [ZoomViewState.resetZoom] returns to
/// 1x (the screen calls it when opening a building).
class ZoomView extends StatefulWidget {
  const ZoomView({super.key, required this.child});

  final Widget child;

  static const maxZoom = 3.0;
  static const doubleTapZoom = 2.0;

  @override
  State<ZoomView> createState() => ZoomViewState();
}

class ZoomViewState extends State<ZoomView> {
  static const _animation = Duration(milliseconds: 300);

  /// Current zoom and the zoomed child's top-left offset.
  double _scale = 1;
  Offset _offset = Offset.zero;

  /// True while a pinch/pan follows the fingers (no easing).
  bool _zooming = false;
  double _gestureStartScale = 1;
  Offset _lastFocal = Offset.zero;

  Size _size = Size.zero;

  // Double-tap detection on raw pointers, so building taps are not delayed.
  final Map<int, (Offset, Duration)> _downs = {};
  (Offset, Duration)? _lastTap;

  bool get isZoomed => _scale > 1;

  /// Back to 1x, animated.
  void resetZoom() {
    if (!isZoomed && _offset == Offset.zero) return;
    setState(() {
      _zooming = false;
      _scale = 1;
      _offset = Offset.zero;
    });
  }

  /// Keeps the zoomed view covering the whole viewport.
  Offset _clamp(Offset o, double scale) => Offset(
        o.dx.clamp(_size.width * (1 - scale), 0),
        o.dy.clamp(_size.height * (1 - scale), 0),
      );

  /// Zooms to [scale] keeping the content under [focal] (view coords) still.
  void _zoomAround(Offset focal, double scale, {Offset pan = Offset.zero}) {
    final content = (focal - _offset) / _scale;
    _scale = scale;
    _offset = _clamp(focal + pan - content * scale, scale);
    if (_scale <= 1.001) {
      _scale = 1;
      _offset = Offset.zero;
    }
  }

  void _onScaleStart(ScaleStartDetails d) {
    // One finger at 1x: nothing to pan, leave the touch to the child.
    if (d.pointerCount < 2 && !isZoomed) return;
    _gestureStartScale = _scale;
    _lastFocal = d.localFocalPoint;
    setState(() => _zooming = true);
  }

  void _onScaleUpdate(ScaleUpdateDetails d) {
    if (!_zooming) {
      // A second finger joined a one-finger touch: start pinching now.
      if (d.pointerCount < 2) return;
      _gestureStartScale = _scale / d.scale;
      _lastFocal = d.localFocalPoint;
      _zooming = true;
    }
    final scale = (_gestureStartScale * d.scale).clamp(1.0, ZoomView.maxZoom);
    setState(() {
      _zoomAround(_lastFocal, scale, pan: d.localFocalPoint - _lastFocal);
      _lastFocal = d.localFocalPoint;
    });
  }

  void _onScaleEnd(ScaleEndDetails d) {
    if (_zooming) setState(() => _zooming = false);
  }

  void _onPointerDown(PointerDownEvent e) =>
      _downs[e.pointer] = (e.localPosition, e.timeStamp);

  void _onPointerUp(PointerUpEvent e) {
    final down = _downs.remove(e.pointer);
    if (down == null || _downs.isNotEmpty) return;
    final (position, time) = down;
    final isTap = (e.localPosition - position).distance < kTouchSlop &&
        e.timeStamp - time < kLongPressTimeout;
    if (!isTap) {
      _lastTap = null;
      return;
    }
    final last = _lastTap;
    if (last != null &&
        e.timeStamp - last.$2 < kDoubleTapTimeout &&
        (position - last.$1).distance < kDoubleTapSlop &&
        (ModalRoute.of(context)?.isCurrent ?? true)) {
      _lastTap = null;
      _onDoubleTap(position);
    } else {
      _lastTap = (position, e.timeStamp);
    }
  }

  void _onDoubleTap(Offset position) {
    if (isZoomed) {
      resetZoom();
      return;
    }
    setState(() {
      _zooming = false;
      _zoomAround(position, ZoomView.doubleTapZoom);
    });
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        _size = constraints.biggest;
        final zoom = Matrix4.translationValues(_offset.dx, _offset.dy, 0)
          ..scaleByDouble(_scale, _scale, 1, 1);
        return Listener(
          onPointerDown: _onPointerDown,
          onPointerUp: _onPointerUp,
          onPointerCancel: (e) => _downs.remove(e.pointer),
          child: GestureDetector(
            onScaleStart: _onScaleStart,
            onScaleUpdate: _onScaleUpdate,
            onScaleEnd: _onScaleEnd,
            child: ClipRect(
              child: TweenAnimationBuilder<Matrix4>(
                tween: Matrix4Tween(end: zoom),
                duration: _zooming ? Duration.zero : _animation,
                curve: Curves.easeOut,
                builder: (context, value, child) => Transform(transform: value, child: child),
                child: widget.child,
              ),
            ),
          ),
        );
      },
    );
  }
}
