import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// AnticiFi logo widget with gradient icon and text.
class AppLogo extends StatelessWidget {
  final double size;
  final bool showText;
  final Color? textColor;

  const AppLogo({
    super.key,
    this.size = 80,
    this.showText = true,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _LogoIcon(size: size),
        if (showText) ...[
          SizedBox(height: size * 0.2),
          ShaderMask(
            shaderCallback: (bounds) => const LinearGradient(
              colors: [AppColors.primary, AppColors.accent],
            ).createShader(bounds),
            child: Text(
              'AnticiFi',
              style: TextStyle(
                fontSize: size * 0.45,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: -0.5,
              ),
            ),
          ),
        ],
      ],
    );
  }
}

/// Custom painted logo icon — stylized "A" with chart arrow.
class _LogoIcon extends StatelessWidget {
  final double size;

  const _LogoIcon({required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(size * 0.22),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.primary, AppColors.accent],
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.35),
            blurRadius: size * 0.3,
            offset: Offset(0, size * 0.1),
          ),
        ],
      ),
      child: CustomPaint(
        size: Size(size, size),
        painter: _LogoPainter(),
      ),
    );
  }
}

class _LogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.055
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    // Chart line going upward (financial growth)
    final chartPath = Path();
    chartPath.moveTo(w * 0.2, h * 0.7);
    chartPath.lineTo(w * 0.35, h * 0.5);
    chartPath.lineTo(w * 0.5, h * 0.6);
    chartPath.lineTo(w * 0.8, h * 0.28);
    canvas.drawPath(chartPath, paint);

    // Arrow tip at end of chart line
    final arrowPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    final arrowPath = Path();
    final tipX = w * 0.8;
    final tipY = h * 0.28;
    final arrowSize = w * 0.07;

    arrowPath.moveTo(tipX, tipY);
    arrowPath.lineTo(tipX - arrowSize * 1.8, tipY + arrowSize * 0.3);
    arrowPath.lineTo(tipX - arrowSize * 0.5, tipY + arrowSize * 1.5);
    arrowPath.close();
    canvas.drawPath(arrowPath, arrowPaint);

    // Small dot at the start
    canvas.drawCircle(
      Offset(w * 0.2, h * 0.7),
      w * 0.035,
      Paint()..color = Colors.white,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
