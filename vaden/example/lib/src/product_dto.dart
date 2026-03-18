import 'package:example/src/enums/product_category.dart';
import 'package:vaden/vaden.dart';

@DTO()
class ProductDto {
  final String name;
  final double price;
  final ProductCategory category;

  ProductDto({
    required this.name,
    required this.price,
    required this.category,
  });
}
