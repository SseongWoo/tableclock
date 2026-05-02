import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

import '../controller/clock_controller.dart';
import '../controller/settings_controller.dart';
import '../settings.dart';
import '../widget/analog_clock.dart';
import '../widget/minimal_clock.dart';
import '../widget/settings_panel.dart';

/// 메인 시계 화면
///
/// - 화면 탭 → 우측 설정 패널 토글
/// - SettingsController 변경 시 ClockController 의 번인 옵션도 동기화
class ClockScreen extends StatefulWidget {
  const ClockScreen({super.key});

  @override
  State<ClockScreen> createState() => _ClockScreenState();
}

class _ClockScreenState extends State<ClockScreen> with WidgetsBindingObserver {
  final SettingsController _settingsCtrl = SettingsController();
  final ClockController _clockCtrl = ClockController();

  bool _panelOpen = false;
  bool _showHint = true;
  Timer? _hintTimer;
  Timer? _presetShuffleTimer;
  bool _presetShuffleEnabled = false;
  int _presetShuffleInterval = 60;

  final math.Random _presetRng = math.Random();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _setScreenAwake(true);
    _clockCtrl.start();
    // 기본 설정 기준 번인 시작 (load 후 다시 동기화됨)
    _clockCtrl.configureBurnIn(
      enabled: _settingsCtrl.settings.burnIn,
      intervalSec: _settingsCtrl.settings.burnInInterval,
    );
    _settingsCtrl.addListener(_onSettingsChanged);
    _settingsCtrl.load();

    _hintTimer = Timer(const Duration(seconds: 4), () {
      if (mounted) setState(() => _showHint = false);
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _setScreenAwake(false);
    _settingsCtrl.removeListener(_onSettingsChanged);
    _settingsCtrl.dispose();
    _clockCtrl.dispose();
    _hintTimer?.cancel();
    _presetShuffleTimer?.cancel();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        _setScreenAwake(true);
        break;
      case AppLifecycleState.inactive:
      case AppLifecycleState.hidden:
      case AppLifecycleState.paused:
      case AppLifecycleState.detached:
        _setScreenAwake(false);
        break;
    }
  }

  Future<void> _setScreenAwake(bool enabled) async {
    await WakelockPlus.toggle(enable: enabled);
  }

  /// 설정 변경 시 번인 옵션을 ClockController 와 동기화
  void _onSettingsChanged() {
    final s = _settingsCtrl.settings;
    if (s.burnIn != _clockCtrl.burnInEnabled ||
        s.burnInInterval != _clockCtrl.burnInInterval) {
      _clockCtrl.configureBurnIn(
        enabled: s.burnIn,
        intervalSec: s.burnInInterval,
      );
    }

    if (s.presetShuffle != _presetShuffleEnabled ||
        s.presetShuffleInterval != _presetShuffleInterval) {
      _configurePresetShuffle(
        enabled: s.presetShuffle,
        intervalSec: s.presetShuffleInterval,
      );
    }
  }

  void _configurePresetShuffle({
    required bool enabled,
    required int intervalSec,
  }) {
    _presetShuffleEnabled = enabled;
    _presetShuffleInterval = intervalSec;
    _presetShuffleTimer?.cancel();

    if (!enabled) return;

    _applyRandomPreset();
    _presetShuffleTimer = Timer.periodic(
      Duration(seconds: intervalSec),
      (_) => _applyRandomPreset(),
    );
  }

  void _applyRandomPreset() {
    if (!_settingsCtrl.loaded) return;

    final presets = ClockSettings.presets;
    if (presets.isEmpty) return;

    final current = _settingsCtrl.settings;
    final candidates = presets
        .where((p) => p.bg != current.bgColor || p.fg != current.fontColor)
        .toList();
    final pool = candidates.isEmpty ? presets : candidates;
    final next = pool[_presetRng.nextInt(pool.length)];

    _settingsCtrl.update(
      current.copyWith(bgColor: next.bg, fontColor: next.fg),
    );
  }

  void _onScreenTap() {
    setState(() {
      _panelOpen = !_panelOpen;
      if (_panelOpen) _showHint = false;
    });
  }

  String _pad2(int n) => n.toString().padLeft(2, '0');

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_settingsCtrl, _clockCtrl]),
      builder: (context, _) {
        if (!_settingsCtrl.loaded) {
          return const Scaffold(
            backgroundColor: Colors.black,
            body: SizedBox(),
          );
        }
        return _buildScaffold();
      },
    );
  }

  Widget _buildScaffold() {
    final settings = _settingsCtrl.settings;
    final now = _clockCtrl.now;
    final color = settings.fontColor;
    final bg = settings.bgColor;
    final isLightBg = bg.computeLuminance() > 0.5;

    int hours = now.hour;
    String ampm = '';
    if (!settings.use24h) {
      ampm = hours >= 12 ? 'PM' : 'AM';
      hours = hours % 12;
      if (hours == 0) hours = 12;
    }
    final hStr = _pad2(hours);
    final mStr = _pad2(now.minute);
    final sStr = _pad2(now.second);
    final timeStr = settings.showSeconds ? '$hStr:$mStr:$sStr' : '$hStr:$mStr';

    const days = ['일', '월', '화', '수', '목', '금', '토'];
    final weekday = now.weekday % 7; // Mon=1...Sun=7 → 일=0
    final dateStr = '${now.year}년 ${now.month}월 ${now.day}일 (${days[weekday]})';

    final font = fontById(settings.fontId);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: isLightBg ? SystemUiOverlayStyle.dark : SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: bg,
        body: LayoutBuilder(
          builder: (context, constraints) {
            final screenW = constraints.maxWidth;
            final screenH = constraints.maxHeight;
            final shortest = math.min(screenW, screenH);
            final availableW = _panelOpen
                ? math.max(screenW - 320.0, 200.0)
                : screenW;

            return Stack(
              children: [
                // 시계 영역 + 화면 탭 처리
                Positioned.fill(
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: _onScreenTap,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 400),
                      color: bg,
                      alignment: Alignment.center,
                      child: TweenAnimationBuilder<Offset>(
                        tween: Tween(
                          begin: Offset.zero,
                          end: _clockCtrl.burnOffset,
                        ),
                        duration: const Duration(milliseconds: 2000),
                        curve: Curves.easeInOut,
                        builder: (_, off, child) =>
                            Transform.translate(offset: off, child: child),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 380),
                          curve: Curves.easeOutCubic,
                          width: availableW,
                          child: _buildClockContent(
                            settings: settings,
                            font: font,
                            color: color,
                            now: now,
                            timeStr: timeStr,
                            hStr: hStr,
                            mStr: mStr,
                            sStr: sStr,
                            ampm: ampm,
                            dateStr: dateStr,
                            shortest: shortest,
                            availableW: availableW,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                // 힌트
                if (_showHint && !_panelOpen)
                  Positioned(
                    right: 32,
                    bottom: 32,
                    child: IgnorePointer(
                      child: AnimatedOpacity(
                        opacity: _showHint ? 0.55 : 0,
                        duration: const Duration(milliseconds: 600),
                        child: Text(
                          '화면을 탭하면 설정이 열립니다',
                          style: uiTextStyle(
                            fontSize: 12,
                            color: color,
                            letterSpacing: 0.6,
                          ),
                        ),
                      ),
                    ),
                  ),

                // 디머 (패널 외부 탭 → 닫기)
                IgnorePointer(
                  ignoring: !_panelOpen,
                  child: AnimatedOpacity(
                    opacity: _panelOpen ? 1 : 0,
                    duration: const Duration(milliseconds: 350),
                    child: GestureDetector(
                      onTap: () => setState(() => _panelOpen = false),
                      child: Container(
                        color: Colors.black.withValues(alpha: 0.35),
                      ),
                    ),
                  ),
                ),

                // 설정 패널 (외부 탭 전파 차단)
                AnimatedPositioned(
                  duration: const Duration(milliseconds: 380),
                  curve: Curves.easeOutCubic,
                  top: 0,
                  bottom: 0,
                  right: _panelOpen ? 0 : -320,
                  width: 320,
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () {},
                    child: SettingsPanel(
                      settings: settings,
                      fontSectionExpanded: _settingsCtrl.fontSectionExpanded,
                      onChanged: _settingsCtrl.update,
                      onToggleFontSection: _settingsCtrl.toggleFontSection,
                      onClose: () => setState(() => _panelOpen = false),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildClockContent({
    required ClockSettings settings,
    required FontOption font,
    required Color color,
    required DateTime now,
    required String timeStr,
    required String hStr,
    required String mStr,
    required String sStr,
    required String ampm,
    required String dateStr,
    required double shortest,
    required double availableW,
  }) {
    final scale = settings.fontSize / 100.0; // 0.5 ~ 1.5
    Widget clock;
    Widget? dateW;
    double gap = 12;

    switch (settings.style) {
      case ClockStyle.analog:
        final size = shortest * 0.7 * scale;
        clock = AnalogClock(time: now, color: color, size: size);
        gap = 24;
        if (settings.showDate) {
          dateW = Text(
            dateStr,
            style: uiTextStyle(
              fontSize: math.max(14, settings.fontSize * 0.14),
              color: color.withValues(alpha: 0.45),
              letterSpacing: 0.7,
            ),
          );
        }
        break;
      case ClockStyle.digital:
        final fs = availableW * 0.00115 * settings.fontSize;
        clock = MinimalClock(
          timeStr: timeStr,
          color: color,
          font: font,
          use24h: settings.use24h,
          ampm: ampm,
          fontSize: fs,
        );
        if (settings.showDate) {
          dateW = Text(
            dateStr,
            style: uiTextStyle(
              fontSize: availableW * 0.00022 * settings.fontSize,
              color: color.withValues(alpha: 0.38),
              letterSpacing: 0.8,
            ),
          );
        }
        break;
    }

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        FittedBox(fit: BoxFit.scaleDown, child: clock),
        if (settings.style == ClockStyle.digital &&
            !settings.use24h &&
            ampm.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              ampm,
              style: font.apply(
                TextStyle(
                  fontSize: availableW * 0.00030 * settings.fontSize,
                  color: color.withValues(alpha: 0.45),
                  letterSpacing: 1.5,
                ),
              ),
            ),
          ),
        if (dateW != null) ...[
          SizedBox(height: gap),
          FittedBox(fit: BoxFit.scaleDown, child: dateW),
        ],
      ],
    );
  }
}
