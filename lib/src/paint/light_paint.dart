import 'dart:math';
import 'package:flutter/material.dart';
import 'package:tutorial_coach_mark/src/clipper/circle_clipper.dart';

class LightPaint extends CustomPainter {
  final double progress;
  final Offset positioned;
  final double sizeCircle;
  final Color colorShadow;
  final double opacityShadow;
  final BorderSide? borderSide;
  final Color shadowBorderColor;  // New parameter for shadow color
  final double shadowOpacity;  // New parameter for shadow opacity
  final double shadowSpreadRadius;  // New parameter for shadow spread radius

  LightPaint(
      this.progress,
      this.positioned,
      this.sizeCircle, {
        this.colorShadow = Colors.black,
        this.opacityShadow = 0.8,
        this.borderSide,
        this.shadowBorderColor = const Color(0xffCFF406),  // Default shadow color
        this.shadowOpacity = 0.5,  // Default shadow opacity
        this.shadowSpreadRadius = 4,  // Default shadow spread radius
      }) : assert(opacityShadow >= 0 && opacityShadow <= 1);

  @override
  void paint(Canvas canvas, Size size) {
    if (positioned == Offset.zero) return;

    var maxSize = max(size.width, size.height);
    double radius = maxSize * (1 - progress) + sizeCircle;
    final circleHole = CircleClipper.circleHolePath(size, positioned, radius);

    // Paint the shadow-filled circle
    canvas.drawPath(
      circleHole,
      Paint()
        ..style = PaintingStyle.fill
        ..color = colorShadow.withOpacity(opacityShadow),
    );

    // Paint the circle with border and optional shadow
    if (borderSide != null && borderSide?.style != BorderStyle.none) {
      Paint borderPaint = Paint()
        ..style = PaintingStyle.stroke
        ..color = borderSide!.color.withOpacity(opacityShadow)
        ..strokeWidth = borderSide!.width;

      // Adding shadow to the border if enabled
      if (shadowSpreadRadius > 0) {
        borderPaint..maskFilter = MaskFilter.blur(BlurStyle.normal, shadowSpreadRadius);
      }

      canvas.drawPath(
        circleHole,
        borderPaint,
      );
    }
  }

  @override
  bool shouldRepaint(LightPaint oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.shadowBorderColor != shadowBorderColor ||
        oldDelegate.shadowOpacity != shadowOpacity ||
        oldDelegate.shadowSpreadRadius != shadowSpreadRadius;
  }
}
