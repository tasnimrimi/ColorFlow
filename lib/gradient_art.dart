import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

String hex(Color color) =>
    '#${(color.toARGB32() & 0xffffff).toRadixString(16).padLeft(6, '0').toUpperCase()}';

class GradientArt {
  const GradientArt(this.colors, {this.angle = 45, this.radial = false});
  final List<Color> colors;
  final double angle;
  final bool radial;
  // A continuous Bezier color curve replaces the separate straight ramps.
  // Logarithmic Bernstein weights also support long user-created palettes.
  List<Color> get blendedColors {
    final degree = colors.length - 1;
    final coefficients = List<double>.filled(colors.length, 0);
    for (var i = 1; i <= degree; i++) {
      coefficients[i] =
          coefficients[i - 1] + math.log(degree - i + 1) - math.log(i);
    }
    return List.generate(257, (sample) {
      if (sample == 0) return colors.first;
      if (sample == 256) return colors.last;
      final t = sample / 256;
      final weights = List.generate(
        colors.length,
        (i) =>
            coefficients[i] + i * math.log(t) + (degree - i) * math.log(1 - t),
      );
      final peak = weights.reduce(math.max);
      double total = 0, red = 0, green = 0, blue = 0;
      for (var i = 0; i < colors.length; i++) {
        final weight = math.exp(weights[i] - peak);
        total += weight;
        red += colors[i].r * weight;
        green += colors[i].g * weight;
        blue += colors[i].b * weight;
      }
      return Color.from(
        alpha: 1,
        red: red / total,
        green: green / total,
        blue: blue / total,
      );
    });
  }

  List<double> get stops => List.generate(257, (i) => i / 256);
  (Offset, Offset) endpoints(Size size) {
    final radians = angle * math.pi / 180;
    final direction = Offset(math.cos(radians), math.sin(radians));
    final length =
        (size.width * direction.dx.abs() + size.height * direction.dy.abs()) /
        2;
    final center = size.center(Offset.zero);
    return (center - direction * length, center + direction * length);
  }

  void paint(Canvas canvas, Size size) {
    final blended = blendedColors;
    final (start, end) = endpoints(size);
    final shader = radial
        ? ui.Gradient.radial(
            size.center(Offset.zero),
            size.longestSide * .7,
            blended,
            stops,
          )
        : ui.Gradient.linear(start, end, blended, stops);
    canvas.drawRect(Offset.zero & size, Paint()..shader = shader);
  }

  String svg(int width, int height) {
    final blended = blendedColors;
    final size = Size(width.toDouble(), height.toDouble());
    final (start, end) = endpoints(size);
    final tags = List.generate(
      blended.length,
      (i) => '<stop offset="${i / 256}" stop-color="${hex(blended[i])}"/>',
    ).join();
    final gradient = radial
        ? '<radialGradient id="g" gradientUnits="userSpaceOnUse" cx="${width / 2}" cy="${height / 2}" r="${size.longestSide * .7}">$tags</radialGradient>'
        : '<linearGradient id="g" gradientUnits="userSpaceOnUse" x1="${start.dx}" y1="${start.dy}" x2="${end.dx}" y2="${end.dy}">$tags</linearGradient>';
    return '<svg xmlns="http://www.w3.org/2000/svg" width="$width" height="$height" viewBox="0 0 $width $height"><defs>$gradient</defs><rect width="$width" height="$height" fill="url(#g)"/></svg>';
  }

  Future<Uint8List> png(int width, int height) async {
    final recorder = ui.PictureRecorder();
    paint(Canvas(recorder), Size(width.toDouble(), height.toDouble()));
    final picture = recorder.endRecording();
    try {
      final image = await picture.toImage(width, height);
      try {
        final data = await image.toByteData(format: ui.ImageByteFormat.png);
        if (data == null) throw StateError('Unable to encode PNG');
        return data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
      } finally {
        image.dispose();
      }
    } finally {
      picture.dispose();
    }
  }
}

class ArtPainter extends CustomPainter {
  const ArtPainter(this.art);
  final GradientArt art;
  @override
  void paint(Canvas canvas, Size size) => art.paint(canvas, size);
  @override
  bool shouldRepaint(covariant ArtPainter old) =>
      old.art.angle != art.angle ||
      old.art.radial != art.radial ||
      !listEquals(old.art.colors, art.colors);
}
