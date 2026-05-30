import 'package:flutter/material.dart';

class AnimatedCounter extends StatelessWidget {
  final double value;
  final TextStyle? style;
  final String Function(double) formatter;
  final Duration duration;
  final String? prefix;

  const AnimatedCounter({
    super.key,
    required this.value,
    this.style,
    required this.formatter,
    this.duration = const Duration(milliseconds: 1200),
    this.prefix,
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: value),
      duration: duration,
      curve: Curves.easeOutCubic,
      builder: (context, currentValue, child) {
        final formatted = formatter(currentValue);
        final text = prefix != null ? '$prefix$formatted' : formatted;
        return Text(text, style: style);
      },
    );
  }
}
