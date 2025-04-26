import 'package:example/config/initialization/initialization_configuration.dart';
import 'package:vaden/vaden.dart';

@Configuration()
class AppConfiguration {
  @Bean()
  ApplicationSettings settings() {
    return ApplicationSettings.load('application.yaml');
  }

  @Bean()
  Future<InitializationSettings> boot(Initialization init) async {
    return InitializationSettings.load([]);
  }

  @Bean()
  Pipeline globalMiddleware(ApplicationSettings settings) {
    return Pipeline() //
        .addMiddleware(cors(allowedOrigins: ['*']))
        .addVadenMiddleware(EnforceJsonContentType())
        .addMiddleware(logRequests());
  }
}
