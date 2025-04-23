import 'package:flutter/material.dart';
import 'package:reimbursement_box/main.dart';

class AnimatedThemeToggle extends StatelessWidget {
  final double size;
  
  const AnimatedThemeToggle({
    Key? key,
    this.size = 40.0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeNotifier,
      builder: (context, mode, child) {
        final isDark = mode == ThemeMode.dark;
        
        return InkWell(
          borderRadius: BorderRadius.circular(size / 2),
          onTap: () {
            themeNotifier.value = isDark ? ThemeMode.light : ThemeMode.dark;
          },
          child: Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(size / 2),
              gradient: isDark ? darkPrimaryGradient : lightPrimaryGradient,
              boxShadow: [
                BoxShadow(
                  color: isDark 
                    ? Colors.black.withOpacity(0.3) 
                    : Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: AnimatedCrossFade(
              firstChild: Center(
                child: Icon(
                  Icons.dark_mode_rounded,
                  color: Colors.white,
                  size: size * 0.6,
                ),
              ),
              secondChild: Center(
                child: Icon(
                  Icons.light_mode_rounded,
                  color: Colors.black87,
                  size: size * 0.6,
                ),
              ),
              crossFadeState: 
                isDark ? CrossFadeState.showFirst : CrossFadeState.showSecond,
              duration: const Duration(milliseconds: 300),
            ),
          ),
        );
      },
    );
  }
} 