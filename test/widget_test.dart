import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:colorflow/main.dart';
import 'package:colorflow/gradient_art.dart';

void main() {
  test(
    'Palette blends continuously instead of forming separate color bands',
    () {
      final samples = const GradientArt([
        Colors.red,
        Colors.green,
        Colors.blue,
      ]).blendedColors;
      expect(samples.first, Colors.red);
      expect(samples.last, Colors.blue);
      expect(samples[128].r, closeTo(Colors.red.r * .25 + Colors.green.r * .5 + Colors.blue.r * .25, .001));
      expect(samples[128].b, closeTo(Colors.red.b * .25 + Colors.green.b * .5 + Colors.blue.b * .25, .001));
      // Derivative stays continuous across the former middle-color boundary.
      final left = samples[128].g - samples[127].g;
      final right = samples[129].g - samples[128].g;
      expect((left - right).abs(), lessThan(.001));
      expect(
        GradientArt(List.filled(400, Colors.red)).blendedColors[128].r,
        closeTo(Colors.red.r, .00001),
      );
    },
  );
  testWidgets('Rainbow starts with seven colors and allows more', (
    tester,
  ) async {
    await tester.pumpWidget(const MyApp());
    expect(find.text('#FF3B5C'), findsOneWidget);
    await tester.ensureVisible(find.text('Add a color'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Add a color'));
    await tester.pump();
    expect(find.byTooltip('Remove color 8'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
  testWidgets('Phone layout and color validation', (tester) async {
    tester.view.physicalSize = const Size(390, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(const MyApp());
    expect(tester.takeException(), isNull);
    await tester.ensureVisible(find.text('#FF3B5C'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('#FF3B5C'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), '#12');
    await tester.tap(find.text('Use color'));
    await tester.pump();
    expect(find.text('Enter six hex digits, like B7CCFF.'), findsOneWidget);
    await tester.enterText(find.byType(TextField), '#123456');
    await tester.tap(find.text('Use color'));
    await tester.pumpAndSettle();
    expect(find.text('#123456'), findsOneWidget);
  });
  test('SVG preserves all rainbow stops and vector geometry', () {
    final art = GradientArt(palettes['Rainbow']!);
    final svg = art.svg(1920, 1080);
    expect('<stop '.allMatches(svg).length, 257);
    expect(svg, contains('viewBox="0 0 1920 1080"'));
    expect(svg, isNot(contains('<image')));
    expect(
      GradientArt(palettes['Rainbow']!, radial: true).svg(100, 200),
      contains('r="140.0"'),
    );
  });
  testWidgets('PNG export renders selected colors at requested size', (
    tester,
  ) async {
    await tester.runAsync(() async {
      final bytes = await const GradientArt([
        Colors.red,
        Colors.blue,
      ], angle: 0).png(100, 50);
      final codec = await ui.instantiateImageCodec(bytes);
      final frame = await codec.getNextFrame();
      expect(frame.image.width, 100);
      expect(frame.image.height, 50);
      final data = (await frame.image.toByteData(
        format: ui.ImageByteFormat.rawRgba,
      ))!;
      expect(data.getUint8(0), greaterThan(240));
      expect(data.getUint8(99 * 4 + 2), greaterThan(240));
      frame.image.dispose();
      codec.dispose();
    });
  });
}
