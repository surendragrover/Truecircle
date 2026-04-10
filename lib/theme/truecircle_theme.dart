import 'package:flutter/material.dart';

class TrueCircleTheme {
  const TrueCircleTheme._();

  static const Color brandPrimary = Color(0xFF6A1B9A);
  static const Color brandSecondary = Color(0xFF9C27B0);
  static const Color surfaceTint = Color(0xFFF3ECFF);

  static const LinearGradient appBackgroundGradient = LinearGradient(
    colors: <Color>[brandPrimary, brandSecondary],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
