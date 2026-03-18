import 'package:example/src/dtos/order_dto.dart';
import 'package:example/src/enums/order_status.dart';
import 'package:vaden/vaden.dart';

@Api(tag: 'orders', description: 'Order operations')
@Controller('/orders')
class OrderController {
  @Get('/')
  List<OrderDto> getAll() {
    return [
      OrderDto(
        id: '1',
        status: OrderStatus.pending,
        history: [OrderStatus.pending],
      ),
    ];
  }

  @Get('/by-status/<status>')
  List<OrderDto> getByStatus(@Param() String status) {
    return [];
  }

  @Post('/')
  OrderDto create(@Body() OrderDto order) {
    return order;
  }
}
