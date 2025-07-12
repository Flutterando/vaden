import 'package:flutter_example/models/product_model.dart';
import 'package:flutter_vaden/flutter_vaden.dart';

@Preferences()
abstract class ProductLocal {
  @PrefKey('products')
  Future<List<ProductModel>> setProducts(List<ProductModel> products);

  @PrefKey('products')
  Future<List<ProductModel>?> getProducts();

  @PrefKey('product')
  Future<ProductModel> setProduct(ProductModel product);

  @PrefKey('product')
  Future<ProductModel?> getProduct();

  @PrefKey('dark_mode')
  Future<void> setDarkMode(bool enabled);

  @PrefKey('dark_mode')
  Future<bool?> getDarkMode();
}
