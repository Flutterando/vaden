import 'package:vaden/vaden.dart';

@Component()
class AppWarmup implements ApplicationRunner {
  @override
  Future<void> run(VadenApplication app) async {
    print('ApplicationRunner');
  }
}

@Component()
class AppRunner implements CommandLineRunner {
  @override
  Future<void> run(List<String> args) async {
    print('My args: $args');
  }
}
