import 'package:vaden/vaden.dart';

enum ExtractType {
  credit,
  debit,
}

@DTO()
sealed class Extract {
  const factory Extract.received({
    required ExtractType type,
    required double amount,
    required DateTime transactionDate,
    required String to,
  }) = ReceivedExtract;

  const factory Extract.sent({
    ExtractType type,
    required double amount,
    required DateTime transactionDate,
    required String from,
  }) = SentExtract;
}

@DTO()
class ReceivedExtract implements Extract {
  final double amount;
  final ExtractType type;
  final DateTime transactionDate;
  final String to;

  const ReceivedExtract({
    required this.amount,
    required this.transactionDate,
    required this.to,
    required this.type,
  });
}

@DTO()
class SentExtract implements Extract {
  final double amount;
  final DateTime transactionDate;
  final String from;
  final ExtractType type;

  const SentExtract({
    required this.amount,
    required this.transactionDate,
    required this.from,
    this.type = ExtractType.debit,
  });
}
