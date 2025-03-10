part 'openapi.dart';
part 'rest.dart';

abstract interface class BaseComponent {
  bool get registerWithInterfaceOrSuperType;
}

final class Component implements BaseComponent {
  @override
  final bool registerWithInterfaceOrSuperType;
  const Component([this.registerWithInterfaceOrSuperType = false]);
}

final class Service implements BaseComponent {
  const Service([this.registerWithInterfaceOrSuperType = true]);

  @override
  final bool registerWithInterfaceOrSuperType;
}

final class Repository implements BaseComponent {
  const Repository([this.registerWithInterfaceOrSuperType = true]);

  @override
  final bool registerWithInterfaceOrSuperType;
}

final class Configuration implements BaseComponent {
  const Configuration();

  @override
  final bool registerWithInterfaceOrSuperType = false;
}

class Bean {
  const Bean();
}

final class Controller implements BaseComponent {
  final String path;

  const Controller(this.path);

  @override
  final bool registerWithInterfaceOrSuperType = false;
}

final class DTO implements BaseComponent {
  const DTO();

  @override
  final bool registerWithInterfaceOrSuperType = false;
}

class JsonKey {
  final String name;
  const JsonKey(this.name);
}

class JsonIgnore {
  const JsonIgnore();
}

class UseMiddleware {
  final List<Type> middlewares;
  const UseMiddleware(this.middlewares);
}

class UseGuards {
  final List<Type> guards;
  const UseGuards(this.guards);
}

class Query {
  final String name;
  const Query(this.name);
}

class Param {
  final String name;

  const Param(this.name);
}

class Body {
  const Body();
}

class Header {
  final String name;
  const Header(this.name);
}

class Context {
  final String name;
  const Context(this.name);
}
