import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../settings.dart';

class SettingsController extends ChangeNotifier {
  static const _prefsKey = 'clock_settings';

  ClockSettings _settings = const ClockSettings();
  bool _loaded = false;
  bool _fontSectionExpanded = false;

  ClockSettings get settings => _settings;
  bool get loaded => _loaded;
  bool get fontSectionExpanded => _fontSectionExpanded;

  /// SharedPreferences 에서 설정 로드
  Future<void> load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_prefsKey);
      if (raw != null) {
        final json = jsonDecode(raw) as Map<String, dynamic>;
        _settings = ClockSettings.fromJson(json);
      }
    } catch (_) {
      // 손상된 저장값 무시 - 기본값 유지
    }
    _loaded = true;
    notifyListeners();
  }

  /// 설정 갱신 + 디스크 저장 + 리스너 통지
  void update(ClockSettings next) {
    if (identical(_settings, next)) return;
    _settings = next;
    notifyListeners();
    _persist();
  }

  void toggleFontSection() {
    _fontSectionExpanded = !_fontSectionExpanded;
    notifyListeners();
  }

  /// 부분 업데이트 헬퍼
  void patch({
    String? fontId,
    bool? showSeconds,
    bool? showDate,
    bool? use24h,
    bool? burnIn,
    int? burnInInterval,
    bool? presetShuffle,
    int? presetShuffleInterval,
    ClockStyle? style,
    int? fontSize,
    Color? fontColor,
    Color? bgColor,
  }) {
    update(
      _settings.copyWith(
        fontId: fontId,
        showSeconds: showSeconds,
        showDate: showDate,
        use24h: use24h,
        burnIn: burnIn,
        burnInInterval: burnInInterval,
        presetShuffle: presetShuffle,
        presetShuffleInterval: presetShuffleInterval,
        style: style,
        fontSize: fontSize,
        fontColor: fontColor,
        bgColor: bgColor,
      ),
    );
  }

  Future<void> _persist() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_prefsKey, jsonEncode(_settings.toJson()));
    } catch (_) {}
  }
}
