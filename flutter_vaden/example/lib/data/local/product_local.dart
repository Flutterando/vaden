import 'package:flutter_example/models/product_model.dart';
import 'package:flutter_vaden/flutter_vaden.dart';

@LocalStorage()
abstract class ProductLocal {
  @StorageKey('products')
  @StorageObject()
  Future<List<ProductModel>> setProducts(List<ProductModel> products);

  @StorageKey('products')
  @StorageObject()
  Future<List<ProductModel>?> getProducts();

  @StorageKey('product')
  @StorageObject()
  Future<ProductModel> setProduct(ProductModel product);

  @StorageKey('product')
  @StorageObject()
  Future<ProductModel?> getProduct();

  @StorageKey('dark_mode')
  Future<void> setDarkMode(bool enabled);

  @StorageKey('dark_mode')
  Future<bool?> getDarkMode();
}
