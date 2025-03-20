import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:localization/localization.dart';

import '../../config/dependencies.dart';
import '../core/ui/ui.dart';
import '../widgets/internation/internation_widget.dart';
import 'viewmodels/generate_viewmodel.dart';

class GeneratePage extends StatefulWidget {
  const GeneratePage({super.key});

  @override
  State<GeneratePage> createState() => _GeneratePageState();
}

class _GeneratePageState extends State<GeneratePage> {
  // AppBar Title
  final double fontSize = 24.0;
  late final double lineHeight = 24.0 / fontSize;
  late final double letterSpacing = fontSize * 0.04;

  // Generate
  final viewModel = injector.get<GenerateViewmodel>();

  final _projectNameEC = TextEditingController();
  final _projectDescriptionEC = TextEditingController();
  String? _projectNameError;

  @override
  void initState() {
    super.initState();
    viewModel.fetchDependenciesCommand.execute();
  }

  @override
  void dispose() {
    _projectNameEC.dispose();
    _projectDescriptionEC.dispose();
    super.dispose();
  }

  Future<void> _openDependenciesDialog() async {
    final result = await VadenDependenciesDialog.show(context, viewModel);

    if (result != null) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    Localizations.localeOf(context);
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [
            VadenColors.blackGradientStart,
            VadenColors.blackGradientEnd,
          ],
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: VadenAppBar(
          title: 'IN_DEVELOPMENT'.i18n(),
          mode: VadenAppBarMode.development, // Pode ser alterado para .production
          fontSize: fontSize,
          letterSpacing: letterSpacing,
          lineHeight: lineHeight,
        ),
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 60,
                child: Stack(
                  children: [
                    Center(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SvgPicture.asset(
                            VadenImage.vadenLogo,
                            width: 48,
                            height: 48,
                          ),
                          const SizedBox(width: 10),
                          Text(
                            'VADEN Generator',
                            style: GoogleFonts.anekBangla(
                              color: VadenColors.txtSecondary,
                              fontSize: 32,
                              fontWeight: FontWeight.normal,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Positioned(
                      right: 48,
                      top: 0,
                      bottom: 0,
                      child: Center(
                        child: InternationWidget(),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 48),
              Center(
                child: SizedBox(
                  width: 580,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Create_new_project'.i18n(),
                        style: GoogleFonts.anekBangla(
                          color: VadenColors.txtSecondary,
                          fontSize: 20,
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        height: 1,
                        width: 156,
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
                      const SizedBox(height: 32),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          VadenTextInput(
                            label: 'Project_name'.i18n(),
                            hint: 'Vaden_Backend'.i18n(),
                            controller: _projectNameEC,
                            onChanged: (value) {
                              final validation = viewModel.validateProjectName(value);
                              setState(() {
                                _projectNameError = validation;
                              });
                              viewModel.setNameProjectCommand.execute(value);
                            },
                            verticalPadding: 20,
                            errorText: _projectNameError,
                          ),
                          const SizedBox(height: 32),
                          VadenTextInput(
                            label: 'Description'.i18n(),
                            hint: 'Vaden_Project'.i18n(),
                            controller: _projectDescriptionEC,
                            onChanged: viewModel.setDescriptionProjectCommand.execute,
                            verticalPadding: 20,
                          ),
                          const SizedBox(height: 32),
                          SizedBox(
                            width: double.infinity,
                            child: VadenDropdown(
                              options: viewModel.dartVersions,
                              title: 'Dart_version'.i18n(),
                              selectedOption: 'Dart_version'.i18n(),
                              title: 'Versão Dart',
                              selectedOption: viewModel.latestDartVersion,

                              onOptionSelected: viewModel.setDartVersionProjectCommand.execute,
                              width: double.infinity,
                              fontSize: 16.0,
                            ),
                          )
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 48),
              Center(
                child: SizedBox(
                  width: 580,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
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
                        width: 130,
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
                      const SizedBox(height: 32),
                      Column(
                        children: [
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(top: 0),
                                child: SizedBox(
                                  width: 440,
                                  height: viewModel.projectDependencies.isEmpty ? 56 : null,
                                  child: viewModel.projectDependencies.isEmpty
                                      ? VadenTextInput(

                                          label: 'Add_dependencies'.i18n(),

                                          hint: '',
                                          verticalPadding: viewModel.projectDependencies.isEmpty //
                                              ? 20
                                              : 12,
                                          isEnabled: false,
                                        )
                                      : VadenDependenciesCard(
                                          dependencies: viewModel.projectDependencies,
                                          onRemove: (dependency) {
                                            viewModel.removeDependencyOnProjectCommand
                                                .execute(dependency);
                                            setState(() {});
                                          },
                                        ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              SizedBox(
                                width: 124,
                                height: 56,
                                child: VadenButtonExtension.primary(
                                  title: 'Add'.i18n(),
                                  onPressed: _openDependenciesDialog,
                                  icon: null,
                                  width: 120,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 80),
                      ListenableBuilder(
                        listenable: viewModel,
                        builder: (context, child) {
                          final String title = 'Generate_project'.i18n();
                          final double width = 320;

                          return Center(
                            child: viewModel.projectIsValid()
                                ? ListenableBuilder(
                                    listenable: viewModel.createProjectCommand,
                                    builder: (context, child) {
                                      return VadenButtonExtension.primary(
                                        title: title,
                                        onPressed: () => viewModel.createProjectCommand.execute(),
                                        icon: null,
                                        width: width,
                                        isLoading: viewModel.createProjectCommand.isRunning,
                                      );
                                    },
                                  )
                                : VadenButtonExtension.outlined(
                                    title: title,
                                    onPressed: () {},
                                    icon: null,
                                    width: width,
                                    borderColor: VadenColors.stkWhite,
                                  ),
                          );
                        },
                      ),
                      const SizedBox(height: 320),
                      Center(
                        child: Column(
                          spacing: 16,
                          children: [
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  '${'Community_made'.i18n()} ',
                                  style: GoogleFonts.anekBangla(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w300,
                                    color: VadenColors.secondaryColor,
                                  ),
                                ),
                                SvgPicture.asset(
                                  VadenImage.flutterandoLogo,
                                  width: 120,
                                  height: 24,
                                ),
                              ],
                            ),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  '${'Copyright'.i18n()} ',
                                  style: GoogleFonts.anekBangla(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                    color: VadenColors.txtSupport2,
                                  ),
                                ),
                                SvgPicture.asset(
                                  VadenImage.copyrightIcon,
                                  width: 120,
                                  height: 24,
                                ),
                                Text(
                                  '2025',
                                  style: GoogleFonts.anekBangla(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                    color: VadenColors.txtSupport2,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
