import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class TangibleButton extends StatefulWidget {
  const TangibleButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isSecondary = false,
    this.height = 56,
  });

  final String text;
  final VoidCallback? onPressed;
  final bool isSecondary;
  final double height;

  @override
  State<TangibleButton> createState() => _TangibleButtonState();
}

class _TangibleButtonState extends State<TangibleButton> with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 60),
      lowerBound: 0.92,
      upperBound: 1.0,
      value: 1.0,
    );
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails _) {
    if (widget.onPressed != null) {
      setState(() => _isPressed = true);
      _animController.reverse();
      HapticFeedback.lightImpact().catchError((_) {});
    }
  }

  void _handleTapUp(TapUpDetails _) {
    if (widget.onPressed != null) {
      setState(() => _isPressed = false);
      _animController.forward();
      widget.onPressed!();
    }
  }

  void _handleTapCancel() {
    if (widget.onPressed != null) {
      setState(() => _isPressed = false);
      _animController.forward();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isInteractive = widget.onPressed != null;

    final List<Color> gradientColors = widget.isSecondary
        ? [const Color(0xFF5C68D4), const Color(0xFF3E49B4)]
        : [const Color(0xFFFFDF6D), const Color(0xFFFFCE31)];

    final Color strokeColor = widget.isSecondary
        ? const Color(0xFF8692FF)
        : const Color(0xFFFFF2A3);

    return GestureDetector(
      onTapDown: _handleTapDown,
      onTapUp: _handleTapUp,
      onTapCancel: _handleTapCancel,
      child: AnimatedBuilder(
        animation: _animController,
        builder: (context, child) {
          return Transform.scale(
            scale: _animController.value,
            child: Opacity(
              opacity: isInteractive ? 1.0 : 0.6,
              child: Container(
                height: widget.height,
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: gradientColors,
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: strokeColor,
                    width: 2.0,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.2),
                      offset: Offset(0, _isPressed ? 1 : 4),
                      blurRadius: _isPressed ? 2 : 6,
                    ),
                  ],
                ),
                alignment: Alignment.center,
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    widget.text.toUpperCase(),
                    style: const TextStyle(
                      fontFamily: 'BebasNeue',
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 2.0,
                      shadows: [
                        Shadow(
                          offset: Offset(0, 2),
                          blurRadius: 2.0,
                          color: Colors.black54,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
