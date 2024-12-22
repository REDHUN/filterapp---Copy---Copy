import 'package:flutter/material.dart';

class ColorPalette {
  // Primary colors
  static const Color purple = Colors.purple;
  static const Color white = Colors.white;
  static const Color black = Colors.black;

  // Text colors
  static const Color textPrimary = Colors.black87;
  static const Color textError = Colors.red;

  // Button colors
  static const Color buttonPrimary = Color(0xFF4B4B4B);

  // States and overlays
  static final Color purpleOverlay = Colors.purple.withOpacity(0.1);
  static final Color shadowColor = Colors.black.withOpacity(0.1);
  static final Color borderColor = Colors.grey.withOpacity(0.2);

  // Shimmer colors
  static final Color shimmerBase = Colors.grey[300]!;
  static final Color shimmerHighlight = Colors.grey[100]!;
}
