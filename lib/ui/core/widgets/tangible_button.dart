import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:match3/ui/core/utils/haptic_service.dart';
import 'package:match3/ui/providers.dart';

class TangibleButton extends ConsumerStatefulWidget {
  const TangibleButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isSecondary = false,
    this.height = 56,
    this.color,
    this.textColor,
    this.borderColor,
  });

  final String text;
  final VoidCallback? onPressed;
  final bool isSecondary;
  final double height;
  final Color? color;
  final Color? textColor;
  final Color? borderColor;

  @override
  ConsumerState<TangibleButton> createState() => _TangibleButtonState();
}

class _TangibleButtonState extends ConsumerState<TangibleButton> with SingleTickerProviderStateMixin {
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
      HapticService.lightImpact();
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
    final theme = ref.watch(activeThemeSkinProvider);

    final List<Color> gradientColors = widget.color != null
        ? [widget.color!.withValues(alpha: 0.88), widget.color!]
        : (widget.isSecondary
            ? [theme.cardBg, theme.surfaceDark]
            : [theme.primaryAccent.withValues(alpha: 0.88), theme.primaryAccent]);

    final Color strokeColor = widget.borderColor ??
        (widget.color != null
            ? widget.color!.withValues(alpha: 0.6)
            : (widget.isSecondary
                ? theme.cardBorder
                : theme.primaryAccent.withValues(alpha: 0.6)));

    final Color effectiveTextColor = widget.textColor ??
        (widget.color != null
            ? (widget.color!.computeLuminance() > 0.5 ? const Color(0xFF1A1A1A) : Colors.white)
            : (widget.isSecondary
                ? theme.textPrimary
                : (theme.primaryAccent.computeLuminance() > 0.5 ? const Color(0xFF1A1A1A) : Colors.white)));

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
              opacity: isInteractive ? 1.0 : 0.5,
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
                      color: Colors.black.withValues(alpha: 0.4),
                      offset: Offset(0, _isPressed ? 1 : 4),
                      blurRadius: _isPressed ? 2 : 8,
                    ),
                  ],
                ),
                alignment: Alignment.center,
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    widget.text.toUpperCase(),
                    style: TextStyle(
                      fontFamily: 'BebasNeue',
                      color: effectiveTextColor,
                      fontSize: 19,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 2.0,
                      shadows: widget.isSecondary
                          ? const [
                              Shadow(
                                offset: Offset(0, 1.5),
                                blurRadius: 2.0,
                                color: Colors.black54,
                              ),
                            ]
                          : null,
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
