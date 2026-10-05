import 'package:flutter/material.dart';

class CanvasTape extends CustomPainter {
  const CanvasTape();
  @override
  void paint(Canvas canvas, Size size) {
    for (var i = 0; i < 2; i++) {
      canvas.save();
      canvas.translate(20 + i * 73, 1);
      canvas.rotate(i == 0 ? -.16 : .12);
      final rect = const Rect.fromLTWH(0, -9, 58, 18);
      canvas.drawRect(
        rect,
        Paint()
          ..color = (i == 0 ? const Color(0xFFB4C3AD) : const Color(0xFFE7BCB5))
              .withValues(alpha: .72),
      );
      canvas.drawRect(
        rect,
        Paint()
          ..color = const Color(0xFF868270).withValues(alpha: .22)
          ..style = PaintingStyle.stroke
          ..strokeWidth = .6,
      );
      for (var j = 0; j < 8; j++) {
        canvas.drawLine(
          Offset(3 + j * 7, -8),
          Offset(4 + j * 7, 8),
          Paint()
            ..color = Colors.white.withValues(alpha: .2)
            ..strokeWidth = .6,
        );
      }
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant CanvasTape oldDelegate) => false;
}
