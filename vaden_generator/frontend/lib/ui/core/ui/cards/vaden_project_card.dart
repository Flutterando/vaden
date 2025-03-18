import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../themes/colors.dart';
import '../images/vaden_images.dart';

enum ProjectVariant {
  gradle,
  marven,
}

class VadenProjectCard extends StatelessWidget {
  final String title;
  final ProjectVariant? variant;
  final Widget? customIcon;
  final bool isSelected;
  final VoidCallback? onTap;
  final double height;
  final double width;
  final BorderRadius? borderRadius;
  final EdgeInsets padding;
  final bool isEnabled;

  const VadenProjectCard({
    super.key,
    required this.title,
    this.variant,
    this.customIcon,
    this.isSelected = false,
    this.onTap,
    this.height = 56,
    this.width = double.infinity,
    this.borderRadius,
    this.padding = const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    this.isEnabled = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Lógica para determinar o ícone baseado na variante
    Widget? effectiveIcon = customIcon;
    if (variant != null && effectiveIcon == null) {
      switch (variant) {
        case ProjectVariant.gradle:
          effectiveIcon = Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: SvgPicture.asset(
              package: VadenImage.packageName,
              VadenImage.gradleIcon,
              height: 24,
              width: 24,
            ),
          );
          break;
        case ProjectVariant.marven:
          effectiveIcon = Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: SvgPicture.asset(
              package: VadenImage.packageName,
              VadenImage.marvenIcon,
              height: 24,
              width: 24,
            ),
          );
          break;
        default:
          break;
      }
    }

    final defaultBorderRadius = BorderRadius.circular(10);
    final effectiveBorderRadius = borderRadius ?? defaultBorderRadius;

    // Usar isSelected diretamente para determinar se está ativo
    final backgroundColor = VadenColors.backgroundColor2;

    // Texto fica com opacidade reduzida quando não selecionado
    final textColor = isSelected ? VadenColors.whiteColor : VadenColors.stkSupport2;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: height,
        width: width,
        padding: padding,
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: effectiveBorderRadius,
          border: Border.all(
            color: isSelected ? VadenColors.stkWhite : VadenColors.stkSupport2,
            width: 1,
          ),
        ),
        child: Row(
          children: [
            // Prefix icon
            if (effectiveIcon != null) effectiveIcon,

            // Title
            Expanded(
              child: Text(
                title,
                style: theme.textTheme.titleMedium?.copyWith(
                  color: textColor,
                  fontWeight: FontWeight.normal,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),

            // Selection indicator
            if (isSelected)
              Container(
                width: 24,
                height: 24,
                margin: const EdgeInsets.only(left: 8),
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: VadenColors.errorColor,
                ),
                child: const Icon(
                  Icons.adjust_rounded,
                  color: VadenColors.errorColor,
                  size: 16,
                ),
              )
            else
              Container(
                width: 24,
                height: 24,
                margin: const EdgeInsets.only(left: 8),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: VadenColors.supportColor2,
                    width: 1,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
