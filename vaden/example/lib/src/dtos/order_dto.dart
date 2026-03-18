import 'package:example/src/enums/order_status.dart';
import 'package:vaden/vaden.dart';

@DTO()
class OrderDto {
  final String id;
  final OrderStatus status;
  final List<OrderStatus> history;

  OrderDto({
    required this.id,
    required this.status,
    required this.history,
  });
}
