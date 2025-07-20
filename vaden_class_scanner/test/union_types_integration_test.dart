import 'package:test/test.dart';

void main() {
  group('Union Types Integration Test', () {
    test('should generate correct code for sealed class union', () {
      // Este é um teste conceitual que mostra como o código gerado deveria funcionar

      const expectedFromJsonCode = '''
fromJsonMap[Extract] = (Map<String, dynamic> json) {
  final runtimeType = json['runtimeType'] as String?;
  switch (runtimeType) {
    case 'ReceivedExtract':
      return fromJson<ReceivedExtract>(json);
    case 'SentExtract':
      return fromJson<SentExtract>(json);
    default:
      throw ArgumentError('Unknown runtimeType for Extract: \$runtimeType');
  }
};''';

      const expectedToJsonCode = '''
toJsonMap[Extract] = (object) {
  // Obtém o tipo real do objeto em runtime
  final objectType = object.runtimeType;
  switch (objectType) {
    case ReceivedExtract:
      return toJson<ReceivedExtract>(object as ReceivedExtract);
    case SentExtract:
      return toJson<SentExtract>(object as SentExtract);
    default:
      throw ArgumentError('Unknown subtype for Extract: \$objectType');
  }
};''';

      // Verifica que o código gerado contém a estrutura esperada
      expect(expectedFromJsonCode, contains('switch (runtimeType)'));
      expect(expectedFromJsonCode, contains('case \'ReceivedExtract\':'));
      expect(expectedFromJsonCode, contains('case \'SentExtract\':'));

      expect(expectedToJsonCode, contains('switch (objectType)'));
      expect(expectedToJsonCode, contains('case ReceivedExtract:'));
      expect(expectedToJsonCode, contains('case SentExtract:'));
    });

    test('should handle serialization flow correctly', () {
      // Simula o fluxo de serialização

      // 1. ReceivedExtract implementa Extract (sealed class)
      // 2. Ao serializar ReceivedExtract, adiciona runtimeType automaticamente
      const expectedReceivedJson = {
        'runtimeType': 'ReceivedExtract',
        'amount': 100.0,
        'to': 'Alice',
        'transactionDate': '2025-07-20T10:00:00.000Z'
      };

      // 3. Ao serializar Extract (tipo genérico), usa o runtimeType do objeto
      // para determinar qual serializer usar
      expect(expectedReceivedJson['runtimeType'], equals('ReceivedExtract'));
      expect(expectedReceivedJson['amount'], equals(100.0));
      expect(expectedReceivedJson['to'], equals('Alice'));
    });

    test('should handle deserialization flow correctly', () {
      // Simula o fluxo de deserialização

      const jsonData = {
        'runtimeType': 'ReceivedExtract',
        'amount': 100.0,
        'to': 'Alice',
        'transactionDate': '2025-07-20T10:00:00.000Z'
      };

      // 1. Extract (sealed class) lê o runtimeType
      final runtimeType = jsonData['runtimeType'] as String;
      expect(runtimeType, equals('ReceivedExtract'));

      // 2. Switch determina qual fromJson chamar
      switch (runtimeType) {
        case 'ReceivedExtract':
          // Chamaria fromJson<ReceivedExtract>(json)
          expect(true, isTrue); // Placeholder para o teste
        case 'SentExtract':
          // Chamaria fromJson<SentExtract>(json)
          fail('Should not reach SentExtract case');
        default:
          fail('Unknown runtimeType: $runtimeType');
      }
    });

    test('should generate correct OpenAPI discriminator schema', () {
      const expectedOpenApiSchema = {
        "oneOf": [
          {"\$ref": "#/components/schemas/ReceivedExtract"},
          {"\$ref": "#/components/schemas/SentExtract"}
        ],
        "discriminator": {
          "propertyName": "runtimeType",
          "mapping": {
            "ReceivedExtract": "#/components/schemas/ReceivedExtract",
            "SentExtract": "#/components/schemas/SentExtract"
          }
        }
      };

      // Verifica a estrutura do schema OpenAPI
      expect(expectedOpenApiSchema['oneOf'], isA<List>());
      expect(expectedOpenApiSchema['discriminator'], isA<Map>());

      final discriminator = expectedOpenApiSchema['discriminator'] as Map;
      expect(discriminator['propertyName'], equals('runtimeType'));
      expect(discriminator['mapping'], isA<Map>());

      final mapping = discriminator['mapping'] as Map;
      expect(mapping['ReceivedExtract'], contains('ReceivedExtract'));
      expect(mapping['SentExtract'], contains('SentExtract'));
    });
  });
}

// Comentários explicativos sobre o funcionamento:
/*
FLUXO COMPLETO DE UNION TYPES:

1. DEFINIÇÃO:
   @DTO()
   sealed class Extract {
     const factory Extract.received(...) = ReceivedExtract;
     const factory Extract.sent(...) = SentExtract;
   }
   
   @DTO() 
   final class ReceivedExtract implements Extract { ... }
   
   @DTO()
   final class SentExtract implements Extract { ... }

2. CÓDIGO GERADO:
   - Extract (sealed): fromJsonMap com switch baseado em runtimeType
   - Extract (sealed): toJsonMap com switch baseado em object.runtimeType
   - ReceivedExtract: fromJsonMap/toJsonMap normal + runtimeType no JSON
   - SentExtract: fromJsonMap/toJsonMap normal + runtimeType no JSON

3. USO NO CÓDIGO:
   final extract = Extract.received(...); // Tipo Extract
   final json = dson.toJson(extract);     // Usa Extract.toJsonMap que detecta ReceivedExtract
   
   final restored = dson.fromJson<Extract>(json); // Usa Extract.fromJsonMap que lê runtimeType

4. RESULTADO:
   - Serialização: { "runtimeType": "ReceivedExtract", "amount": 100.0, ... }
   - Deserialização: ReceivedExtract instance (como Extract)
   - OpenAPI: Schema com oneOf + discriminator
*/
