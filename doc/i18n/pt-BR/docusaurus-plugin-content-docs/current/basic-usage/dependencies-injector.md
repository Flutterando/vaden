---
sidebar_position: 3
---

# Scope

A anotação `@Scope()` define como um componente é registrado no container de injeção de dependências.

Por padrão, as classes são registradas como lazySingleton, ou seja, uma instância só é criada na primeira vez que for solicitada. Você pode alterar esse comportamento passando um BindType diferente para o `@Scope()`.

## Tipos de Bind

O enum `BindType` define os tipos de vinculação disponíveis:

- `BindType.singleton`: Uma única instância é criada e compartilhada em todo o app.
- `BindType.lazySingleton` (padrão): Uma única instância é criada de forma preguiçosa no primeiro acesso.
- `BindType.instance`: Uma nova instância é criada toda vez que for solicitada.
- `BindType.factory`: Semelhante ao `instance`, mas permite passar parâmetros na criação.

## Exemplo

```dart
@Scope(BindType.singleton)
class DatabaseService {
  void connect() => print('Connected');
}

@Scope(BindType.instance)
class Counter {
  int count = 0;
}
````

Se nenhum tipo for especificado, o padrão é lazySingleton:
```dart
@Serices()
@Scope()
class AuthService {}

``` 

# Injeção via Construtor
O container resolve e injeta automaticamente as dependências declaradas no construtor:

```dart
@Scope(BindType.singleton)
class UserService {
  final DatabaseService database;

  UserService(this.database);

  void load() {
    database.connect();
  }
}
```
Desde que DatabaseService esteja registrado, UserService irá recebê-lo.