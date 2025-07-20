import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:test/test.dart';
import 'package:vaden_class_scanner/src/setups/dto_setup.dart';

void main() {
  group('DTO Setup Union Types', () {
    test('should detect sealed class and generate union setup', () {
      // Arrange - Mock de uma sealed class
      final mockSealedClass = MockClassElement(
        name: 'Extract',
        isSealed: true,
        constructors: [
          MockConstructorElement(
            isFactory: true,
            redirectedConstructor: MockConstructorElement(
              enclosingElement: MockClassElement(name: 'ReceivedExtract'),
            ),
          ),
          MockConstructorElement(
            isFactory: true,
            redirectedConstructor: MockConstructorElement(
              enclosingElement: MockClassElement(name: 'SentExtract'),
            ),
          ),
        ],
      );

      // Act
      final result = dtoSetup(mockSealedClass);

      // Assert
      expect(result, contains('fromJsonMap[Extract]'));
      expect(result, contains('toJsonMap[Extract]'));
      expect(result, contains('toOpenApiMap[Extract]'));

      // Verifica se gera o switch/case correto para fromJson
      expect(result, contains('case \'ReceivedExtract\':'));
      expect(result, contains('case \'SentExtract\':'));
      expect(result, contains('return fromJson<ReceivedExtract>(json);'));
      expect(result, contains('return fromJson<SentExtract>(json);'));

      // Verifica se gera o switch/case correto para toJson baseado no runtimeType
      expect(result, contains('case ReceivedExtract:'));
      expect(result, contains('case SentExtract:'));
      expect(
          result,
          contains(
              'return toJson<ReceivedExtract>(object as ReceivedExtract);'));
      expect(result,
          contains('return toJson<SentExtract>(object as SentExtract);'));
    });

    test('should generate correct OpenAPI schema for union types', () {
      // Arrange
      final mockSealedClass = MockClassElement(
        name: 'Extract',
        isSealed: true,
        constructors: [
          MockConstructorElement(
            isFactory: true,
            redirectedConstructor: MockConstructorElement(
              enclosingElement: MockClassElement(name: 'ReceivedExtract'),
            ),
          ),
          MockConstructorElement(
            isFactory: true,
            redirectedConstructor: MockConstructorElement(
              enclosingElement: MockClassElement(name: 'SentExtract'),
            ),
          ),
        ],
      );

      // Act
      final result = dtoSetup(mockSealedClass);

      // Assert
      expect(result, contains('"oneOf": ['));
      expect(result, contains('"discriminator": {'));
      expect(result, contains('"propertyName": "runtimeType"'));
      expect(result, contains('#/components/schemas/ReceivedExtract'));
      expect(result, contains('#/components/schemas/SentExtract'));
    });

    test('should detect class that implements sealed class', () {
      // Arrange - Mock de uma classe que implementa sealed class
      final mockInterface = MockInterfaceType(
        element: MockClassElement(name: 'Extract', isSealed: true),
      );

      final mockImplementingClass = MockClassElement(
        name: 'ReceivedExtract',
        isSealed: false,
        interfaces: [mockInterface],
      );

      // Act
      final result = dtoSetup(mockImplementingClass);

      // Assert - Deve adicionar runtimeType no toJson
      expect(result, contains("'runtimeType': 'ReceivedExtract'"));
    });

    test('should handle empty factory constructors gracefully', () {
      // Arrange
      final mockSealedClass = MockClassElement(
        name: 'EmptyUnion',
        isSealed: true,
        constructors: [],
      );

      // Act
      final result = dtoSetup(mockSealedClass);

      // Assert - Deve gerar estrutura básica mesmo sem subtipos
      expect(result, contains('fromJsonMap[EmptyUnion]'));
      expect(result, contains('toJsonMap[EmptyUnion]'));
      expect(result, contains('default:'));
      expect(result, contains('throw ArgumentError'));
    });
  });
}

// Mock classes para testes
class MockClassElement implements ClassElement, InterfaceElement {
  @override
  final String name;
  @override
  final bool isSealed;
  @override
  final List<ConstructorElement> constructors;
  @override
  final List<InterfaceType> interfaces;

  MockClassElement({
    required this.name,
    this.isSealed = false,
    this.constructors = const [],
    this.interfaces = const [],
  });

  // Implementações mínimas necessárias para o teste
  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError();
}

class MockConstructorElement implements ConstructorElement {
  @override
  final bool isFactory;
  @override
  final ConstructorElement? redirectedConstructor;
  final InterfaceElement? _enclosingElement;

  MockConstructorElement({
    this.isFactory = false,
    this.redirectedConstructor,
    InterfaceElement? enclosingElement,
  }) : _enclosingElement = enclosingElement;

  @override
  InterfaceElement get enclosingElement3 => _enclosingElement!;

  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError();
}

class MockInterfaceType implements InterfaceType {
  @override
  final InterfaceElement element;

  MockInterfaceType({required this.element});

  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError();
}
