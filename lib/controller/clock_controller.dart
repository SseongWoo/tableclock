import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';

/// 시간 틱 + 번인 위치 이동을 관리하는 컨트롤러
class ClockController extends ChangeNotifier {
  DateTime _now = DateTime.now();
  Offset _burnOffset = Offset.zero;

  Timer? _tickTimer;
  Timer? _burnTimer;

  bool _burnInEnabled = true;
  int _burnInInterval = 30;

  final math.Random _rng = math.Random();
  bool _disposed = false;

  DateTime get now => _now;
  Offset get burnOffset => _burnOffset;

  /// 1초 주기 시계 시작
  void start() {
    _tickTimer?.cancel();
    _now = DateTime.now();
    _tickTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_disposed) return;
      _now = DateTime.now();
      notifyListeners();
    });
  }

  /// 번인 방지 옵션을 적용 (옵션이 바뀌면 호출)
  void configureBurnIn({required bool enabled, required int intervalSec}) {
    _burnInEnabled = enabled;
    _burnInInterval = intervalSec;
    _burnTimer?.cancel();
    if (!enabled) {
      _burnOffset = Offset.zero;
      notifyListeners();
      return;
    }
    _burnTimer = Timer.periodic(Duration(seconds: intervalSec), (_) {
      if (_disposed) return;
      final dx = ((_rng.nextDouble() - 0.5) * 96).roundToDouble();
      final dy = ((_rng.nextDouble() - 0.5) * 56).roundToDouble();
      _burnOffset = Offset(dx, dy);
      notifyListeners();
    });
  }

  bool get burnInEnabled => _burnInEnabled;
  int get burnInInterval => _burnInInterval;

  @override
  void dispose() {
    _disposed = true;
    _tickTimer?.cancel();
    _burnTimer?.cancel();
    super.dispose();
  }
}
