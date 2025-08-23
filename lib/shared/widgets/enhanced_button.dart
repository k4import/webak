import 'package:flutter/material.dart';
import 'package:webak/core/theme/app_theme.dart';
import 'package:webak/core/theme/app_colors.dart';
import 'package:webak/core/theme/app_animations.dart';

/// زر محسن مع رسوم متحركة وتصميم حديث
class EnhancedButton extends StatefulWidget {
  final String text;
  final VoidCallback? onPressed;
  final IconData? icon;
  final Color? backgroundColor;
  final Color? textColor;
  final Color? iconColor;
  final double? width;
  final double? height;
  final bool isLoading;
  final bool isFullWidth;
  final EnhancedButtonType type;
  final EnhancedButtonSize size;
  final Widget? child;

  const EnhancedButton({
    super.key,
    required this.text,
    this.onPressed,
    this.icon,
    this.backgroundColor,
    this.textColor,
    this.iconColor,
    this.width,
    this.height,
    this.isLoading = false,
    this.isFullWidth = false,
    this.type = EnhancedButtonType.primary,
    this.size = EnhancedButtonSize.medium,
    this.child,
  });

  const EnhancedButton.primary({
    super.key,
    required this.text,
    this.onPressed,
    this.icon,
    this.width,
    this.height,
    this.isLoading = false,
    this.isFullWidth = false,
    this.size = EnhancedButtonSize.medium,
    this.child,
  }) : type = EnhancedButtonType.primary,
       backgroundColor = null,
       textColor = null,
       iconColor = null;

  const EnhancedButton.secondary({
    super.key,
    required this.text,
    this.onPressed,
    this.icon,
    this.width,
    this.height,
    this.isLoading = false,
    this.isFullWidth = false,
    this.size = EnhancedButtonSize.medium,
    this.child,
  }) : type = EnhancedButtonType.secondary,
       backgroundColor = null,
       textColor = null,
       iconColor = null;

  const EnhancedButton.outline({
    super.key,
    required this.text,
    this.onPressed,
    this.icon,
    this.width,
    this.height,
    this.isLoading = false,
    this.isFullWidth = false,
    this.size = EnhancedButtonSize.medium,
    this.child,
  }) : type = EnhancedButtonType.outline,
       backgroundColor = null,
       textColor = null,
       iconColor = null;

  const EnhancedButton.text({
    super.key,
    required this.text,
    this.onPressed,
    this.icon,
    this.width,
    this.height,
    this.isLoading = false,
    this.isFullWidth = false,
    this.size = EnhancedButtonSize.medium,
    this.child,
  }) : type = EnhancedButtonType.text,
       backgroundColor = null,
       textColor = null,
       iconColor = null;

  @override
  State<EnhancedButton> createState() => _EnhancedButtonState();
}

class _EnhancedButtonState extends State<EnhancedButton>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: AppAnimations.fast,
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: AppAnimations.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    if (widget.onPressed != null && !widget.isLoading) {
      setState(() => _isPressed = true);
      _animationController.forward();
    }
  }

  void _handleTapUp(TapUpDetails details) {
    _resetAnimation();
  }

  void _handleTapCancel() {
    _resetAnimation();
  }

  void _resetAnimation() {
    setState(() => _isPressed = false);
    _animationController.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final buttonStyle = _getButtonStyle(theme);
    final textStyle = _getTextStyle(theme);
    final buttonSize = _getButtonSize();

    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: GestureDetector(
            onTapDown: _handleTapDown,
            onTapUp: _handleTapUp,
            onTapCancel: _handleTapCancel,
            child: Container(
              width: widget.isFullWidth ? double.infinity : widget.width,
              height: widget.height ?? buttonSize.height,
              decoration: buttonStyle.decoration,
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: widget.isLoading ? null : widget.onPressed,
                  borderRadius: BorderRadius.circular(AppTheme.borderRadius),
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: buttonSize.horizontalPadding,
                      vertical: buttonSize.verticalPadding,
                    ),
                    child: _buildContent(textStyle),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildContent(TextStyle textStyle) {
    if (widget.isLoading) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(
                textStyle.color ?? Colors.white,
              ),
            ),
          ),
          const SizedBox(width: AppTheme.sm),
          Text(
            'جاري التحميل...',
            style: textStyle,
          ),
        ],
      );
    }

    if (widget.child != null) {
      return widget.child!;
    }

    if (widget.icon != null) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            widget.icon,
            color: widget.iconColor ?? textStyle.color,
            size: _getButtonSize().iconSize,
          ),
          const SizedBox(width: AppTheme.sm),
          Text(
            widget.text,
            style: textStyle,
          ),
        ],
      );
    }

    return Text(
      widget.text,
      style: textStyle,
      textAlign: TextAlign.center,
    );
  }

  _ButtonStyle _getButtonStyle(ThemeData theme) {
    switch (widget.type) {
      case EnhancedButtonType.primary:
        return _ButtonStyle(
          decoration: BoxDecoration(
            color: widget.backgroundColor ?? Theme.of(context).primaryColor,
            borderRadius: BorderRadius.circular(AppTheme.borderRadius),
            boxShadow: [
              BoxShadow(
                color: (widget.backgroundColor ?? AppColors.primaryGreen)
                    .withOpacity(0.3),
                blurRadius: AppTheme.elevationLow,
                offset: const Offset(0, 2),
              ),
            ],
          ),
        );
      
      case EnhancedButtonType.secondary:
        return _ButtonStyle(
          decoration: BoxDecoration(
            color: widget.backgroundColor ?? AppColors.primaryOrange,
            borderRadius: BorderRadius.circular(AppTheme.borderRadius),
            boxShadow: [
              BoxShadow(
                color: (widget.backgroundColor ?? AppColors.primaryOrange)
                    .withOpacity(0.3),
                blurRadius: AppTheme.elevationLow,
                offset: const Offset(0, 2),
              ),
            ],
          ),
        );
      
      case EnhancedButtonType.outline:
        return _ButtonStyle(
          decoration: BoxDecoration(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(AppTheme.borderRadius),
            border: Border.all(
              color: widget.backgroundColor ?? AppColors.primaryGreen,
              width: 1.5,
            ),
          ),
        );
      
      case EnhancedButtonType.text:
        return _ButtonStyle(
          decoration: BoxDecoration(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(AppTheme.borderRadius),
          ),
        );
    }
  }

  TextStyle _getTextStyle(ThemeData theme) {
    Color textColor;
    
    switch (widget.type) {
      case EnhancedButtonType.primary:
      case EnhancedButtonType.secondary:
        textColor = widget.textColor ?? Colors.white;
        break;
      case EnhancedButtonType.outline:
        textColor = widget.textColor ?? 
                   widget.backgroundColor ?? 
                   AppColors.primaryGreen;
        break;
      case EnhancedButtonType.text:
        textColor = widget.textColor ?? 
                   widget.backgroundColor ?? 
                   AppColors.primaryGreen;
        break;
    }

    return AppTheme.button.copyWith(
      color: textColor,
      fontSize: _getButtonSize().fontSize,
    );
  }

  _ButtonSize _getButtonSize() {
    switch (widget.size) {
      case EnhancedButtonSize.small:
        return _ButtonSize(
          height: 36,
          horizontalPadding: AppTheme.lg,
          verticalPadding: AppTheme.sm,
          fontSize: 12,
          iconSize: 16,
        );
      case EnhancedButtonSize.medium:
        return _ButtonSize(
          height: 48,
          horizontalPadding: AppTheme.xl,
          verticalPadding: AppTheme.lg,
          fontSize: 14,
          iconSize: 18,
        );
      case EnhancedButtonSize.large:
        return _ButtonSize(
          height: 56,
          horizontalPadding: AppTheme.xxl,
          verticalPadding: AppTheme.xl,
          fontSize: 16,
          iconSize: 20,
        );
    }
  }
}

class _ButtonStyle {
  final BoxDecoration decoration;

  _ButtonStyle({required this.decoration});
}

class _ButtonSize {
  final double height;
  final double horizontalPadding;
  final double verticalPadding;
  final double fontSize;
  final double iconSize;

  _ButtonSize({
    required this.height,
    required this.horizontalPadding,
    required this.verticalPadding,
    required this.fontSize,
    required this.iconSize,
  });
}

enum EnhancedButtonType {
  primary,
  secondary,
  outline,
  text,
}

enum EnhancedButtonSize {
  small,
  medium,
  large,
}