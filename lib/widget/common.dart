import 'package:flutter/material.dart';

import '../settings.dart';

/// 칩 옵션
class ChipOpt<T> {
  final T id;
  final String label;
  const ChipOpt({required this.id, required this.label});
}

/// 칩 그룹 - 옵션 중 하나 선택
class ChipGroup<T> extends StatelessWidget {
  final List<ChipOpt<T>> options;
  final T value;
  final ValueChanged<T> onChange;

  /// true 면 한 줄에 정확히 두 칸으로 50% 폭으로 채움
  final bool fullWidth;

  const ChipGroup({
    super.key,
    required this.options,
    required this.value,
    required this.onChange,
    this.fullWidth = false,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (fullWidth) {
          return Wrap(
            spacing: 6,
            runSpacing: 6,
            children: options.map((o) {
              final active = o.id == value;
              return SizedBox(
                width: (constraints.maxWidth - 6) / 2,
                child: _chip(o, active),
              );
            }).toList(),
          );
        }
        return Wrap(
          spacing: 6,
          runSpacing: 6,
          children: options.map((o) => _chip(o, o.id == value)).toList(),
        );
      },
    );
  }

  Widget _chip(ChipOpt<T> o, bool active) {
    return GestureDetector(
      onTap: () => onChange(o.id),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: active
              ? Colors.white.withValues(alpha: 0.9)
              : Colors.white.withValues(alpha: 0.07),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: active
                ? Colors.transparent
                : Colors.white.withValues(alpha: 0.1),
            width: 1,
          ),
        ),
        alignment: Alignment.center,
        child: Text(
          o.label,
          textAlign: TextAlign.center,
          style: uiTextStyle(
            fontSize: 12,
            color: active
                ? const Color(0xFF111111)
                : Colors.white.withValues(alpha: 0.55),
          ),
        ),
      ),
    );
  }
}

/// 토글 행 - 라벨 + AppSwitch
class ToggleRow extends StatelessWidget {
  final String label;
  final bool value;
  final ValueChanged<bool> onChange;

  const ToggleRow({
    super.key,
    required this.label,
    required this.value,
    required this.onChange,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              label,
              style: uiTextStyle(
                fontSize: 14,
                color: Colors.white.withValues(alpha: 0.75),
              ),
            ),
          ),
          AppSwitch(value: value, onChanged: onChange),
        ],
      ),
    );
  }
}

/// 커스텀 토글 (HTML 원본과 동일한 모양)
class AppSwitch extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;
  const AppSwitch({super.key, required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onChanged(!value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        width: 44,
        height: 24,
        decoration: BoxDecoration(
          color: value
              ? Colors.white.withValues(alpha: 0.85)
              : Colors.white.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Stack(
          children: [
            AnimatedPositioned(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeInOut,
              top: 3,
              left: value ? 23 : 3,
              child: Container(
                width: 18,
                height: 18,
                decoration: BoxDecoration(
                  color: value
                      ? const Color(0xFF111111)
                      : Colors.white.withValues(alpha: 0.5),
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 섹션 라벨 (대문자 1차)
class SectionLabel extends StatelessWidget {
  final String text;
  const SectionLabel(this.text, {super.key});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text.toUpperCase(),
        style: uiTextStyle(
          fontSize: 11,
          color: Colors.white.withValues(alpha: 0.35),
          letterSpacing: 1.1,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

/// 서브 섹션 라벨
class SectionLabelSub extends StatelessWidget {
  final String text;
  const SectionLabelSub(this.text, {super.key});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, top: 4),
      child: Text(
        text.toUpperCase(),
        style: uiTextStyle(
          fontSize: 10,
          color: Colors.white.withValues(alpha: 0.3),
          letterSpacing: 1.0,
        ),
      ),
    );
  }
}

/// 패널용 얇은 디바이더
class AppDivider extends StatelessWidget {
  const AppDivider({super.key});
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 1,
      margin: const EdgeInsets.symmetric(vertical: 18),
      color: Colors.white.withValues(alpha: 0.06),
    );
  }
}
