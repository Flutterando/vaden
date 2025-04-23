import 'package:vaden/vaden.dart';

@DTO()
class DartVersion with Validator<DartVersion> {
  final String id;
  final String name;

  DartVersion({
    required this.id,
    required this.name,
  });

  @override
  LucidValidator<DartVersion> validate(ValidatorBuilder<DartVersion> builder) {
    builder //
        .ruleFor((p) => p.id, key: 'dartVersion')
        .notEmpty()
        .matchesPattern(
          r"^\d+\.\d+\.\d+$",
          message: "Invalid dart version",
        );

    return builder;
  }
}
