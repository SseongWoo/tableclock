import 'package:flutter/material.dart';

import '../settings.dart';

/// 미니멀 시계 - 단일 텍스트
class MinimalClock extends StatelessWidget {
  final String timeStr;
  final Color color;
  final FontOption font;
  final bool use24h;
  final String ampm;
  final double fontSize;

  const MinimalClock({
    super.key,
    required this.timeStr,
    required this.color,
    required this.font,
    required this.use24h,
    required this.ampm,
    required this.fontSize,
  });

  @override
  Widget build(BuildContext context) {
    final letterSpacing = font.id == 'josefin'
        ? fontSize * 0.15
        : fontSize * 0.04;
    final main = font.apply(
      TextStyle(
        fontSize: fontSize,
        color: color,
        letterSpacing: letterSpacing,
        fontWeight: FontWeight.w300,
        height: 1.0,
      ),
    );
    final ampmStyle = font.apply(
      TextStyle(
        fontSize: fontSize * 0.25,
        color: color.withValues(alpha: 0.45),
        letterSpacing: fontSize * 0.05 * 0.25,
        height: 1.0,
      ),
    );

    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      children: [
        Text(timeStr, style: main),
        if (!use24h && ampm.isNotEmpty)
          Padding(
            padding: EdgeInsets.only(
              left: fontSize * 0.04,
              bottom: fontSize * 0.20,
            ),
            child: Text(ampm, style: ampmStyle),
          ),
      ],
    );
  }
}
