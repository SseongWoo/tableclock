import 'package:flutter/material.dart';

import '../settings.dart';

/// HSV 슬라이더 + 팔레트가 있는 색상 선택 다이얼로그
///
/// 사용:
/// ```dart
/// final c = await showDialog<Color>(
///   context: context,
///   builder: (_) => ColorPickerDialog(initial: current),
/// );
/// ```
class ColorPickerDialog extends StatefulWidget {
  final Color initial;
  const ColorPickerDialog({super.key, required this.initial});

  @override
  State<ColorPickerDialog> createState() => _ColorPickerDialogState();
}

class _ColorPickerDialogState extends State<ColorPickerDialog> {
  late double _h; // 0..360
  late double _s; // 0..1
  late double _v; // 0..1

  static const _palette = <Color>[
    Color(0xFFFFFFFF),
    Color(0xFFE0E0E0),
    Color(0xFF9E9E9E),
    Color(0xFF424242),
    Color(0xFF000000),
    Color(0xFFFF5252),
    Color(0xFFFF9800),
    Color(0xFFFFEB3B),
    Color(0xFF4CAF50),
    Color(0xFF00BCD4),
    Color(0xFF2196F3),
    Color(0xFF3F51B5),
    Color(0xFF9C27B0),
    Color(0xFFE91E63),
    Color(0xFFFFBBAA),
    Color(0xFFAAFFAA),
    Color(0xFF88BBFF),
    Color(0xFFE0E0FF),
    Color(0xFFFFFDF7),
    Color(0xFFF5F0E8),
  ];

  @override
  void initState() {
    super.initState();
    final hsv = HSVColor.fromColor(widget.initial);
    _h = hsv.hue;
    _s = hsv.saturation;
    _v = hsv.value;
  }

  Color get _current => HSVColor.fromAHSV(1.0, _h, _s, _v).toColor();

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: const Color(0xFF1A1A1A),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '색상 선택',
              style: uiTextStyle(
                fontSize: 16,
                color: Colors.white.withValues(alpha: 0.9),
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 16),
            // 미리보기
            Container(
              height: 60,
              decoration: BoxDecoration(
                color: _current,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
              ),
            ),
            const SizedBox(height: 16),
            // 팔레트
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _palette.map((c) {
                return GestureDetector(
                  onTap: () {
                    final hsv = HSVColor.fromColor(c);
                    setState(() {
                      _h = hsv.hue;
                      _s = hsv.saturation;
                      _v = hsv.value;
                    });
                  },
                  child: Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: c,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.15),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            _ColorSlider(
              label: 'H',
              value: _h,
              max: 360,
              gradient: const LinearGradient(
                colors: [
                  Color(0xFFFF0000),
                  Color(0xFFFFFF00),
                  Color(0xFF00FF00),
                  Color(0xFF00FFFF),
                  Color(0xFF0000FF),
                  Color(0xFFFF00FF),
                  Color(0xFFFF0000),
                ],
              ),
              onChanged: (v) => setState(() => _h = v),
            ),
            _ColorSlider(
              label: 'S',
              value: _s * 100,
              max: 100,
              gradient: LinearGradient(
                colors: [
                  HSVColor.fromAHSV(1, _h, 0, _v).toColor(),
                  HSVColor.fromAHSV(1, _h, 1, _v).toColor(),
                ],
              ),
              onChanged: (v) => setState(() => _s = v / 100),
            ),
            _ColorSlider(
              label: 'V',
              value: _v * 100,
              max: 100,
              gradient: LinearGradient(
                colors: [
                  HSVColor.fromAHSV(1, _h, _s, 0).toColor(),
                  HSVColor.fromAHSV(1, _h, _s, 1).toColor(),
                ],
              ),
              onChanged: (v) => setState(() => _v = v / 100),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(
                    '취소',
                    style: uiTextStyle(
                      color: Colors.white.withValues(alpha: 0.5),
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(_current),
                  child: Text(
                    '확인',
                    style: uiTextStyle(
                      color: Colors.white.withValues(alpha: 0.9),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ColorSlider extends StatelessWidget {
  final String label;
  final double value;
  final double max;
  final Gradient gradient;
  final ValueChanged<double> onChanged;

  const _ColorSlider({
    required this.label,
    required this.value,
    required this.max,
    required this.gradient,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 18,
            child: Text(
              label,
              style: uiTextStyle(
                fontSize: 11,
                color: Colors.white.withValues(alpha: 0.5),
              ),
            ),
          ),
          Expanded(
            child: Stack(
              alignment: Alignment.centerLeft,
              children: [
                Container(
                  height: 8,
                  decoration: BoxDecoration(
                    gradient: gradient,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                SliderTheme(
                  data: SliderThemeData(
                    trackHeight: 0,
                    activeTrackColor: Colors.transparent,
                    inactiveTrackColor: Colors.transparent,
                    thumbColor: Colors.white,
                    overlayColor: Colors.white.withValues(alpha: 0.1),
                    thumbShape: const RoundSliderThumbShape(
                      enabledThumbRadius: 7,
                    ),
                  ),
                  child: Slider(
                    min: 0,
                    max: max,
                    value: value.clamp(0, max),
                    onChanged: onChanged,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
