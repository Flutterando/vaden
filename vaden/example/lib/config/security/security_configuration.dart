import 'package:vaden/vaden.dart';
import 'package:vaden_security/vaden_security.dart';

@Configuration()
class SecurityConfiguration {
  @Bean()
  PasswordEncoder passwordEncoder() {
    return BCryptPasswordEncoder(cost: 10);
  }

  @Bean()
  JwtService jwtService(ApplicationSettings settings) {
    return JwtService.withSettings(settings);
  }

  @Bean()
  HttpSecurity httpSecurity() {
    return HttpSecurity([
      RequestMatcher('/auth/**/*').permitAll(),
      RequestMatcher('/docs/**/*').permitAll(),
      RequestMatcher('/hello/**/*').permitAll(),
      RequestMatcher('/dto/**/*').permitAll(),
      RequestMatcher('/tablet/**/*', HttpMethod.get).permitAll(),
      AnyRequest().authenticated(),
    ]);
  }
}
