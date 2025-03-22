import 'package:flutter/material.dart';

import '../../themes/colors.dart';

enum VadenButtonStyle {
  filled, // Botão com fundo preenchido
  outlined, // Botão apenas com borda
  text // Botão somente texto sem fundo
}

enum VadenButtonState {
  normal, // Estado normal
  loading, // Estado de carregamento
  disabled // Estado desabilitado
}

enum VadenButtonColor {
  primary, // Cor primária (vermelho)
  secondary, // Cor secundária (cinza)
  transparent, // Sem cor de fundo
  gradient, // Cor de gradient
  custom // Cor personalizada
}

enum VadenTextStyle {
  normal, // Texto normal
  gradient, // Texto com gradiente
  custom // Estilo personalizado
}

class VadenButton extends StatelessWidget {
  final String title;
  final VoidCallback? onPressed;
  final IconData? icon;
  final double height;
  final double width;
  final double borderRadius;
  final VadenButtonStyle style;
  final VadenButtonState state;
  final VadenButtonColor color;
  final VadenTextStyle textStyle;
  final TextStyle? titleTextStyle;
  final bool centerText;

  // Personalizações avançadas
  final Color? customBackgroundColor;
  final Color? customForegroundColor;
  final Color? customBorderColor;
  final double borderWidth;
  final Gradient? customBackgroundGradient;
  final Gradient? customTextGradient;
  final Color? iconColor;
  final double iconSize;

  const VadenButton({
    super.key,
    required this.title,
    required this.onPressed,
    this.icon = Icons.arrow_forward_rounded,
    this.height = 56,
    this.width = double.infinity,
    this.borderRadius = 10,
    this.style = VadenButtonStyle.filled,
    this.state = VadenButtonState.normal,
    this.color = VadenButtonColor.primary,
    this.textStyle = VadenTextStyle.normal,
    this.titleTextStyle,
    this.centerText = true,
    this.customBackgroundColor,
    this.customForegroundColor,
    this.customBorderColor,
    this.borderWidth = 1,
    this.customBackgroundGradient,
    this.customTextGradient,
    this.iconColor,
    this.iconSize = 24,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final isDisabled = state == VadenButtonState.disabled || onPressed == null;

    Color backgroundColor;
    Color foregroundColor;
    Color borderColor;
    Gradient? backgroundGradient;
    Gradient? textGradient;

    // Definir cores de acordo com o estilo e cor escolhida
    if (style == VadenButtonStyle.filled) {
      if (color == VadenButtonColor.primary) {
        backgroundColor = isDisabled ? VadenColors.greyColor : VadenColors.errorColor;
        foregroundColor = VadenColors.whiteColor;
        borderColor = Colors.transparent;
      } else if (color == VadenButtonColor.secondary) {
        backgroundColor = isDisabled ? VadenColors.greyColor : VadenColors.whiteColor;
        foregroundColor = isDisabled ? VadenColors.greyColor : VadenColors.errorColor;
        borderColor = Colors.transparent;
      } else if (color == VadenButtonColor.gradient) {
        backgroundColor = Colors.transparent;
        foregroundColor = VadenColors.whiteColor;
        borderColor = Colors.transparent;
        backgroundGradient = const LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [
            VadenColors.gradientStart,
            VadenColors.gradientEnd,
          ],
        );
      } else if (color == VadenButtonColor.custom && customBackgroundColor != null) {
        backgroundColor = customBackgroundColor!;
        foregroundColor = customForegroundColor ?? VadenColors.whiteColor;
        borderColor = customBorderColor ?? Colors.transparent;
        backgroundGradient = customBackgroundGradient;
      } else {
        backgroundColor = Colors.transparent;
        foregroundColor = isDisabled ? VadenColors.greyColor : VadenColors.errorColor;
        borderColor = Colors.transparent;
      }
    } else if (style == VadenButtonStyle.outlined) {
      backgroundColor = Colors.transparent;

      // Lógica para a cor do texto
      if (color == VadenButtonColor.custom && customForegroundColor != null) {
        foregroundColor = isDisabled ? VadenColors.greyColor : customForegroundColor!;
      } else {
        foregroundColor = isDisabled
            ? VadenColors.greyColor
            : (color == VadenButtonColor.primary ? VadenColors.errorColor : VadenColors.whiteColor);
      }

      // Lógica para a cor da borda
      if (color == VadenButtonColor.custom && customBorderColor != null) {
        borderColor = isDisabled ? VadenColors.greyColor : customBorderColor!;
      } else if (color == VadenButtonColor.custom && customForegroundColor != null) {
        borderColor = isDisabled ? VadenColors.greyColor : customForegroundColor!;
      } else {
        borderColor = isDisabled
            ? VadenColors.greyColor
            : (color == VadenButtonColor.primary ? VadenColors.errorColor : VadenColors.whiteColor);
      }
    } else {
      backgroundColor = Colors.transparent;
      if (color == VadenButtonColor.custom && customForegroundColor != null) {
        foregroundColor = isDisabled ? VadenColors.greyColor : customForegroundColor!;
      } else {
        foregroundColor = isDisabled
            ? VadenColors.greyColor
            : (color == VadenButtonColor.primary ? VadenColors.errorColor : VadenColors.whiteColor);
      }
      borderColor = Colors.transparent;
    }

    // Configura gradiente de texto
    if (textStyle == VadenTextStyle.gradient && !isDisabled) {
      textGradient = customTextGradient ??
          const LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: [
              VadenColors.gradientStart,
              VadenColors.gradientEnd,
            ],
          );
    }

    // Cor final do ícone
    final effectiveIconColor = iconColor ?? foregroundColor;

    // Determina se usa gradiente de fundo
    final useBackgroundGradient = backgroundGradient != null && !isDisabled;

    // Widget do botão principal
    Widget buttonWidget;

    // Conteúdo do botão (texto, ícone)
    Widget contentWidget = state == VadenButtonState.loading
        ? _buildLoadingContent(foregroundColor, effectiveIconColor)
        : _buildNormalContent(theme, foregroundColor, effectiveIconColor, textGradient);

    // Cria o botão base
    buttonWidget = ElevatedButton(
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
        fixedSize: Size(width, height),
        backgroundColor: useBackgroundGradient ? Colors.transparent : backgroundColor,
        foregroundColor: foregroundColor,
        textStyle: titleTextStyle ?? theme.textTheme.bodyLarge,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadius),
          side: style == VadenButtonStyle.outlined
              ? BorderSide(color: borderColor, width: borderWidth)
              : BorderSide.none,
        ),
        elevation: 0,
        shadowColor: Colors.transparent,
      ),
      onPressed: isDisabled ? null : onPressed,
      child: contentWidget,
    );

    // Se tem gradiente de fundo, envolve com Container
    if (useBackgroundGradient) {
      return Container(
        height: height,
        width: width,
        decoration: BoxDecoration(
          gradient: backgroundGradient,
          borderRadius: BorderRadius.circular(borderRadius),
        ),
        child: buttonWidget,
      );
    }

    return buttonWidget;
  }

  Widget _buildNormalContent(
    ThemeData theme,
    Color foregroundColor,
    Color iconColor,
    Gradient? textGradient,
  ) {
    // Criar texto com ou sem gradiente
    Widget textWidget;
    if (textGradient != null) {
      textWidget = ShaderMask(
        shaderCallback: (bounds) => textGradient.createShader(bounds),
        child: Text(
          title,
          style: titleTextStyle ??
              theme.textTheme.bodyLarge?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
        ),
      );
    } else {
      textWidget = Text(
        title,
        style: titleTextStyle ??
            theme.textTheme.bodyLarge?.copyWith(
              color: foregroundColor,
              fontWeight: FontWeight.bold,
            ),
      );
    }

    // Se não tiver ícone, apenas centraliza o texto
    if (icon == null) {
      return Center(
        child: textWidget,
      );
    }

    // Criar ícone com ou sem gradiente
    Widget iconWidget;
    if (textGradient != null) {
      iconWidget = ShaderMask(
        shaderCallback: (bounds) => textGradient.createShader(bounds),
        child: Icon(
          icon,
          size: iconSize,
          color: Colors.white,
        ),
      );
    } else {
      iconWidget = Icon(
        icon,
        size: iconSize,
        color: iconColor,
      );
    }

    // Se tiver ícone, usa o layout original com Row
    return Row(
      mainAxisAlignment: centerText ? MainAxisAlignment.center : MainAxisAlignment.spaceBetween,
      children: [
        if (centerText) const Spacer(),
        textWidget,
        if (centerText) const Spacer(),
        if (!centerText)
          iconWidget
        else
          Padding(
            padding: const EdgeInsets.only(left: 8.0),
            child: iconWidget,
          ),
      ],
    );
  }

  Widget _buildLoadingContent(Color foregroundColor, Color iconColor) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Spacer(),
        SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(foregroundColor),
          ),
        ),
        const Spacer(),
        if (icon != null)
          Icon(
            icon,
            size: iconSize,
            color: iconColor,
          ),
      ],
    );
  }
}

// Factory construtores para facilitar a criação das variações
extension VadenButtonExtension on VadenButton {
  // Botão vermelho padrão com gradiente
  static VadenButton primary({
    required String title,
    required VoidCallback onPressed,
    IconData? icon = Icons.arrow_forward_rounded,
    double height = 56,
    double width = double.infinity,
    bool isLoading = false,
    bool isDisabled = false,
  }) {
    return VadenButton(
      title: title,
      onPressed: isDisabled ? null : onPressed,
      icon: icon,
      height: height,
      width: width,
      style: VadenButtonStyle.filled,
      state: isLoading
          ? VadenButtonState.loading
          : isDisabled
              ? VadenButtonState.disabled
              : VadenButtonState.normal,
      color: VadenButtonColor.gradient,
      centerText: true,
      textStyle: VadenTextStyle.normal,
    );
  }

  // Botão cinza desabilitado
  static VadenButton disabled({
    required String title,
    IconData? icon = Icons.arrow_forward_rounded,
    double height = 56,
    double width = double.infinity,
  }) {
    return VadenButton(
      title: title,
      onPressed: null,
      icon: icon,
      height: height,
      width: width,
      style: VadenButtonStyle.filled,
      state: VadenButtonState.disabled,
      color: VadenButtonColor.secondary,
    );
  }

  // Botão com borda
  static VadenButton outlined({
    required String title,
    required VoidCallback onPressed,
    IconData? icon = Icons.arrow_forward_rounded,
    double height = 56,
    double width = double.infinity,
    bool isLoading = false,
    bool isDisabled = false,
    Color? borderColor,
    Color? textColor,
    double borderWidth = 1,
  }) {
    final useCustomColor = borderColor != null;

    return VadenButton(
      title: title,
      onPressed: isDisabled ? null : onPressed,
      icon: icon,
      height: height,
      width: width,
      style: VadenButtonStyle.outlined,
      state: isLoading
          ? VadenButtonState.loading
          : isDisabled
              ? VadenButtonState.disabled
              : VadenButtonState.normal,
      color: useCustomColor ? VadenButtonColor.custom : VadenButtonColor.primary,
      customBorderColor: borderColor,
      customForegroundColor: textColor,
      borderWidth: borderWidth,
    );
  }

  // Botão texto sem fundo
  static VadenButton text({
    required String title,
    required VoidCallback onPressed,
    IconData? icon = Icons.arrow_forward_rounded,
    double height = 56,
    double width = double.infinity,
    bool isDisabled = false,
    bool isLoading = false,
    VadenTextStyle textStyle = VadenTextStyle.normal,
    Gradient? textGradient,
  }) {
    return VadenButton(
      title: title,
      onPressed: isDisabled ? null : onPressed,
      icon: icon,
      height: height,
      width: width,
      style: VadenButtonStyle.text,
      textStyle: textStyle,
      customTextGradient: textGradient,
      state: isLoading
          ? VadenButtonState.loading
          : isDisabled
              ? VadenButtonState.disabled
              : VadenButtonState.normal,
      color: VadenButtonColor.primary,
    );
  }

  // Botão totalmente personalizado
  static VadenButton custom({
    required String title,
    required VoidCallback onPressed,
    IconData? icon,
    double height = 56,
    double width = double.infinity,
    double borderRadius = 10,
    VadenButtonStyle style = VadenButtonStyle.filled,
    bool isLoading = false,
    bool isDisabled = false,
    bool centerText = true,

    // Personalizações
    Color backgroundColor = Colors.transparent,
    Color? textColor,
    Color borderColor = Colors.transparent,
    double borderWidth = 1,
    Gradient? backgroundGradient,
    VadenTextStyle textStyle = VadenTextStyle.normal,
    Gradient? textGradient,
    Color? iconColor,
    double iconSize = 24,
  }) {
    // Se for estilo outlined, garantir que o fundo é transparente
    final effectiveBackgroundColor = style == VadenButtonStyle.outlined //
        ? Colors.transparent //
        : backgroundColor;

    // Para outlined, se textColor for não nulo, usar textColor como borderColor
    final effectiveBorderColor =
        style == VadenButtonStyle.outlined && textColor != null //
        ? textColor //
        : borderColor;

    return VadenButton(
      title: title,
      onPressed: isDisabled ? null : onPressed,
      icon: icon,
      height: height,
      width: width,
      borderRadius: borderRadius,
      style: style,
      state: isLoading
          ? VadenButtonState.loading
          : isDisabled
              ? VadenButtonState.disabled
              : VadenButtonState.normal,
      color: VadenButtonColor.custom,
      textStyle: textStyle,
      centerText: centerText,
      customBackgroundColor: effectiveBackgroundColor,
      customForegroundColor: textColor,
      customBorderColor: effectiveBorderColor,
      borderWidth: borderWidth,
      customBackgroundGradient: backgroundGradient,
      customTextGradient: textGradient,
      iconColor: iconColor,
      iconSize: iconSize,
    );
  }

  // Botão com texto e ícone gradientes
  static VadenButton gradientText({
    required String title,
    required VoidCallback onPressed,
    IconData? icon = Icons.arrow_forward_rounded,
    double height = 56,
    double width = double.infinity,
    Color backgroundColor = Colors.transparent,
    VadenButtonStyle style = VadenButtonStyle.text,
    Gradient? textGradient,
    bool isLoading = false,
    bool isDisabled = false,
  }) {
    return VadenButton(
      title: title,
      onPressed: isDisabled ? null : onPressed,
      icon: icon,
      height: height,
      width: width,
      style: style,
      textStyle: VadenTextStyle.gradient,
      customTextGradient: textGradient,
      state: isLoading
          ? VadenButtonState.loading
          : isDisabled
              ? VadenButtonState.disabled
              : VadenButtonState.normal,
      color:
          style == VadenButtonStyle.filled ? VadenButtonColor.custom : VadenButtonColor.transparent,
      customBackgroundColor: backgroundColor,
    );
  }
}
