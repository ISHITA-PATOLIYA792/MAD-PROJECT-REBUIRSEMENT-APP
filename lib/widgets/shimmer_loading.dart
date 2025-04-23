import 'package:flutter/material.dart';
import 'package:reimbursement_box/main.dart';
import 'package:reimbursement_box/utils/border_styles.dart';

class ShimmerLoading extends StatefulWidget {
  final Widget child;
  final bool isLoading;
  final bool useGradient;
  
  const ShimmerLoading({
    Key? key,
    required this.child,
    this.isLoading = true,
    this.useGradient = true,
  }) : super(key: key);

  @override
  State<ShimmerLoading> createState() => _ShimmerLoadingState();
}

class _ShimmerLoadingState extends State<ShimmerLoading> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();
    
    _animation = Tween<double>(begin: -2.0, end: 2.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOutSine),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isLoading) {
      return widget.child;
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return ShaderMask(
          blendMode: BlendMode.srcATop,
          shaderCallback: (bounds) {
            return widget.useGradient
                ? LinearGradient(
                    colors: isDark
                        ? [
                            Color(0xFF303050),
                            Color(0xFF5A5A80),
                            Color(0xFF303050),
                          ]
                        : [
                            Color(0xFFEEEEEE),
                            Color(0xFFFFFFFF),
                            Color(0xFFEEEEEE),
                          ],
                    stops: [0.0, 0.5, 1.0],
                    begin: Alignment(
                      _animation.value - 1.0,
                      0.0,
                    ),
                    end: Alignment(
                      _animation.value + 1.0,
                      0.0,
                    ),
                  ).createShader(bounds)
                : LinearGradient(
                    colors: isDark
                        ? [Color(0xFF252542), Color(0xFF353554)]
                        : [Color(0xFFE0E0E0), Color(0xFFF5F5F5)],
                    stops: [0.0, 1.0],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ).createShader(bounds);
          },
          child: widget.child,
        );
      },
    );
  }
}

class ShimmerPlaceholder extends StatelessWidget {
  final double width;
  final double height;
  final double borderRadius;
  final EdgeInsetsGeometry margin;
  final bool useBorder;
  
  const ShimmerPlaceholder({
    Key? key,
    required this.width,
    required this.height,
    this.borderRadius = 4.0,
    this.margin = EdgeInsets.zero,
    this.useBorder = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      margin: margin,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(borderRadius),
        border: useBorder ? BorderStyles.getThemedBorder(context) : null,
      ),
    );
  }
} 