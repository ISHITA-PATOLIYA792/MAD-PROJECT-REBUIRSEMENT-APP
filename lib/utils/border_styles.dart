import 'package:flutter/material.dart';

/// Utility class that provides standard border styles for the application
class BorderStyles {
  // standard border width for all components
  static const double borderWidth = 1.5;
  
  // standard border radius for regular components
  static const double borderRadius = 12.0;
  
  // border radius for circular components
  static const double circularBorderRadius = 100.0;
  
  // get standard border for light theme
  static Border getLightBorder() {
    return Border.all(
      color: Colors.grey.shade300,
      width: borderWidth,
    );
  }
  
  // get standard border for dark theme
  static Border getDarkBorder() {
    return Border.all(
      color: Colors.grey.shade800,
      width: borderWidth,
    );
  }
  
  // get themed border based on current brightness
  static Border getThemedBorder(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark ? getDarkBorder() : getLightBorder();
  }
  
  // get colored border
  static Border getColoredBorder(Color color, {double width = borderWidth}) {
    return Border.all(
      color: color,
      width: width,
    );
  }
} 