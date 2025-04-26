import 'package:vaden/vaden.dart';

@Configuration()
class InitializationConfiguration {
  @Bean()
  Future<Initialization> init(ApplicationSettings settings) async {
    return Initialization(text: settings['openapi']['title']);
  }
}

class Initialization {
  final String text;

  Initialization({required this.text});

  Future<void> start() async {
    await Future.delayed(Duration(seconds: 3));
    print(text);
    print('Start boot');
  }

  Future<void> error() async {
    await Future.delayed(Duration(seconds: 3));
    throw Exception('error');
  }
}
