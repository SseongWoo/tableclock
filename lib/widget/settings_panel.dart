import 'package:flutter/material.dart';

import '../settings.dart';
import 'color_picker_dialog.dart';
import 'common.dart';

/// 우측 슬라이드 설정 패널 (320px 폭)
class SettingsPanel extends StatelessWidget {
  final ClockSettings settings;
  final bool fontSectionExpanded;
  final ValueChanged<ClockSettings> onChanged;
  final VoidCallback onToggleFontSection;
  final VoidCallback onClose;

  const SettingsPanel({
    super.key,
    required this.settings,
    required this.fontSectionExpanded,
    required this.onChanged,
    required this.onToggleFontSection,
    required this.onClose,
  });

  void _upd(ClockSettings next) => onChanged(next);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 320,
      decoration: BoxDecoration(
        color: const Color(0xFF121212).withValues(alpha: 0.97),
        border: Border(
          left: BorderSide(
            color: Colors.white.withValues(alpha: 0.07),
            width: 1,
          ),
        ),
      ),
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildHeader(context),
            Container(height: 1, color: Colors.white.withValues(alpha: 0.06)),
            Expanded(child: _buildBody(context)),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 20, 16, 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '설정',
            style: uiTextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.white.withValues(alpha: 0.9),
            ),
          ),
          GestureDetector(
            onTap: onClose,
            child: Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.07),
                borderRadius: BorderRadius.circular(8),
              ),
              alignment: Alignment.center,
              child: Icon(
                Icons.close,
                size: 16,
                color: Colors.white.withValues(alpha: 0.5),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    final isAnalog = settings.style == ClockStyle.analog;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 시계 스타일
          const SectionLabel('시계 스타일'),
          ChipGroup<ClockStyle>(
            options: ClockStyle.values
                .map((e) => ChipOpt(id: e, label: e.label))
                .toList(),
            value: settings.style,
            onChange: (v) => _upd(settings.copyWith(style: v)),
            fullWidth: true,
          ),
          const AppDivider(),

          if (!isAnalog) ...[
            // 글꼴
            _buildFontSection(),
            const AppDivider(),
          ],

          // 표시 옵션
          const SectionLabel('표시'),
          if (!isAnalog)
            ToggleRow(
              label: '초 표시',
              value: settings.showSeconds,
              onChange: (v) => _upd(settings.copyWith(showSeconds: v)),
            ),
          ToggleRow(
            label: '날짜 표시',
            value: settings.showDate,
            onChange: (v) => _upd(settings.copyWith(showDate: v)),
          ),

          if (!isAnalog) ...[
            const SizedBox(height: 8),
            // 시간 형식
            const SectionLabel('시간 형식'),
            ChipGroup<bool>(
              options: const [
                ChipOpt(id: true, label: '24시간'),
                ChipOpt(id: false, label: '12시간 (AM/PM)'),
              ],
              value: settings.use24h,
              onChange: (v) => _upd(settings.copyWith(use24h: v)),
              fullWidth: true,
            ),
          ],
          const AppDivider(),

          // 글자 크기
          SectionLabel(
            '${isAnalog ? '시계 크기' : '글자 크기'} — ${settings.fontSize}%',
          ),
          _appSlider(
            min: 50,
            max: 150,
            divisions: 100,
            value: settings.fontSize.toDouble(),
            onChanged: (v) => _upd(settings.copyWith(fontSize: v.round())),
          ),

          // 색상
          const SectionLabel('색상'),
          Row(
            children: [
              Expanded(
                child: _ColorBlock(
                  label: '글자',
                  color: settings.fontColor,
                  onChanged: (c) => _upd(settings.copyWith(fontColor: c)),
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: _ColorBlock(
                  label: '배경',
                  color: settings.bgColor,
                  onChanged: (c) => _upd(settings.copyWith(bgColor: c)),
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),
          const SectionLabel('배경 프리셋'),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: ClockSettings.presets.map(_presetTile).toList(),
          ),
          const SizedBox(height: 12),
          ToggleRow(
            label: '프리셋 랜덤 재생',
            value: settings.presetShuffle,
            onChange: (v) => _upd(settings.copyWith(presetShuffle: v)),
          ),
          if (settings.presetShuffle) ...[
            const SizedBox(height: 4),
            SectionLabelSub('변경 주기 — ${settings.presetShuffleInterval}초'),
            _appSlider(
              min: 10,
              max: 300,
              divisions: (300 - 10) ~/ 10,
              value: settings.presetShuffleInterval.toDouble(),
              onChanged: (v) =>
                  _upd(settings.copyWith(presetShuffleInterval: v.round())),
            ),
          ],
          const AppDivider(),

          // 번인 방지
          const SectionLabel('번인 방지'),
          ToggleRow(
            label: '위치 이동 (OLED 보호)',
            value: settings.burnIn,
            onChange: (v) => _upd(settings.copyWith(burnIn: v)),
          ),
          if (settings.burnIn) ...[
            const SizedBox(height: 4),
            SectionLabelSub('이동 주기 — ${settings.burnInInterval}초'),
            _appSlider(
              min: 10,
              max: 120,
              divisions: (120 - 10) ~/ 5,
              value: settings.burnInInterval.toDouble(),
              onChanged: (v) =>
                  _upd(settings.copyWith(burnInInterval: v.round())),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildFontSection() {
    final current = fontById(settings.fontId);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: onToggleFontSection,
          child: Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    '글꼴',
                    style: uiTextStyle(
                      fontSize: 11,
                      color: Colors.white.withValues(alpha: 0.35),
                      letterSpacing: 1.1,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                Text(
                  current.label,
                  style: uiTextStyle(
                    fontSize: 11,
                    color: Colors.white.withValues(alpha: 0.45),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(width: 8),
                AnimatedRotation(
                  turns: fontSectionExpanded ? 0.5 : 0,
                  duration: const Duration(milliseconds: 180),
                  child: Icon(
                    Icons.keyboard_arrow_down,
                    size: 18,
                    color: Colors.white.withValues(alpha: 0.45),
                  ),
                ),
              ],
            ),
          ),
        ),
        AnimatedCrossFade(
          firstChild: _fontSummaryRow(current),
          secondChild: Column(children: kFonts.map(_fontRow).toList()),
          crossFadeState: fontSectionExpanded
              ? CrossFadeState.showSecond
              : CrossFadeState.showFirst,
          duration: const Duration(milliseconds: 180),
          sizeCurve: Curves.easeOutCubic,
        ),
      ],
    );
  }

  Widget _fontSummaryRow(FontOption f) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.07),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.12),
          width: 1,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(
            child: Text(
              f.label,
              style: uiTextStyle(
                fontSize: 13,
                color: Colors.white.withValues(alpha: 0.72),
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 12),
          Text(
            '12:34',
            style: f.apply(
              TextStyle(
                fontSize: 15,
                color: Colors.white.withValues(alpha: 0.75),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _fontRow(FontOption f) {
    final active = settings.fontId == f.id;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => _upd(settings.copyWith(fontId: f.id)),
      child: Container(
        margin: const EdgeInsets.only(bottom: 4),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
        decoration: BoxDecoration(
          color: active
              ? Colors.white.withValues(alpha: 0.09)
              : Colors.transparent,
          border: Border.all(
            color: active
                ? Colors.white.withValues(alpha: 0.18)
                : Colors.transparent,
            width: 1,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              f.label,
              style: uiTextStyle(
                fontSize: 13,
                color: Colors.white.withValues(alpha: 0.7),
              ),
            ),
            Text(
              '12:34',
              style: f.apply(
                TextStyle(
                  fontSize: 15,
                  color: Colors.white.withValues(alpha: active ? 0.9 : 0.25),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _presetTile(ClockPreset p) {
    final active = settings.bgColor == p.bg;
    return GestureDetector(
      onTap: () => _upd(settings.copyWith(bgColor: p.bg, fontColor: p.fg)),
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: p.bg,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: active
                ? Colors.white.withValues(alpha: 0.6)
                : Colors.white.withValues(alpha: 0.1),
            width: 2,
          ),
        ),
        alignment: Alignment.center,
        child: Text(
          'Aa',
          style: TextStyle(
            fontSize: 10,
            color: p.fg,
            fontFamily: 'monospace',
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }

  Widget _appSlider({
    required double min,
    required double max,
    required int divisions,
    required double value,
    required ValueChanged<double> onChanged,
  }) {
    return SliderTheme(
      data: SliderThemeData(
        trackHeight: 3,
        activeTrackColor: Colors.white.withValues(alpha: 0.85),
        inactiveTrackColor: Colors.white.withValues(alpha: 0.15),
        thumbColor: Colors.white,
        overlayColor: Colors.white.withValues(alpha: 0.1),
        thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
        overlayShape: const RoundSliderOverlayShape(overlayRadius: 16),
      ),
      child: Slider(
        min: min,
        max: max,
        divisions: divisions,
        value: value.clamp(min, max),
        onChanged: onChanged,
      ),
    );
  }
}

/// 색상 블록 - 원형 색상 + hex 텍스트, 탭하면 ColorPickerDialog
class _ColorBlock extends StatelessWidget {
  final String label;
  final Color color;
  final ValueChanged<Color> onChanged;

  const _ColorBlock({
    required this.label,
    required this.color,
    required this.onChanged,
  });

  String _hex(Color c) {
    return '#${c.toARGB32().toRadixString(16).padLeft(8, '0').substring(2).toUpperCase()}';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Text(
            label,
            style: uiTextStyle(
              fontSize: 11,
              color: Colors.white.withValues(alpha: 0.3),
              letterSpacing: 0.5,
            ),
          ),
        ),
        Row(
          children: [
            GestureDetector(
              onTap: () async {
                final c = await showDialog<Color>(
                  context: context,
                  builder: (_) => ColorPickerDialog(initial: color),
                );
                if (c != null) onChanged(c);
              },
              child: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.2),
                    width: 1,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                _hex(color),
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.white.withValues(alpha: 0.3),
                  fontFamily: 'monospace',
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
