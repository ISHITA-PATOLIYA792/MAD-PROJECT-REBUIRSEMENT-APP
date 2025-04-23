import 'package:flutter/material.dart';
import 'package:reimbursement_box/main.dart';
import 'package:reimbursement_box/utils/border_styles.dart';

class GradientButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final String text;
  final IconData? icon;
  final double height;
  final double? width;
  final double borderRadius;
  final EdgeInsetsGeometry padding;
  final bool isPrimary;
  final bool useBorder;
  final Color? borderColor;
  
  const GradientButton({
    Key? key,
    required this.text,
    this.onPressed,
    this.icon,
    this.height = 50.0,
    this.width,
    this.borderRadius = 12.0,
    this.padding = const EdgeInsets.symmetric(horizontal: 24, vertical: 0),
    this.isPrimary = true,
    this.useBorder = true,
    this.borderColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final LinearGradient gradient = isPrimary
        ? (isDark ? darkPrimaryGradient : lightPrimaryGradient)
        : (isDark ? darkSecondaryGradient : lightSecondaryGradient);
    
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(borderRadius),
        child: Ink(
          height: height,
          width: width,
          padding: padding,
          decoration: BoxDecoration(
            gradient: onPressed != null ? gradient : LinearGradient(
              colors: [Colors.grey.shade400, Colors.grey.shade500],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(borderRadius),
            boxShadow: onPressed != null ? [
              BoxShadow(
                color: gradient.colors.first.withOpacity(0.3),
                blurRadius: 8,
                offset: Offset(0, 3),
                spreadRadius: 1,
              )
            ] : null,
            border: useBorder 
                ? (borderColor != null 
                    ? BorderStyles.getColoredBorder(borderColor!) 
                    : (onPressed != null 
                        ? BorderStyles.getColoredBorder(gradient.colors.first.withOpacity(0.5)) 
                        : BorderStyles.getColoredBorder(Colors.grey.withOpacity(0.5))))
                : null,
          ),
          child: Center(
            child: Row(
              mainAxisSize: width != null ? MainAxisSize.max : MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (icon != null) ...[
                  Icon(
                    icon,
                    color: Colors.white,
                    size: 20,
                  ),
                  SizedBox(width: 8),
                ],
                Text(
                  text,
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
} 