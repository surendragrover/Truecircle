import 'package:flutter/material.dart';

/// Provides backward-compatible support for the custom [withValues] helper
/// used across the UI codebase. It mirrors Flutter's modern color component
/// accessors to keep existing calls working while clamping the requested
/// alpha to the valid 0–1 range.
extension ColorAlphaExtension on Color {
  Color withValues({double? alpha}) {
    final double effectiveAlpha = (alpha ?? a).clamp(0.0, 1.0);
    final int effectiveRed = (r * 255.0).round() & 0xff;
    final int effectiveGreen = (g * 255.0).round() & 0xff;
    final int effectiveBlue = (b * 255.0).round() & 0xff;

    return Color.fromRGBO(
      effectiveRed,
      effectiveGreen,
      effectiveBlue,
      effectiveAlpha,
    );
  }
}
