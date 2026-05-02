import 'dart:math' as math;
import 'package:flutter/material.dart';

/// 아날로그 시계 (CustomPainter)
class AnalogClock extends StatelessWidget {
  final DateTime time;
  final Color color;
  final double size;

  const AnalogClock({
    super.key,
    required this.time,
    required this.color,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(size, size),
      painter: _AnalogClockPainter(time: time, color: color),
    );
  }
}

class _AnalogClockPainter extends CustomPainter {
  final DateTime time;
  final Color color;

  _AnalogClockPainter({required this.time, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final r = size.width / 2;
    final center = Offset(r, r);

    // 외곽 링
    final ringPaint = Paint()
      ..color = color.withValues(alpha: 0.15)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    canvas.drawCircle(center, r * 0.97, ringPaint);

    Offset toXY(double deg, double len) {
      final rad = deg * math.pi / 180.0;
      return Offset(
        center.dx + math.sin(rad) * len,
        center.dy - math.cos(rad) * len,
      );
    }

    // 60개 눈금
    for (var i = 0; i < 60; i++) {
      final major = i % 5 == 0;
      final a = i * 6.0;
      final inner = major ? r * 0.82 : r * 0.87;
      final outer = r * 0.94;
      final p1 = toXY(a, inner);
      final p2 = toXY(a, outer);
      final tickPaint = Paint()
        ..color = color.withValues(alpha: major ? 0.6 : 0.2)
        ..strokeWidth = major ? 2 : 1
        ..strokeCap = StrokeCap.round;
      canvas.drawLine(p1, p2, tickPaint);
    }

    // 시침/분침/초침 좌표
    final hour = (time.hour % 12) + time.minute / 60.0;
    final minute = time.minute + time.second / 60.0;
    final second = time.second.toDouble();

    final hp = toXY(hour * 30, r * 0.52);
    final mp = toXY(minute * 6, r * 0.72);
    final sp = toXY(second * 6, r * 0.80);

    // 시침
    canvas.drawLine(
      center,
      hp,
      Paint()
        ..color = color.withValues(alpha: 0.95)
        ..strokeWidth = r * 0.045
        ..strokeCap = StrokeCap.round,
    );

    // 분침
    canvas.drawLine(
      center,
      mp,
      Paint()
        ..color = color.withValues(alpha: 0.9)
        ..strokeWidth = r * 0.028
        ..strokeCap = StrokeCap.round,
    );

    // 초침
    canvas.drawLine(
      center,
      sp,
      Paint()
        ..color = color.withValues(alpha: 0.7)
        ..strokeWidth = r * 0.012
        ..strokeCap = StrokeCap.round,
    );

    // 중심점
    canvas.drawCircle(
      center,
      r * 0.025,
      Paint()..color = color.withValues(alpha: 0.8),
    );
  }

  @override
  bool shouldRepaint(covariant _AnalogClockPainter old) {
    return old.time != time || old.color != color;
  }
}
