import 'package:flutter/material.dart';

import '../../themes/colors.dart';

class VadenCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String? tag;
  final bool isSelected;
  final VoidCallback? onTap;
  final double? height;
  final double width;
  final Widget? trailing;
  final BorderRadius? borderRadius;
  final EdgeInsets padding;
  final bool isEnabled;
  final int maxLines;

  const VadenCard({
    super.key,
    required this.title,
    required this.subtitle,
    this.tag,
    this.isSelected = false,
    this.onTap,
    this.height,
    this.width = double.infinity,
    this.trailing,
    this.borderRadius,
    this.padding = const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    this.isEnabled = true,
    this.maxLines = 2,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final defaultBorderRadius = BorderRadius.circular(10);
    final effectiveBorderRadius = borderRadius ?? defaultBorderRadius;

    final effectiveIsEnabled = isEnabled || isSelected;

    final backgroundColor = effectiveIsEnabled //
        ? VadenColors.backgroundColor2 //
        : VadenColors.backgroundColor;

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
            color: isSelected ? VadenColors.stkWhite : VadenColors.stkDisabled,
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: VadenColors.txtSecondary,
                            fontWeight: FontWeight.bold,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (tag != null)
                        Container(
                          margin: const EdgeInsets.only(left: 8),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: VadenColors.stkSupport2,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            tag!,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: VadenColors.whiteColor,
                              fontSize: 10,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: VadenColors.txtSecondary,
                      fontWeight: FontWeight.w300,
                    ),
                    maxLines: maxLines,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            if (trailing != null)
              Padding(
                padding: const EdgeInsets.only(left: 8),
                child: trailing,
              )
            else if (isSelected)
              _buildSelectionIndicator()
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

  Widget _buildSelectionIndicator() {
    return Container(
      width: 24,
      height: 24,
      margin: const EdgeInsets.only(left: 8),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  VadenColors.gradientStart,
                  VadenColors.gradientEnd,
                ],
              ),
            ),
          ),
          Container(
            width: 18,
            height: 18,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.black,
            ),
          ),
          Container(
            width: 12,
            height: 12,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  VadenColors.gradientStart,
                  VadenColors.gradientEnd,
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
