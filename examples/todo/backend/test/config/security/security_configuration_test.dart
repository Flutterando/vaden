import 'package:vaden_security/vaden_security.dart';

void main() {
  final password = BCryptPasswordEncoder(cost: 10).encode('12345678');
  print(password);
}
