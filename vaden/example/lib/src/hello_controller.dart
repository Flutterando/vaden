import 'dart:io';

import 'package:example/src/enums/product_category.dart';
import 'package:example/src/product_dto.dart';
import 'package:vaden/vaden.dart';

@Api(tag: 'hello')
@Controller('/hello/')
class HelloController {
  @Get('/ping')
  String ping() {
    return 'pong';
  }

  @Get()
  String empty() {
    return 'empty';
  }

  @Get('/map')
  Map<String, String> map() {
    return {'ping': 'pong'};
  }

  @Get('/maplist')
  List<Map<String, dynamic>> mapList() {
    return [
      {'ping': 'pong 1'},
      {'ping': 'pong 2'},
      {'ping': 'pong 3'},
    ];
  }

  @Get('/object')
  List<ProductDto> object() {
    return [
      ProductDto(name: 'Product 1', price: 100.0, category: ProductCategory.electronics),
      ProductDto(name: 'Product 2', price: 200.0, category: ProductCategory.clothing),
      ProductDto(name: 'Product 3', price: 300.0, category: ProductCategory.food),
    ];
  }

  @Get('/application.yaml')
  List<int> application() {
    return File('application.yaml').readAsBytesSync();
  }

  @Get('/exception')
  Response withException() {
    throw Exception('This is an exception');
  }

  @Get('/response-exception')
  Response withResponseException() {
    throw ResponseException(
      400,
      {'message': 'This is a response exception'},
    );
  }
}
