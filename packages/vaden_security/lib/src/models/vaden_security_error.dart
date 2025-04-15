import 'package:vaden/vaden.dart';

@DTO()
class VadenSecurityError {
  final String error;

  VadenSecurityError(this.error);

  @override
  String toString() {
    return error;
  }
}
