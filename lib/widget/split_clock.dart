import 'package:flutter/material.dart';

import '../settings.dart';

/// 분리형 시계 - 시:분 큰 글자, 초/AMPM 작은 글자
class SplitClock extends StatelessWidget {
  final String h;
  final String m;
  final String s;
  final bool showSec;
  final Color color;
  final FontOption font;
  final bool use24h;
  final String ampm;
  final double fontSize;

  const SplitClock({
    super.key,
    required this.h,
    required this.m,
    required this.s,
    required this.showSec,
    required this.color,
    required this.font,
    required this.use24h,
    required this.ampm,
    required this.fontSize,
  });

  @override
  Widget build(BuildContext context) {
    final main = font.apply(
      TextStyle(fontSize: fontSize, color: color, height: 1.0),
    );
    final colon = font.apply(
      TextStyle(
        fontSize: fontSize * 0.55,
        color: color.withValues(alpha: 0.4),
        height: 1.0,
      ),
    );
    final secStyle = font.apply(
      TextStyle(
        fontSize: fontSize * 0.55,
        color: color.withValues(alpha: 0.7),
        height: 1.0,
      ),
    );
    final ampmStyle = font.apply(
      TextStyle(
        fontSize: fontSize * 0.25,
        color: color.withValues(alpha: 0.5),
        letterSpacing: 1.2,
        height: 1.0,
      ),
    );

    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Padding(
          padding: EdgeInsets.only(right: fontSize * 0.06),
          child: Text(h, style: main),
        ),
        Padding(
          padding: EdgeInsets.only(
            bottom: fontSize * 0.10,
            right: fontSize * 0.06,
          ),
          child: Text(':', style: colon),
        ),
        Text(m, style: main),
        if (showSec) ...[
          Padding(
            padding: EdgeInsets.only(
              left: fontSize * 0.06,
              bottom: fontSize * 0.10,
              right: fontSize * 0.06,
            ),
            child: Text(':', style: colon),
          ),
          Padding(
            padding: EdgeInsets.only(bottom: fontSize * 0.06),
            child: Text(s, style: secStyle),
          ),
        ],
        if (!use24h && ampm.isNotEmpty)
          Padding(
            padding: EdgeInsets.only(
              left: fontSize * 0.10,
              bottom: fontSize * 0.18,
            ),
            child: Text(ampm, style: ampmStyle),
          ),
      ],
    );
  }
}
