import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:localization/localization.dart';

import '../../config/dependencies.dart';
import '../../domain/entities/project.dart';
import '../../domain/validators/project_validator.dart';
import '../core/ui/ui.dart';
import '../widgets/internation/internation_widget.dart';
import 'viewmodels/generate_viewmodel.dart';
import 'widgets/vaden_dependencies_dialog.dart';

class GeneratePage extends StatefulWidget {
  const GeneratePage({super.key});

  @override
  State<GeneratePage> createState() => _GeneratePageState();
}

class _GeneratePageState extends State<GeneratePage> {
  final double fontSize = 24.0;
  late final double lineHeight = 24.0 / fontSize;
  late final double letterSpacing = fontSize * 0.04;

  final viewModel = injector.get<GenerateViewmodel>();

  final project = Project();

  final projectValidator = ProjectValidator();

  @override
  void initState() {
    super.initState();
    viewModel.fetchDependenciesCommand.execute();
    project.setDartVersion(viewModel.latestDartVersion);
  }

  Future<void> _openDependenciesDialog() async {
    final notSelectedDependencies = [...viewModel.dependencies].where((e) {
      return !project.dependencies.contains(e);
    }).toList();

    final result = await VadenDependenciesDialog.show(
      context,
      notSelectedDependencies,
    );

    if (result != null) {
      setState(() {
        project.dependencies.add(result);
      });
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
          mode: VadenAppBarMode.development,
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
                      LayoutBuilder(
                        builder: (context, constraints) {
                          final textSpan = TextSpan(
                            text: 'Create_new_project'.i18n(),
                            style: GoogleFonts.anekBangla(
                              color: VadenColors.txtSecondary,
                              fontSize: 20,
                              fontWeight: FontWeight.normal,
                            ),
                          );
                          final textPainter = TextPainter(
                            text: textSpan,
                            textDirection: TextDirection.ltr,
                          )..layout();
                          return Container(
                            height: 1,
                            width: textPainter.width,
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
                          );
                        },
                      ),
                      const SizedBox(height: 32),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          VadenTextInput(
                            autovalidateMode: AutovalidateMode.onUserInteraction,
                            label: 'Project_name'.i18n(),
                            hint: 'Vaden_Backend'.i18n(),
                            onChanged: project.setName,
                            validator: projectValidator.byField(project, 'name'),
                            verticalPadding: 20,
                          ),
                          const SizedBox(height: 32),
                          VadenTextInput(
                            autovalidateMode: AutovalidateMode.onUserInteraction,
                            label: 'Description'.i18n(),
                            hint: 'Vaden_Project'.i18n(),
                            onChanged: project.setDescription,
                            validator: projectValidator.byField(project, 'description'),
                            verticalPadding: 20,
                          ),
                          const SizedBox(height: 32),
                          SizedBox(
                            width: double.infinity,
                            child: VadenDropdown(
                              options: viewModel.dartVersions,
                              title: 'Dart_version'.i18n(),
                              selectedOption: viewModel.latestDartVersion,
                              onOptionSelected: project.setDartVersion,
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
                      LayoutBuilder(
                        builder: (context, constraints) {
                          final textSpan = TextSpan(
                            text: 'Dependencies'.i18n(),
                            style: GoogleFonts.anekBangla(
                              color: VadenColors.txtSecondary,
                              fontSize: 20,
                              fontWeight: FontWeight.normal,
                            ),
                          );
                          final textPainter = TextPainter(
                            text: textSpan,
                            textDirection: TextDirection.ltr,
                          )..layout();
                          return Container(
                            height: 1,
                            width: textPainter.width,
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
                          );
                        },
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
                                  height: project.dependencies.isEmpty ? 56 : null,
                                  child: project.dependencies.isEmpty
                                      ? VadenTextInput(
                                          label: 'Add_dependencies'.i18n(),
                                          hint: '',
                                          verticalPadding: project.dependencies.isEmpty //
                                              ? 20
                                              : 12,
                                          isEnabled: false,
                                        )
                                      : VadenDependenciesCard(
                                          dependencies: project.dependencies,
                                          onRemove: (dependency) {
                                            setState(() {
                                              project.dependencies.remove(dependency);
                                            });
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
                        listenable: Listenable.merge([
                          viewModel.createProjectCommand,
                          project,
                        ]),
                        builder: (context, child) {
                          final String title = 'Generate_project'.i18n();
                          final double width = 320;

                          return Center(
                            child: projectValidator.validate(project).isValid
                                ? VadenButtonExtension.primary(
                                    title: title,
                                    onPressed: () =>
                                        viewModel.createProjectCommand.execute(project),
                                    icon: null,
                                    width: width,
                                    isLoading: viewModel.createProjectCommand.isRunning,
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
                                  '${'Community_made'.i18n()}  ',
                                  style: GoogleFonts.anekBangla(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w300,
                                    color: VadenColors.secondaryColor,
                                  ),
                                ),
                                InkWell(
                                  child: SvgPicture.asset(
                                    VadenImage.flutterandoLogo,
                                    width: 120,
                                    height: 24,
                                  ),
                                  onTap: () {
                                    context.go('/linktree');
                                  },
                                ),
                              ],
                            ),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  '${'Copyright'.i18n()}  ',
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
                                  ' 2025',
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
