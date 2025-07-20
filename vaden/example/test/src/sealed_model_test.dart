import 'package:example/src/sealed_model.dart';
import 'package:example/vaden_application.dart';
import 'package:test/test.dart';
import 'package:vaden/vaden.dart';

void main() {
  test('sealed model ', () async {
    final app = VadenApp();

    await app.setup();

    final dson = app.injector.get<DSON>();

    final received = Extract.received(
      type: ExtractType.credit,
      amount: 100.0,
      transactionDate: DateTime.now(),
      to: 'Alice',
    );

    final sent = Extract.sent(
      amount: 50.0,
      transactionDate: DateTime.now(),
      from: 'Bob',
    );

    final receivedJson = dson.toJson(received);
    final sentJson = dson.toJson(sent);

    expect(receivedJson['runtimeType'], 'ReceivedExtract');
    expect(receivedJson['amount'], 100.0);
    expect(receivedJson['transactionDate'],
        (received as ReceivedExtract).transactionDate.toIso8601String());
    expect(receivedJson['to'], 'Alice');
    expect(receivedJson['type'], 'credit');

    expect(sentJson['runtimeType'], 'SentExtract');
    expect(sentJson['amount'], 50.0);
    expect(sentJson['transactionDate'],
        (sent as SentExtract).transactionDate.toIso8601String());
    expect(sentJson['from'], 'Bob');
    expect(sentJson['type'], 'debit');

    final receivedFromJson = dson.fromJson<Extract>(receivedJson);
    final sentFromJson = dson.fromJson<Extract>(sentJson);

    expect(receivedFromJson, isA<ReceivedExtract>());
    expect((receivedFromJson as ReceivedExtract).amount, 100.0);
    expect(receivedFromJson.transactionDate, received.transactionDate);
    expect(receivedFromJson.to, 'Alice');
    expect(receivedFromJson.type, ExtractType.credit);

    expect(sentFromJson, isA<SentExtract>());
    expect((sentFromJson as SentExtract).amount, 50.0);
    expect(sentFromJson.transactionDate, sent.transactionDate);
    expect(sentFromJson.from, 'Bob');
    expect(sentFromJson.type, ExtractType.debit);
  });
}
