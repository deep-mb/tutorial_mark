import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:tutorial_coach_mark/src/clipper/rect_clipper.dart';
import 'package:tutorial_coach_mark/src/target/target_position.dart';

class LightPaintRect extends CustomPainter {
  final double progress;
  final TargetPosition target;
  final Color colorShadow;
  final double opacityShadow;
  final double offset;
  final double radius;
  final BorderSide? borderSide;
  final Color shadowBorderColor;  // New parameter for shadow color
  final double shadowOpacity;  // New parameter for shadow opacity
  final double shadowSpreadRadius;  // New parameter for shadow spread radius

  LightPaintRect({
    required this.progress,
    required this.target,
    this.colorShadow = Colors.black,
    this.opacityShadow = 0.8,
    this.offset = 10,
    this.radius = 10,
    this.borderSide,
    this.shadowBorderColor = const Color(0xffCFF406),  // Default shadow color
    this.shadowOpacity = 0.5,  // Default shadow opacity
    this.shadowSpreadRadius = 4,  // Default shadow spread radius
  }) : assert(opacityShadow >= 0 && opacityShadow <= 1);

  static Path _drawJustHole(
      Size canvasSize,
      double x,
      double y,
      double w,
      double h,
      ) {
    return Path()
      ..moveTo(x + w, y)
      ..lineTo(x + w, y + h)
      ..lineTo(x, y + h)
      ..lineTo(x, y)
      ..close();
  }

  static Path _drawJustRHole(
      Size canvasSize,
      double x,
      double y,
      double w,
      double h,
      double radius,
      ) {
    double diameter = radius * 2;

    return Path()
      ..moveTo(x, y + radius)
      ..arcTo(
        Rect.fromLTWH(x, y, diameter, diameter),
        pi,
        pi / 2,
        false,
      )
      ..arcTo(
        Rect.fromLTWH(x + w - diameter, y, diameter, diameter),
        3 * pi / 2,
        pi / 2,
        false,
      )
      ..arcTo(
        Rect.fromLTWH(x + w - diameter, y + h - diameter, diameter, diameter),
        0,
        pi / 2,
        false,
      )
      ..arcTo(
        Rect.fromLTWH(x, y + h - diameter, diameter, diameter),
        pi / 2,
        pi / 2,
        false,
      )
      ..lineTo(x, y + radius)
      ..close();
  }

  @override
  void paint(Canvas canvas, Size size) {
    if (target.offset == Offset.zero) return;

    var maxSize = max(size.width, size.height) +
        max(target.size.width, target.size.height) +
        target.getBiggerSpaceBorder(size);

    double x = -maxSize / 2 * (1 - progress) + target.offset.dx - offset / 2;
    double y = -maxSize / 2 * (1 - progress) + target.offset.dy - offset / 2;
    double w = maxSize * (1 - progress) + target.size.width + offset;
    double h = maxSize * (1 - progress) + target.size.height + offset;

    Path path = radius > 0
        ? RectClipper.rRectHolePath(size, x, y, w, h, radius)
        : RectClipper.rectHolePath(size, x, y, w, h);

    canvas.drawPath(
      path,
      Paint()
        ..style = PaintingStyle.fill
        ..color = colorShadow.withOpacity(opacityShadow),
    );

    // Drawing the shadow effect on the border
    if (borderSide != null && borderSide!.style != BorderStyle.none) {
      Paint shadowPaint = Paint()
        ..style = PaintingStyle.stroke
        ..color = shadowBorderColor.withOpacity(shadowOpacity)
        ..strokeWidth = borderSide!.width + shadowSpreadRadius
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, shadowSpreadRadius);

      canvas.drawPath(
        radius > 0
            ? _drawJustRHole(size, x, y, w, h, radius)
            : _drawJustHole(size, x, y, w, h),
        shadowPaint,
      );
    }
  }

  @override
  bool shouldRepaint(LightPaintRect oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.shadowBorderColor != shadowBorderColor ||
        oldDelegate.shadowOpacity != shadowOpacity ||
        oldDelegate.shadowSpreadRadius != shadowSpreadRadius;
  }
}
