import 'package:flutter/material.dart';
import 'package:reimbursement_box/main.dart';
import 'package:reimbursement_box/utils/border_styles.dart';

class AnimatedThemeToggle extends StatelessWidget {
  final double size;
  final bool useBorder;
  
  const AnimatedThemeToggle({
    Key? key,
    this.size = 40.0,
    this.useBorder = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeNotifier,
      builder: (_, ThemeMode currentMode, __) {
        final isLight = currentMode == ThemeMode.light;
        
        return GestureDetector(
          onTap: () {
            themeNotifier.value = isLight ? ThemeMode.dark : ThemeMode.light;
          },
          child: Container(
            height: size,
            width: size,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(size / 2),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: isLight
                    ? [Color(0xFF4A6FFF), Color(0xFF7A54FF)]
                    : [Color(0xFF2A3F8A), Color(0xFF6649B8)],
              ),
              boxShadow: [
                BoxShadow(
                  color: isLight
                      ? Color(0xFF4A6FFF).withOpacity(0.3)
                      : Color(0xFF6649B8).withOpacity(0.5),
                  blurRadius: 12,
                  spreadRadius: 2,
                  offset: Offset(0, 3),
                )
              ],
              border: useBorder 
                  ? BorderStyles.getColoredBorder(
                      isLight 
                        ? Color(0xFF4A6FFF).withOpacity(0.5)
                        : Color(0xFF6649B8).withOpacity(0.7))
                  : null,
            ),
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 400),
              reverseDuration: const Duration(milliseconds: 300),
              switchInCurve: Curves.easeOutBack,
              switchOutCurve: Curves.easeInCirc,
              transitionBuilder: (Widget child, Animation<double> animation) {
                return RotationTransition(
                  turns: Tween<double>(begin: 0.5, end: 1.0).animate(animation),
                  child: ScaleTransition(
                    scale: animation,
                    child: FadeTransition(
                      opacity: animation,
                      child: child,
                    ),
                  ),
                );
              },
              child: isLight
                  ? Icon(
                      Icons.light_mode_rounded,
                      key: const ValueKey('light'),
                      color: Colors.white,
                      size: size * 0.6,
                    )
                  : Icon(
                      Icons.dark_mode_rounded,
                      key: const ValueKey('dark'),
                      color: Colors.white,
                      size: size * 0.6,
                    ),
            ),
          ),
        );
      },
    );
  }
} 