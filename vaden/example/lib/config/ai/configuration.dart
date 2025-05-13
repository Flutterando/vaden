import 'package:vaden/vaden.dart';
import 'package:vaden_ai/vaden_ai.dart';

@Configuration()
class McpConfiguration {
  @Bean()
  McpService mcpService(ApplicationSettings settings) {
    return McpService.withSettings(settings);
  }
}
