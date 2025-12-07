import 'package:flutter/material.dart';

class CornerPageCurlPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();

    // ألوان الورقة
    final gradient = LinearGradient(
      begin: Alignment.topRight,
      end: Alignment.bottomLeft,
      colors: [
        Colors.white,
        Colors.grey.shade100,
        Colors.grey.shade300,
      ],
    );

    final paperPaint = Paint()
      ..shader = gradient.createShader(
        Rect.fromLTWH(0, 0, size.width, size.height),
      );

    // 🔥 مسار الورقة المتنية من الزاوية اليمنى العليا فعلياً
    final path = Path()
      ..moveTo(size.width, 0) // نقطة الزاوية اليمين فوق
      ..lineTo(size.width, size.height * 0.6)
      ..quadraticBezierTo(
        size.width * 0.8,
        size.height * 0.75,
        size.width * 0.55,
        size.height * 0.9,
      )
      ..lineTo(size.width * 0.2, size.height)
      ..lineTo(size.width * 0.75, 0)
      ..close();

    // 🔥 ظل واقعي تحت الانثناء
    final shadowPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topRight,
        end: Alignment.bottomLeft,
        colors: [
          Colors.black.withOpacity(0.20),
          Colors.black.withOpacity(0.05),
          Colors.transparent,
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    final shadowPath = Path()
      ..moveTo(size.width, size.height * 0.4)
      ..quadraticBezierTo(
        size.width * 0.8,
        size.height * 0.7,
        size.width * 0.3,
        size.height,
      )
      ..lineTo(size.width * 0.6, size.height)
      ..quadraticBezierTo(
        size.width * 0.9,
        size.height * 0.7,
        size.width,
        size.height * 0.45,
      )
      ..close();

    // 🔥 رسم العناصر
    canvas.drawPath(shadowPath, shadowPaint);
    canvas.drawPath(path, paperPaint);

    // خط الحافة
    final edgePaint = Paint()
      ..color = Colors.grey.shade500
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    canvas.drawPath(path, edgePaint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
