import 'package:flutter/material.dart';

import '../settings.dart';

/// 디지털 시계 (Orbitron + LCD-shadow)
class DigitalClock extends StatelessWidget {
  final String timeStr;
  final Color color;
  final double fontSize;

  const DigitalClock({
    super.key,
    required this.timeStr,
    required this.color,
    required this.fontSize,
  });

  @override
  Widget build(BuildContext context) {
    final orbitron = fontById('orbitron');
    return Text(
      timeStr,
      style: orbitron.apply(
        TextStyle(
          fontSize: fontSize,
          color: color,
          letterSpacing: fontSize * 0.08,
          height: 1.0,
          shadows: [
            Shadow(color: color.withValues(alpha: 0.27), blurRadius: 30),
            Shadow(color: color.withValues(alpha: 0.13), blurRadius: 60),
          ],
        ),
      ),
    );
  }
}
