/// Templates for generating Vaden configurations
class ConfigurationTemplate {
  /// Generate a basic configuration class
  static String generateConfiguration({
    required String className,
    String? description,
  }) {
    final buffer = StringBuffer();

    buffer.writeln("import 'package:vaden/vaden.dart';");
    buffer.writeln();

    buffer.writeln('@Configuration');
    buffer.writeln('class $className {');
    buffer.writeln('  // Add your @Bean methods here');
    buffer.writeln('}');

    return buffer.toString();
  }

  /// Generate a bean method
  static String generateBeanMethod({
    required String methodName,
    required String returnType,
  }) {
    final buffer = StringBuffer();

    buffer.writeln('  @Bean');
    buffer.writeln('  $returnType $methodName() {');
    buffer.writeln('    // TODO: Configure and return $returnType instance');
    buffer.writeln('    throw UnimplementedError();');
    buffer.writeln('  }');

    return buffer.toString();
  }

  /// Generate OpenAPI configuration
  static String generateOpenApiConfiguration() {
    return '''import 'package:vaden/vaden.dart';

@Configuration
class OpenApiConfiguration {
  @Bean
  OpenApiConfig openApi() {
    return OpenApiConfig(
      title: 'API Documentation',
      version: '1.0.0',
      description: 'API documentation for the application',
    );
  }

  @Bean
  SwaggerUIConfig swaggerUI() {
    return SwaggerUIConfig(
      path: '/docs',
      openApiPath: '/docs/openapi.json',
    );
  }
}
''';
  }

  /// Generate database configuration template
  static String generateDatabaseConfiguration() {
    return '''import 'package:vaden/vaden.dart';

@Configuration
class DatabaseConfiguration {
  @Bean
  DatabaseConfig database() {
    return DatabaseConfig(
      host: 'localhost',
      port: 5432,
      database: 'myapp',
      username: 'user',
      password: 'password',
    );
  }
}
''';
  }

  /// Generate security configuration template
  static String generateSecurityConfiguration() {
    return '''import 'package:vaden/vaden.dart';
import 'package:vaden_security/vaden_security.dart';

@Configuration
class SecurityConfiguration {
  @Bean
  PasswordEncoder passwordEncoder() {
    return BCryptPasswordEncoder();
  }

  @Bean
  JwtService jwtService() {
    return JwtService(
      secret: 'your-secret-key',
      accessTokenExpiration: Duration(hours: 1),
      refreshTokenExpiration: Duration(days: 7),
    );
  }

  @Bean
  HttpSecurity httpSecurity() {
    return HttpSecurity()
      ..permitAll('/auth/login')
      ..permitAll('/auth/refresh')
      ..authenticated('/api/**');
  }
}
''';
  }
}
