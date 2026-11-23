import 'package:flutter/material.dart';

class MedicalPatternPainter extends CustomPainter {
  const MedicalPatternPainter({
    Key? key,
    this.isSecondary = false,
  });

  final bool isSecondary;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = isSecondary
        ? const Color(0xFFFFFFFF).withOpacity(0.07)
        : const Color(0xFF308B60).withOpacity(0.1)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    final double spacing = 90;

    for (double x = 20; x < size.width; x += spacing) {
      for (double y = 20; y < size.height; y += spacing) {
        final int index = ((x / spacing).round() + (y / spacing).round()) % 3;

        if (index == 0) {
          canvas.drawLine(Offset(x - 8, y), Offset(x + 8, y), paint);
          canvas.drawLine(Offset(x, y - 8), Offset(x, y + 8), paint);
        } else if (index == 1) {
          canvas.save();
          canvas.translate(x, y);
          canvas.rotate(-0.6);

          final rect = Rect.fromCenter(
            center: Offset.zero,
            width: 25,
            height: 12,
          );

          canvas.drawRRect(
            RRect.fromRectAndRadius(rect, const Radius.circular(10)),
            paint,
          );

          canvas.drawLine(const Offset(0, -6), const Offset(0, 6), paint);

          canvas.restore();
        } else {
          canvas.drawCircle(Offset(x, y), 7, paint);
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
