import 'package:flutter/material.dart';

import '../ui/core/ui/ui.dart';

class UiExamples extends StatefulWidget {
  const UiExamples({super.key});

  @override
  State<UiExamples> createState() => _UiExamplesState();
}

class _UiExamplesState extends State<UiExamples> {
  String? _selectedVersion;
  String? _selectedLanguage;
  String? _selectedOptions;
  bool _isLoading = false;

  String? _selectedCard;

  void _toggleLoading() {
    setState(() {
      _isLoading = !_isLoading;
    });
  }

  void _selectCard(String cardId) {
    setState(() {
      if (_selectedCard == cardId) {
        _selectedCard = null;
      } else {
        _selectedCard = cardId;
      }
    });
  }

  // Mock de versões
  final List<String> _dartVersions = [
    '3.8.0-70.1.beta',
    '3.7.1 (ref dcddfab)',
    '3.7.0',
    '3.3.1',
    '3.2.1',
    '3.1.0',
  ];

  final List<String> _languages = [
    'Portugues',
    'English',
  ];

  final List<String> _dependenciesOptions = [
    'Dev Tools',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: VadenColors.backgroundColor2,
      body: Padding(
        padding: const EdgeInsets.all(32.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              VadenTextInput(
                label: 'Project Name',
                hint: 'Enter project name',
              ),
              const SizedBox(height: 8),
              VadenDropdown(
                title: 'Dart Version',
                options: _dartVersions,
                placeholder: _selectedVersion ?? 'Select a Dart Version',
                onOptionSelected: (version) {
                  setState(() {
                    _selectedVersion = version;
                  });
                },
              ),
              const SizedBox(height: 24),
              VadenButton(
                label: 'Primary Button',
                onPressed: _toggleLoading,
                isLoading: _isLoading,
              ),
              const SizedBox(height: 16),
              VadenButton(
                style: VadenButtonStyle.critical,
                label: 'Outlined Button',
                onPressed: _toggleLoading,
                isLoading: _isLoading,
              ),
              const SizedBox(height: 16),
              VadenButton(
                style: VadenButtonStyle.outlined,
                label: 'Outlined Button',
                onPressed: _toggleLoading,
                isLoading: _isLoading,
              ),
              const SizedBox(height: 16),
              VadenButton(
                style: VadenButtonStyle.outlinedWhite,
                label: 'Outlined Button',
                onPressed: _toggleLoading,
                isLoading: _isLoading,
              ),
              const SizedBox(height: 16),
              VadenButton(
                style: VadenButtonStyle.text,
                label: 'Outlined Button',
                onPressed: _toggleLoading,
                isLoading: _isLoading,
              ),
              const SizedBox(height: 16),
              VadenButton(
                style: VadenButtonStyle.white,
                label: 'Outlined Button',
                onPressed: _toggleLoading,
                isLoading: _isLoading,
              ),
              const SizedBox(height: 16),
              VadenButton(
                style: VadenButtonStyle.white,
                label: 'Outlined Button',
                onPressed: _toggleLoading,
                isLoading: _isLoading,
                prefixIcon: Icons.star,
              ),
              const SizedBox(height: 16),
              VadenButton(
                style: VadenButtonStyle.white,
                label: 'Outlined Button',
                onPressed: _toggleLoading,
                isLoading: _isLoading,
                suffixIcon: Icons.star,
              ),
              const SizedBox(height: 16),
              VadenCard(
                title: 'Card',
                subtitle: 'Subtitle',
                // tag: 'Dev tools',
                isSelected: _selectedCard == 'card',
                onTap: () => _selectCard('card'),
              ),
              const SizedBox(height: 16),
              VadenProjectCard(
                title: 'Gradle - Groovy',
                variant: ProjectVariant.gradle,
                onTap: () => _selectCard('gradle-groovy'),
                isSelected: _selectedCard == 'gradle-groovy',
              ),
              const SizedBox(height: 16),
              VadenProjectCard(
                title: 'Gradle - Kotlin',
                variant: ProjectVariant.gradle,
                onTap: () => _selectCard('gradle-kotlin'),
                isSelected: _selectedCard == 'gradle-kotlin',
              ),
              const SizedBox(height: 16),
              VadenProjectCard(
                title: 'Marven - Groovy',
                variant: ProjectVariant.marven,
                onTap: () => _selectCard('marven-groovy'),
                isSelected: _selectedCard == 'marven-groovy',
              ),
              const SizedBox(height: 16),
              VadenDropdown(
                options: _languages,
                placeholder: _selectedLanguage ?? 'Portugues',
                selectedOption: _selectedLanguage,
                onOptionSelected: (language) {
                  setState(() {
                    _selectedLanguage = language;
                  });
                },
              ),
              const SizedBox(height: 16),
              VadenDropdown(
                options: _dependenciesOptions,
                placeholder: _selectedOptions ?? 'DevTools',
                selectedOption: _selectedOptions,
                onOptionSelected: (options) {
                  setState(() {
                    _selectedOptions = options;
                  });
                },
              ),
              const SizedBox(height: 80),
            ],
          ),
        ),
      ),
    );
  }
}
