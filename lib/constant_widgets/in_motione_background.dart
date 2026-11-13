import 'dart:ui' as ui;

import 'package:customer/theme/app_them_data.dart';
import 'package:flutter/material.dart';

/// Shared visual foundation used across the In Motione customer experience.
class InMotioneBackground extends StatelessWidget {
  const InMotioneBackground({
    super.key,
    required this.child,
    this.padding = EdgeInsets.zero,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;

  static const Color canvas = Color(0xFF101214);
  static const Color surface = Color(0xE81B1E21);
  static const Color surfaceRaised = Color(0xFF24272A);
  static const Color lime = Color(0xFF8DC63F);

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: <Color>[Color(0xFF171A1D), canvas, Color(0xFF0B0D0F)],
          stops: <double>[0, 0.52, 1],
        ),
      ),
      child: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          const RepaintBoundary(child: CustomPaint(painter: _RoutePainter())),
          Padding(padding: padding, child: child),
        ],
      ),
    );
  }
}

class InMotioneSurface extends StatelessWidget {
  const InMotioneSurface({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.borderRadius = const BorderRadius.all(Radius.circular(20)),
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final BorderRadius borderRadius;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: InMotioneBackground.surface,
        borderRadius: borderRadius,
        border: Border.all(color: Colors.white.withValues(alpha: 0.07)),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.16),
            blurRadius: 14,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: Padding(padding: padding, child: child),
    );
  }
}

class _RoutePainter extends CustomPainter {
  const _RoutePainter();

  @override
  void paint(Canvas canvas, Size size) {
    final glowRect = Rect.fromCircle(
      center: Offset(size.width * 0.85, size.height * 0.18),
      radius: size.shortestSide * 0.58,
    );
    canvas.drawRect(
      glowRect,
      Paint()
        ..shader = const RadialGradient(
          colors: <Color>[Color(0x2BFEA735), Color(0x00FEA735)],
        ).createShader(glowRect),
    );

    final topRoute = Path()
      ..moveTo(size.width * 0.76, -48)
      ..cubicTo(
        size.width * 0.56,
        size.height * 0.15,
        size.width * 1.04,
        size.height * 0.28,
        size.width * 0.79,
        size.height * 0.44,
      );
    final bottomRoute = Path()
      ..moveTo(-45, size.height * 0.84)
      ..cubicTo(
        size.width * 0.24,
        size.height * 0.62,
        size.width * 0.55,
        size.height * 0.96,
        size.width + 55,
        size.height * 0.72,
      );

    for (final path in <Path>[topRoute, bottomRoute]) {
      canvas.drawPath(
        path,
        Paint()
          ..color = const Color(0xB5222528)
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round
          ..strokeWidth = 54,
      );
      canvas.drawPath(
        path,
        Paint()
          ..color = Colors.white.withValues(alpha: 0.035)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1,
      );
      _drawDashes(canvas, path);
    }

    canvas.drawCircle(
      Offset(size.width * 0.87, size.height * 0.38),
      5,
      Paint()..color = InMotioneBackground.lime.withValues(alpha: 0.78),
    );
    canvas.drawCircle(
      Offset(size.width * 0.11, size.height * 0.79),
      4,
      Paint()..color = AppThemData.primary500.withValues(alpha: 0.72),
    );
  }

  void _drawDashes(Canvas canvas, Path path) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.13)
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 2;
    for (final ui.PathMetric metric in path.computeMetrics()) {
      double distance = 8;
      while (distance < metric.length) {
        canvas.drawPath(
          metric.extractPath(distance, (distance + 12).clamp(0, metric.length)),
          paint,
        );
        distance += 28;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _RoutePainter oldDelegate) => false;
}
