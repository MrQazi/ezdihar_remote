import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ezdihar_remote/widgets/zoom_view.dart';

void main() {
  late int taps;
  final key = GlobalKey<ZoomViewState>();

  Future<void> pumpView(WidgetTester tester) async {
    taps = 0;
    tester.view.physicalSize = const Size(1000, 600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(MaterialApp(
      home: ZoomView(
        key: key,
        child: Stack(children: [
          const Positioned.fill(child: ColoredBox(color: Colors.green)),
          Positioned(
            left: 480,
            top: 280,
            width: 40,
            height: 40,
            child: GestureDetector(
              key: const ValueKey('button'),
              onTap: () => taps++,
              child: const ColoredBox(color: Colors.red),
            ),
          ),
        ]),
      ),
    ));
  }

  Rect button(WidgetTester tester) => tester.getRect(find.byKey(const ValueKey('button')));

  Future<void> doubleTapAt(WidgetTester tester, Offset at) async {
    await tester.tapAt(at);
    await tester.pump(const Duration(milliseconds: 100));
    await tester.tapAt(at);
    await tester.pumpAndSettle();
  }

  testWidgets('at rest the child is shown exactly as laid out', (tester) async {
    await pumpView(tester);
    expect(button(tester), const Rect.fromLTWH(480, 280, 40, 40));
  });

  testWidgets('double-tap toggles 2x zoom', (tester) async {
    await pumpView(tester);
    await doubleTapAt(tester, const Offset(200, 150));
    expect(key.currentState!.isZoomed, isTrue);
    await doubleTapAt(tester, const Offset(200, 150));
    expect(key.currentState!.isZoomed, isFalse);
    expect(button(tester), const Rect.fromLTWH(480, 280, 40, 40));
  });

  testWidgets('pinch zooms, the button stays tappable and one finger pans', (tester) async {
    await pumpView(tester);
    final a = await tester.startGesture(const Offset(450, 300));
    final b = await tester.startGesture(const Offset(550, 300), pointer: 2);
    await tester.pump();
    for (var i = 1; i <= 10; i++) {
      await a.moveTo(Offset(450 - i * 10.0, 300));
      await b.moveTo(Offset(550 + i * 10.0, 300));
      await tester.pump();
    }
    await a.up();
    await b.up();
    await tester.pumpAndSettle();
    expect(key.currentState!.isZoomed, isTrue);

    await tester.tap(find.byKey(const ValueKey('button')));
    expect(taps, 1);

    final before = button(tester);
    await tester.dragFrom(const Offset(300, 300), const Offset(100, 0));
    await tester.pumpAndSettle();
    expect(button(tester).left, greaterThan(before.left));

    key.currentState!.resetZoom();
    await tester.pumpAndSettle();
    expect(key.currentState!.isZoomed, isFalse);
  });

  testWidgets('a one-finger drag at 1x moves nothing', (tester) async {
    await pumpView(tester);
    await tester.dragFrom(const Offset(500, 300), const Offset(-200, 0));
    await tester.pumpAndSettle();
    expect(key.currentState!.isZoomed, isFalse);
    expect(button(tester), const Rect.fromLTWH(480, 280, 40, 40));
  });
}
