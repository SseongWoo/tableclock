import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// 시계 스타일
enum ClockStyle { digital, analog }

extension ClockStyleX on ClockStyle {
  String get id => name;
  String get label {
    switch (this) {
      case ClockStyle.digital:
        return '디지털';
      case ClockStyle.analog:
        return '아날로그';
    }
  }

  static ClockStyle fromId(String? id) {
    switch (id) {
      case 'analog':
        return ClockStyle.analog;
      case 'digital':
      case 'minimal':
      case 'split':
      default:
        return ClockStyle.digital;
    }
  }
}

/// 폰트 옵션
class FontOption {
  final String id;
  final String label;
  final TextStyle Function(TextStyle base) apply;

  const FontOption({
    required this.id,
    required this.label,
    required this.apply,
  });
}

TextStyle _localFont(String family, TextStyle base) {
  return base.copyWith(fontFamily: family);
}

/// 시계 폰트 목록
final List<FontOption> kFonts = [
  FontOption(
    id: 'orbitron',
    label: 'Orbitron',
    apply: (b) => GoogleFonts.orbitron(textStyle: b),
  ),
  FontOption(
    id: 'spacemono',
    label: 'Space Mono',
    apply: (b) => GoogleFonts.spaceMono(textStyle: b),
  ),
  FontOption(
    id: 'playfair',
    label: 'Playfair Display',
    apply: (b) => GoogleFonts.playfairDisplay(textStyle: b),
  ),
  FontOption(
    id: 'josefin',
    label: 'Josefin Sans',
    apply: (b) => GoogleFonts.josefinSans(textStyle: b),
  ),
  FontOption(
    id: 'dm',
    label: 'DM Serif',
    apply: (b) => GoogleFonts.dmSerifDisplay(textStyle: b),
  ),
  FontOption(
    id: 'noto',
    label: '노토 산스',
    apply: (b) => GoogleFonts.notoSansKr(textStyle: b),
  ),
  FontOption(
    id: 'noto-serif',
    label: '노토 세리프',
    apply: (b) => GoogleFonts.notoSerifKr(textStyle: b),
  ),
  FontOption(
    id: 'cafe24-ssurround',
    label: 'Cafe24 써라운드',
    apply: (b) => _localFont('Cafe24Ssurround', b),
  ),
  FontOption(
    id: 'gmarket-sans',
    label: 'G마켓 산스',
    apply: (b) => _localFont('GmarketSans', b),
  ),
  FontOption(
    id: 'mona-10x12',
    label: 'Mona 10x12',
    apply: (b) => _localFont('Mona10x12', b),
  ),
  FontOption(
    id: 'pretendard',
    label: 'Pretendard',
    apply: (b) => _localFont('Pretendard', b),
  ),
  FontOption(
    id: 'gyeonggi-batang',
    label: '경기천년바탕',
    apply: (b) => _localFont('GyeonggiBatang', b),
  ),
  FontOption(
    id: 'gyeonggi-title',
    label: '경기천년제목',
    apply: (b) => _localFont('GyeonggiTitle', b),
  ),
  FontOption(
    id: 'ongle-park-dahyun',
    label: '온글잎 박다현체',
    apply: (b) => _localFont('OngleParkDahyun', b),
  ),
];

FontOption fontById(String id) =>
    kFonts.firstWhere((f) => f.id == id, orElse: () => kFonts.first);

/// 한국어 UI 폰트 (Noto Sans KR)
TextStyle uiTextStyle({
  double? fontSize,
  Color? color,
  FontWeight? fontWeight,
  double? letterSpacing,
}) {
  return GoogleFonts.notoSansKr(
    fontSize: fontSize,
    color: color,
    fontWeight: fontWeight,
    letterSpacing: letterSpacing,
  );
}

/// 시계 설정 모델 (불변)
class ClockSettings {
  final String fontId;
  final bool showSeconds;
  final bool showDate;
  final bool use24h;
  final bool burnIn;
  final int burnInInterval; // seconds
  final bool presetShuffle;
  final int presetShuffleInterval; // seconds
  final ClockStyle style;
  final int fontSize; // 50 ~ 150 (%)
  final Color fontColor;
  final Color bgColor;

  const ClockSettings({
    this.fontId = 'orbitron',
    this.showSeconds = true,
    this.showDate = true,
    this.use24h = true,
    this.burnIn = true,
    this.burnInInterval = 30,
    this.presetShuffle = false,
    this.presetShuffleInterval = 60,
    this.style = ClockStyle.digital,
    this.fontSize = 100,
    this.fontColor = const Color(0xFFFFFFFF),
    this.bgColor = const Color(0xFF000000),
  });

  ClockSettings copyWith({
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
    return ClockSettings(
      fontId: fontId ?? this.fontId,
      showSeconds: showSeconds ?? this.showSeconds,
      showDate: showDate ?? this.showDate,
      use24h: use24h ?? this.use24h,
      burnIn: burnIn ?? this.burnIn,
      burnInInterval: burnInInterval ?? this.burnInInterval,
      presetShuffle: presetShuffle ?? this.presetShuffle,
      presetShuffleInterval:
          presetShuffleInterval ?? this.presetShuffleInterval,
      style: style ?? this.style,
      fontSize: fontSize ?? this.fontSize,
      fontColor: fontColor ?? this.fontColor,
      bgColor: bgColor ?? this.bgColor,
    );
  }

  Map<String, dynamic> toJson() => {
    'fontId': fontId,
    'showSeconds': showSeconds,
    'showDate': showDate,
    'use24h': use24h,
    'burnIn': burnIn,
    'burnInInterval': burnInInterval,
    'presetShuffle': presetShuffle,
    'presetShuffleInterval': presetShuffleInterval,
    'style': style.name,
    'fontSize': fontSize,
    'fontColor': fontColor.toARGB32(),
    'bgColor': bgColor.toARGB32(),
  };

  factory ClockSettings.fromJson(Map<String, dynamic> j) {
    return ClockSettings(
      fontId: j['fontId'] as String? ?? 'orbitron',
      showSeconds: j['showSeconds'] as bool? ?? true,
      showDate: j['showDate'] as bool? ?? true,
      use24h: j['use24h'] as bool? ?? true,
      burnIn: j['burnIn'] as bool? ?? true,
      burnInInterval: (j['burnInInterval'] as num?)?.toInt() ?? 30,
      presetShuffle: j['presetShuffle'] as bool? ?? false,
      presetShuffleInterval:
          (j['presetShuffleInterval'] as num?)?.toInt() ?? 60,
      style: ClockStyleX.fromId(j['style'] as String?),
      fontSize: (j['fontSize'] as num?)?.toInt() ?? 100,
      fontColor: Color((j['fontColor'] as num?)?.toInt() ?? 0xFFFFFFFF),
      bgColor: Color((j['bgColor'] as num?)?.toInt() ?? 0xFF000000),
    );
  }

  /// 배경 프리셋 (UI 미리보기 + 일괄 적용용)
  static const List<ClockPreset> presets = [
    ClockPreset(Color(0xFF000000), Color(0xFFFFFFFF)),
    ClockPreset(Color(0xFF0D0D0D), Color(0xFFFFFFFF)),
    ClockPreset(Color(0xFF1A1A2E), Color(0xFFE0E0FF)),
    ClockPreset(Color(0xFF0A1628), Color(0xFF88BBFF)),
    ClockPreset(Color(0xFF1A0A0A), Color(0xFFFFBBAA)),
    ClockPreset(Color(0xFF0D1A0A), Color(0xFFAAFFAA)),
    ClockPreset(Color(0xFFFFFDF7), Color(0xFF111111)),
    ClockPreset(Color(0xFFF5F0E8), Color(0xFF2A2520)),
    ClockPreset(Color(0xFF081C1C), Color(0xFFB8FFF4)),
    ClockPreset(Color(0xFF1B1024), Color(0xFFFFD6F7)),
    ClockPreset(Color(0xFF24180B), Color(0xFFFFD28A)),
    ClockPreset(Color(0xFF07131F), Color(0xFF8FE1FF)),
    ClockPreset(Color(0xFF101820), Color(0xFFFFF2C7)),
    ClockPreset(Color(0xFF210D14), Color(0xFFFF9DB7)),
    ClockPreset(Color(0xFFEAF6FF), Color(0xFF0C1B2A)),
    ClockPreset(Color(0xFFEFF7EC), Color(0xFF102314)),
  ];
}

class ClockPreset {
  final Color bg;
  final Color fg;
  const ClockPreset(this.bg, this.fg);
}
