import 'package:flutter/material.dart';

import '../../themes/colors.dart';

enum VadenButtonStyle {
  filled,
  critical,
  outlined,
  outlinedWhite,
  text,
  white;

  Gradient? getBackgroundGradient() {
    return switch (this) {
      VadenButtonStyle.filled => LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [
            VadenColors.gradientStart,
            VadenColors.gradientEnd,
          ],
        ),
      _ => null,
    };
  }

  Gradient? getTextGradient() {
    return switch (this) {
      VadenButtonStyle.outlined => LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [
            VadenColors.gradientStart,
            VadenColors.gradientEnd,
          ],
        ),
      VadenButtonStyle.text => LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [
            VadenColors.gradientStart,
            VadenColors.gradientEnd,
          ],
        ),
      VadenButtonStyle.white => LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [
            VadenColors.gradientStart,
            VadenColors.gradientEnd,
          ],
        ),
      _ => null,
    };
  }

  Color getBackgroundColor() {
    return switch (this) {
      VadenButtonStyle.filled => Colors.transparent,
      VadenButtonStyle.critical => VadenColors.errorColor,
      VadenButtonStyle.outlined => Colors.transparent,
      VadenButtonStyle.outlinedWhite => Colors.transparent,
      VadenButtonStyle.text => Colors.transparent,
      VadenButtonStyle.white => VadenColors.whiteColor,
    };
  }

  Color? getForegroundColor() {
    return switch (this) {
      VadenButtonStyle.filled => VadenColors.whiteColor,
      VadenButtonStyle.critical => VadenColors.whiteColor,
      VadenButtonStyle.outlined => null,
      VadenButtonStyle.outlinedWhite => VadenColors.whiteColor,
      VadenButtonStyle.text => null,
      VadenButtonStyle.white => null,
    };
  }

  Color getBorderColor() {
    return switch (this) {
      VadenButtonStyle.outlined => VadenColors.errorColor,
      VadenButtonStyle.outlinedWhite => VadenColors.whiteColor,
      _ => Colors.transparent,
    };
  }

  Color getDisabledColor() {
    return switch (this) {
      _ => VadenColors.disabledColor2,
    };
  }

  Color getDisabledForegroundColor() {
    return switch (this) {
      _ => VadenColors.whiteColor,
    };
  }
}

class VadenButton extends StatelessWidget {
  final String? label;
  final VoidCallback? onPressed;
  final VadenButtonStyle style;
  final bool disabled;
  final bool isLoading;
  final IconData? prefixIcon;
  final IconData? suffixIcon;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry? padding;
  const VadenButton({
    super.key,
    this.label,
    this.onPressed,
    this.style = VadenButtonStyle.filled,
    this.disabled = false,
    this.isLoading = false,
    this.prefixIcon,
    this.suffixIcon,
    this.width,
    this.height,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final double borderRadius = 8;
    return Container(
      height: height ?? 48,
      constraints: BoxConstraints(maxWidth: width ?? double.infinity),
      decoration: BoxDecoration(
        gradient: style.getBackgroundGradient(),
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      child: ElevatedButton(
        onPressed: disabled ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: style.getBackgroundColor(),
          foregroundColor: style.getForegroundColor(),
          disabledBackgroundColor: style.getDisabledColor(),
          disabledForegroundColor: style.getDisabledForegroundColor(),
          elevation: 0,
          padding: padding ?? const EdgeInsets.symmetric(horizontal: 24),
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius),
            side: BorderSide(color: style.getBorderColor(), width: 0.5),
          ),
        ),
        child: isLoading
            ? Center(
                child: SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(style.getDisabledForegroundColor()),
                  ),
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  prefixIcon == null
                      ? SizedBox()
                      : Icon(
                          prefixIcon,
                          size: 24,
                          color: style.getForegroundColor(),
                        ),
                  label == null ? const SizedBox() : lebelText(context),
                  suffixIcon == null
                      ? SizedBox()
                      : Icon(
                          suffixIcon,
                          size: 24,
                          color: style.getForegroundColor(),
                        ),
                ],
              ),
      ),
    );
  }

  Widget lebelText(BuildContext context) {
    final theme = Theme.of(context);
    final Gradient? textGradient = style.getTextGradient();

    if (textGradient != null) {
      return ShaderMask(
        shaderCallback: (bounds) => textGradient.createShader(bounds),
        child: Text(
          label!,
          style: theme.textTheme.bodyLarge?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      );
    }

    return Text(
      label!,
      style: theme.textTheme.bodyLarge?.copyWith(
        color: style.getForegroundColor(),
        fontWeight: FontWeight.bold,
      ),
    );
  }
}
