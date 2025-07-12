import 'package:flutter_example/models/product_model.dart';
import 'package:flutter_vaden/flutter_vaden.dart';

@Preferences()
abstract class ProductLocal {
  @PrefKey('products')
  @PrefObject()
  Future<List<ProductModel>> setProducts(List<ProductModel> products);

  @PrefKey('products')
  @PrefObject()
  Future<List<ProductModel>?> getProducts();

  @PrefKey('product')
  @PrefObject()
  Future<ProductModel> setProduct(ProductModel product);

  @PrefKey('product')
  @PrefObject()
  Future<ProductModel?> getProduct();

  @PrefKey('dark_mode')
  Future<void> setDarkMode(bool enabled);

  @PrefKey('dark_mode')
  Future<bool?> getDarkMode();
}
