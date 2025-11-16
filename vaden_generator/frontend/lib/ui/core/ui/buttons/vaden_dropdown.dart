import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../themes/colors.dart';

class VadenDropdown extends StatefulWidget {
  final String? title;
  final String placeholder;
  final List<String> options;
  final String? selectedOption;
  final Function(String)? onOptionSelected;
  final bool isEnabled;
  final TextStyle? textStyle;
  final TextStyle? titleStyle;
  final TextStyle? optionsStyle;
  final double? height;
  final double? width;
  final double fontSize;
  final bool dynamicWidth;

  const VadenDropdown({
    super.key,
    this.title,
    this.placeholder = 'Selecione uma opção',
    required this.options,
    this.selectedOption,
    this.onOptionSelected,
    this.isEnabled = true,
    this.textStyle,
    this.titleStyle,
    this.optionsStyle,
    this.height,
    this.width,
    this.fontSize = 16.0,
    this.dynamicWidth = false,
  });

  @override
  State<VadenDropdown> createState() => _VadenDropdownState();
}

class _VadenDropdownState extends State<VadenDropdown> {
  bool _isDropdownOpen = false;
  final LayerLink _layerLink = LayerLink();
  OverlayEntry? _overlayEntry;
  final GlobalKey _dropdownKey = GlobalKey();

  String? _selectedOption;

  @override
  void initState() {
    super.initState();

    _selectedOption = widget.selectedOption;
  }

  @override
  void didUpdateWidget(VadenDropdown oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.selectedOption != oldWidget.selectedOption) {
      _selectedOption = widget.selectedOption;

      if (_isDropdownOpen) {
        _removeOverlay();

        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            _showOverlay();
          }
        });
      }
    }
  }

  @override
  void dispose() {
    _removeOverlay();
    super.dispose();
  }

  void _toggleDropdown() {
    if (!widget.isEnabled) return;

    setState(() {
      _isDropdownOpen = !_isDropdownOpen;
    });

    if (_isDropdownOpen) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _showOverlay();
        }
      });
    } else {
      _removeOverlay();
    }
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  void _showOverlay() {
    _overlayEntry = _createOverlayEntry();
    Overlay.of(context).insert(_overlayEntry!);
  }

  void _selectOption(String option) {
    setState(() {
      _selectedOption = option;
    });

    if (widget.onOptionSelected != null) {
      widget.onOptionSelected!(option);
    }

    if (_isDropdownOpen && _overlayEntry != null) {
      _overlayEntry!.markNeedsBuild();
    }

    _toggleDropdown();
  }

  Widget _buildSelectionIndicator() {
    return SizedBox(
      width: 24,
      height: 24,
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
                colors: [VadenColors.gradientStart, VadenColors.gradientEnd],
              ),
            ),
          ),
          Container(
            width: 18,
            height: 18,
            decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.black),
          ),
          Container(
            width: 12,
            height: 12,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [VadenColors.gradientStart, VadenColors.gradientEnd],
              ),
            ),
          ),
        ],
      ),
    );
  }

  OverlayEntry _createOverlayEntry() {
    final RenderBox renderBox = _dropdownKey.currentContext!.findRenderObject() as RenderBox;
    final size = renderBox.size;

    // Calcular a largura máxima necessária para as opções
    double maxTextWidth = 0;
    if (widget.dynamicWidth) {
      final TextStyle textStyle =
          widget.optionsStyle ??
          widget.textStyle ??
          TextStyle(color: VadenColors.whiteColor, fontSize: widget.fontSize);

      final TextPainter textPainter = TextPainter(
        textDirection: TextDirection.ltr,
        textScaler: MediaQuery.of(_dropdownKey.currentContext!).textScaler,
      );

      for (final option in widget.options) {
        textPainter.text = TextSpan(text: option, style: textStyle);
        textPainter.layout();
        if (textPainter.width > maxTextWidth) {
          maxTextWidth = textPainter.width;
        }
      }

      // Adicionar espaço para o ícone e padding
      maxTextWidth += 80; // 24px para o ícone + 16px padding de cada lado + 24px margem extra
    }

    // Usar a maior largura entre o dropdown e o texto mais longo
    final dropdownWidth = widget.dynamicWidth ? math.max(size.width, maxTextWidth) : size.width;

    return OverlayEntry(
      builder: (context) => GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () {
          setState(() {
            _isDropdownOpen = false;
          });
          _removeOverlay();
        },
        child: Stack(
          children: [
            Positioned.fill(child: Container(color: Colors.transparent)),
            Positioned(
              width: dropdownWidth,
              child: CompositedTransformFollower(
                link: _layerLink,
                showWhenUnlinked: false,
                offset: Offset(0, size.height + 4),
                child: GestureDetector(
                  onTap: () {},
                  child: Material(
                    elevation: 8,
                    color: Colors.transparent,
                    shadowColor: Colors.black26,
                    child: Container(
                      constraints: BoxConstraints(
                        maxHeight: MediaQuery.of(context).size.height * 0.3,
                        minWidth: dropdownWidth,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: VadenColors.txtSupport2, width: 1),
                      ),
                      child: ListView.builder(
                        padding: EdgeInsets.zero,
                        shrinkWrap: true,
                        physics: const ClampingScrollPhysics(),
                        itemCount: widget.options.length,
                        itemBuilder: (context, index) {
                          final option = widget.options[index];
                          final isSelected = option == _selectedOption;

                          return InkWell(
                            onTap: () => _selectOption(option),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              child: Row(
                                mainAxisSize: widget.dynamicWidth
                                    ? MainAxisSize.min
                                    : MainAxisSize.max,
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Flexible(
                                    child: Text(
                                      option,
                                      style:
                                          widget.optionsStyle ??
                                          widget.textStyle ??
                                          TextStyle(
                                            color: VadenColors.whiteColor,
                                            fontSize: widget.fontSize,
                                          ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  SizedBox(width: 8),
                                  isSelected
                                      ? _buildSelectionIndicator()
                                      : Container(
                                          width: 24,
                                          height: 24,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            border: Border.all(
                                              color: VadenColors.txtSupport2,
                                              width: 1,
                                            ),
                                          ),
                                        ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Tamanho de fonte configurável
    final defaultTextStyle = TextStyle(
      color: widget.isEnabled ? VadenColors.whiteColor : VadenColors.disabledColor,
      fontSize: widget.fontSize,
    );

    final dropdownContent = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.title != null)
          Padding(
            padding: const EdgeInsets.only(left: 8.0, bottom: 4.0),
            child: Text(
              widget.title!,
              style:
                  widget.titleStyle ??
                  widget.textStyle ??
                  defaultTextStyle.copyWith(color: Colors.white70),
            ),
          ),
        CompositedTransformTarget(
          link: _layerLink,
          child: GestureDetector(
            key: _dropdownKey,
            onTap: _toggleDropdown,
            child: Container(
              height: widget.height ?? 56,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: VadenColors.txtSupport2, width: 1),
              ),
              child: Row(
                mainAxisSize: widget.dynamicWidth ? MainAxisSize.min : MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: Text(
                      _selectedOption ?? widget.placeholder,
                      style: widget.textStyle ?? defaultTextStyle,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  SizedBox(width: 8),
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: VadenColors.backgroundColor2,
                      border: Border.all(color: VadenColors.stkSupport2, width: 1),
                    ),
                    child: Center(
                      child: Icon(
                        _isDropdownOpen
                            ? Icons.keyboard_arrow_up_rounded
                            : Icons.keyboard_arrow_down_rounded,
                        color:
                            widget
                                .isEnabled //
                            ? VadenColors
                                  .whiteColor //
                            : VadenColors.txtSupport2,
                        size: 16,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );

    // Se a largura for dinâmica, não envolva em um SizedBox
    if (widget.dynamicWidth) {
      return dropdownContent;
    }

    // Caso contrário, use um SizedBox com largura fixa (comportamento original)
    return SizedBox(width: widget.width, child: dropdownContent);
  }
}
