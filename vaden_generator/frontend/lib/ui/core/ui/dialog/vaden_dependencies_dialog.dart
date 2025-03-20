import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:localization/localization.dart';
import 'package:provider/provider.dart';

import '../../../../domain/entities/dependency.dart';
import '../../../generate/viewmodels/generate_viewmodel.dart';
import '../ui.dart';

class VadenDependenciesDialog extends StatefulWidget {
  final Function(List<Dependency>) onSave;
  final VoidCallback onCancel;

  const VadenDependenciesDialog({
    super.key,
    required this.onSave,
    required this.onCancel,
  });

  static Future<List<Dependency>?> show(
    BuildContext context,
    GenerateViewmodel viewModel,
  ) async {
    return await showDialog<List<Dependency>>(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black.withOpacity(0.5),
      builder: (context) => ChangeNotifierProvider.value(
        value: viewModel,
        child: VadenDependenciesDialog(
          onSave: (selectedDeps) {
            Navigator.of(context).pop(selectedDeps);
          },
          onCancel: () {
            Navigator.of(context).pop();
          },
        ),
      ),
    );
  }

  @override
  State<VadenDependenciesDialog> createState() => _VadenDependenciesDialogState();
}

class _VadenDependenciesDialogState extends State<VadenDependenciesDialog> {
  List<Dependency> _selectedDependencies = [];
  String _currentCategory = 'Todos';
  final double fontSize = 12.0;
  late final double lineHeight = 24.0 / fontSize;
  late final double letterSpacing = fontSize * 0.04;

  @override
  void initState() {
    super.initState();

    // Buscar dependências quando o diálogo é aberto
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchDependencies();
    });
  }

  void _fetchDependencies() {
    final viewModel = context.read<GenerateViewmodel>();

    // Inicializar dependências já selecionadas
    setState(() {
      _selectedDependencies = List.from(viewModel.projectDependencies);
    });
  }

  // Método para obter categorias únicas das dependências
  List<String> _getUniqueCategories(List<Dependency> dependencies) {
    final categories = dependencies.map((dep) => dep.tag).toSet().toList();
    return [
      'Todos',
      ...categories.isEmpty ? ['Dev Tools'] : categories
    ];
  }

  // Método para filtrar dependências pela categoria atual
  List<Dependency> _getFilteredDependencies(List<Dependency> dependencies) {
    if (dependencies.isEmpty) return [];
    if (_currentCategory == 'Todos') return dependencies;
    return dependencies.where((dep) => dep.tag == _currentCategory).toList();
  }

  void _toggleDependency(Dependency dependency) {
    final viewModel = context.read<GenerateViewmodel>();

    if (_selectedDependencies.contains(dependency)) {
      _selectedDependencies.remove(dependency);
      viewModel.removeDependencyOnProjectCommand.execute(dependency);
    } else {
      _selectedDependencies.add(dependency);
      viewModel.addDependencyOnProjectCommand.execute(dependency);
    }

    // Fechar o diálogo e retornar as dependências selecionadas
    widget.onSave(_selectedDependencies);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<GenerateViewmodel>(
      builder: (context, viewModel, _) {
        final dependencies = viewModel.dependencies;
        final categories = _getUniqueCategories(dependencies);

        // Garantir que a categoria atual existe na lista de categorias
        if (dependencies.isNotEmpty && !categories.contains(_currentCategory)) {
          _currentCategory = categories.first;
        }

        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          child: Container(
            width: 580,
            decoration: BoxDecoration(
              color: VadenColors.dialogBgColor,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Cabeçalho do diálogo
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        children: [
                          Text(
                            'Dependencies'.i18n(),
                            style: GoogleFonts.anekBangla(
                              color: VadenColors.txtSecondary,
                              fontSize: 20,
                              fontWeight: FontWeight.normal,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Container(
                            height: 1,
                            width: 120,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.centerLeft,
                                end: Alignment.centerRight,
                                colors: [
                                  VadenColors.gradientStart,
                                  VadenColors.gradientEnd,
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      Container(
                        height: 40,
                        constraints: BoxConstraints(
                          minWidth: 120,
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: VadenDropdown(
                          options: categories,
                          height: 36,
                          fontSize: 12.0,
                          dynamicWidth: true,
                          optionsStyle: GoogleFonts.anekBangla(
                            fontSize: fontSize,
                            color: VadenColors.txtSecondary,
                            height: lineHeight * 0.5,
                            letterSpacing: letterSpacing,
                          ),
                          selectedOption: _currentCategory,
                          onOptionSelected: (newCategory) {
                            setState(() {
                              _currentCategory = newCategory;
                            });
                          },
                        ),
                      )
                    ],
                  ),
                ),

                // Conteúdo do diálogo (dependendo do estado)
                Builder(
                  builder: (context) {
                    // Estado de carregamento
                    if (viewModel.fetchDependenciesCommand.isRunning) {
                      return Container(
                        height: 300,
                        alignment: Alignment.center,
                        child: const CircularProgressIndicator.adaptive(
                          backgroundColor: VadenColors.errorColor,
                        ),
                      );
                    }

                    // Estado de erro
                    if (viewModel.fetchDependenciesCommand.isFailure) {
                      return Container(
                        height: 300,
                        alignment: Alignment.center,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Loading_dependencies_error'.i18n(),
                              style: GoogleFonts.anekBangla(
                                color: VadenColors.errorColor,
                                fontSize: 16,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 16),
                            TextButton.icon(
                              onPressed: _fetchDependencies,
                              icon: const Icon(Icons.refresh, color: VadenColors.errorColor),
                              label: Text(
                                'Try_again'.i18n(),
                                style: GoogleFonts.anekBangla(
                                  color: VadenColors.errorColor,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    // Estado sem dependências
                    if (dependencies.isEmpty) {
                      return Container(
                        height: 300,
                        alignment: Alignment.center,
                        child: Text(
                          'No_dependencies_available'.i18n(),
                          style: GoogleFonts.anekBangla(
                            color: VadenColors.txtSupport,
                            fontSize: 16,
                          ),
                        ),
                      );
                    }

                    // Lista de dependências
                    return ConstrainedBox(
                      constraints: BoxConstraints(
                        maxHeight: MediaQuery.of(context).size.height * 0.5,
                        minHeight: 50,
                      ),
                      child: ListView.separated(
                        shrinkWrap: true,
                        padding: const EdgeInsets.all(20),
                        itemCount: _getFilteredDependencies(dependencies).length,
                        separatorBuilder: (_, __) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final dependency = _getFilteredDependencies(dependencies)[index];
                          final isSelected = _selectedDependencies.contains(dependency);

                          return VadenCard(
                            title: dependency.name,
                            subtitle: dependency.description,
                            tag: dependency.tag,
                            isSelected: isSelected,
                            onTap: () => _toggleDependency(dependency),
                            maxLines: 3,
                          );
                        },
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
