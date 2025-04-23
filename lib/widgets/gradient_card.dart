import 'package:flutter/material.dart';
import 'package:reimbursement_box/main.dart';
import 'package:reimbursement_box/utils/border_styles.dart';

class GradientCard extends StatelessWidget {
  final Widget child;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry? margin;
  final double borderRadius;
  final double borderWidth;
  final bool useGradientBorder;
  final bool isPrimary;
  final double elevation;
  final List<Color>? borderColors;
  final List<Color>? gradientColors;
  final List<BoxShadow>? boxShadow;
  final bool useSolidBorder;
  final Color? borderColor;
  
  const GradientCard({
    Key? key,
    required this.child,
    this.width,
    this.height,
    this.padding = const EdgeInsets.all(16),
    this.margin,
    this.borderRadius = 12,
    this.borderWidth = 2,
    this.useGradientBorder = true,
    this.isPrimary = true,
    this.elevation = 4,
    this.borderColors,
    this.gradientColors,
    this.boxShadow,
    this.useSolidBorder = false,
    this.borderColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    // if not using gradient border, return a simple container
    if (!useGradientBorder || useSolidBorder) {
      return Container(
        width: width,
        height: height,
        margin: margin,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: gradientColors ?? 
                  (isPrimary 
                    ? [
                        isDark ? const Color(0xFF303030) : Colors.white,
                        isDark ? const Color(0xFF252525) : const Color(0xFFF5F5F5),
                      ]
                    : [
                        isDark ? const Color(0xFF252525) : const Color(0xFFF5F5F5),
                        isDark ? const Color(0xFF303030) : Colors.white,
                      ]),
          ),
          borderRadius: BorderRadius.circular(borderRadius),
          boxShadow: boxShadow ?? [
            BoxShadow(
              color: isDark 
                ? Colors.black.withOpacity(0.3) 
                : Colors.grey.withOpacity(0.3),
              spreadRadius: 1,
              blurRadius: elevation,
              offset: const Offset(0, 2),
            ),
          ],
          border: useSolidBorder 
              ? (borderColor != null 
                  ? BorderStyles.getColoredBorder(borderColor!, width: borderWidth)
                  : BorderStyles.getThemedBorder(context))
              : Border.all(
                  color: Theme.of(context).dividerColor.withOpacity(0.3),
                  width: borderWidth,
                ),
        ),
        child: Padding(
          padding: padding,
          child: child,
        ),
      );
    }
    
    // For gradient border, use nested containers
    return Container(
      width: width,
      height: height,
      margin: margin,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: borderColors ?? 
            (isPrimary 
              ? [
                  isDark ? const Color(0xFF3E4DF0) : const Color(0xFF5E8FFC),
                  isDark ? const Color(0xFF818CF8) : const Color(0xFF5FFBF1),
                ] 
              : [
                  isDark ? const Color(0xFFE879F9) : const Color(0xFFFF5994),
                  isDark ? const Color(0xFF8B5CF6) : const Color(0xFFFF9B50),
                ]),
        ),
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: boxShadow ?? [
          BoxShadow(
            color: isDark 
              ? Colors.black.withOpacity(0.3) 
              : Colors.grey.withOpacity(0.3),
            spreadRadius: 1,
            blurRadius: elevation,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Container(
        margin: EdgeInsets.all(borderWidth),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: gradientColors ?? 
                  (isPrimary 
                    ? [
                        isDark ? const Color(0xFF303030) : Colors.white,
                        isDark ? const Color(0xFF252525) : const Color(0xFFF5F5F5),
                      ]
                    : [
                        isDark ? const Color(0xFF252525) : const Color(0xFFF5F5F5),
                        isDark ? const Color(0xFF303030) : Colors.white,
                      ]),
          ),
          borderRadius: BorderRadius.circular(borderRadius - borderWidth),
        ),
        padding: padding,
        child: child,
      ),
    );
  }
} 