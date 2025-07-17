// GENERATED CODE - DO NOT MODIFY BY HAND
// Aggregated Vaden application file
// ignore_for_file: prefer_function_declarations_over_variables, implementation_imports
import 'package:flutter_example/config/dio_configuration.dart';
import 'package:flutter_example/models/product_model.dart';
import 'package:flutter_example/data/local/product_local.dart';
import 'package:flutter_example/data/api/product_api.dart';

import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart' as dioPackage;
import 'package:flutter_vaden/flutter_vaden.dart';

late final AutoInjector _injector;

class VadenApp extends FlutterVadenApplication {
  @override
  AutoInjector get injector => _injector;

  VadenApp({required super.child, AutoInjector? injector}) {
    _injector = injector ?? AutoInjector();
  }

  @override
  Future<void> setup() async {
    final asyncBeans = <Future<void> Function()>[];
    _injector.addLazySingleton<DSON>(_DSON.new);

    final configurationAppConfiguration = AppConfiguration();

    _injector.addLazySingleton(configurationAppConfiguration.dioFactory);
    _injector.addLazySingleton(
      configurationAppConfiguration.preferencesFactory,
    );

    _injector.addLazySingleton<ProductLocal>(_ProductLocal.new);

    _injector.addLazySingleton<ProductApi>(_ProductApi.new);

    _injector.commit();

    for (final asyncBean in asyncBeans) {
      await asyncBean();
    }
  }
}

class _DSON extends DSON {
  @override
  (
    Map<Type, FromJsonFunction>,
    Map<Type, ToJsonFunction>,
    Map<Type, ToOpenApiNormalMap>,
  )
  getMaps() {
    final fromJsonMap = <Type, FromJsonFunction>{};
    final toJsonMap = <Type, ToJsonFunction>{};
    final toOpenApiMap = <Type, ToOpenApiNormalMap>{};

    fromJsonMap[ProductModel] = (Map<String, dynamic> json) {
      return Function.apply(ProductModel.new, [json['nome']], {});
    };
    toJsonMap[ProductModel] = (object) {
      final obj = object as ProductModel;
      return {'nome': obj.nome};
    };
    toOpenApiMap[ProductModel] = {
      "type": "object",
      "properties": <String, dynamic>{
        "nome": {"type": "string"},
      },
      "required": ["nome"],
    };

    return (fromJsonMap, toJsonMap, toOpenApiMap);
  }
}

class _ProductApi implements ProductApi {
  final DSON dson;

  _ProductApi(this.dson);

  @override
  Future<List<ProductModel>> getTest() async {
    final dio = _injector.tryGet<dioPackage.Dio>() ?? dioPackage.Dio();
    final response = await dio.request(
      '/api/vi/users',
      options: dioPackage.Options(method: 'GET'),
    );
    return dson.fromJsonList<ProductModel>(response.data);
  }

  @override
  Future<ProductModel> getProduct(int id) async {
    final dio = _injector.tryGet<dioPackage.Dio>() ?? dioPackage.Dio();
    final response = await dio.request(
      '/product/$id',
      options: dioPackage.Options(method: 'GET'),
    );
    return dson.fromJson<ProductModel>(response.data);
  }

  @override
  Future<ProductModel> createProduct(ProductModel product) async {
    final dio = _injector.tryGet<dioPackage.Dio>() ?? dioPackage.Dio();
    final response = await dio.request(
      '/product',
      options: dioPackage.Options(method: 'POST'),
      data: dson.toJson<ProductModel>(product),
    );
    return dson.fromJson<ProductModel>(response.data);
  }

  @override
  Future<ProductModel> updateProduct(int id, ProductModel product) async {
    final dio = _injector.tryGet<dioPackage.Dio>() ?? dioPackage.Dio();
    final response = await dio.request(
      '/product/$id',
      options: dioPackage.Options(method: 'PUT'),
      data: dson.toJson<ProductModel>(product),
    );
    return dson.fromJson<ProductModel>(response.data);
  }

  @override
  Future<ProductModel> updateProducts(List<ProductModel> product) async {
    final dio = _injector.tryGet<dioPackage.Dio>() ?? dioPackage.Dio();
    final response = await dio.request(
      '/product',
      options: dioPackage.Options(method: 'PUT'),
      data: dson.toJsonList<ProductModel>(product),
    );
    return dson.fromJson<ProductModel>(response.data);
  }

  @override
  Future<void> deleteProduct(int id) async {
    final dio = _injector.tryGet<dioPackage.Dio>() ?? dioPackage.Dio();
    await dio.request(
      '/product/$id',
      options: dioPackage.Options(method: 'DELETE'),
    );
  }

  @override
  Future<List<ProductModel>> getAllProducts() async {
    final dio = _injector.tryGet<dioPackage.Dio>() ?? dioPackage.Dio();
    final response = await dio.request(
      '/products',
      options: dioPackage.Options(method: 'GET'),
    );
    return dson.fromJsonList<ProductModel>(response.data);
  }
}

class _ProductLocal implements ProductLocal {
  final DSON dson;
  _ProductLocal(this.dson);
  @override
  Future<List<ProductModel>> setProducts(List<ProductModel> products) async {
    final prefs = _injector.tryGet<ILocalStorage>();

    if (prefs == null) {
      throw Exception("ILocalStorage not found");
    }

    await prefs.setString(
      'products',
      json.encode(dson.toJsonList<ProductModel>(products)),
    );
    return products;
  }

  @override
  Future<List<ProductModel>?> getProducts() async {
    final prefs = _injector.tryGet<ILocalStorage>();

    if (prefs == null) {
      throw Exception("ILocalStorage not found");
    }

    final result = await prefs.getString('products');
    if (result == null || result.isEmpty) {
      return null;
    }
    return dson.fromJsonList<ProductModel>(json.decode(result));
  }

  @override
  Future<ProductModel> setProduct(ProductModel product) async {
    final prefs = _injector.tryGet<ILocalStorage>();

    if (prefs == null) {
      throw Exception("ILocalStorage not found");
    }

    await prefs.setString(
      'product',
      json.encode(dson.toJson<ProductModel>(product)),
    );
    return product;
  }

  @override
  Future<ProductModel?> getProduct() async {
    final prefs = _injector.tryGet<ILocalStorage>();

    if (prefs == null) {
      throw Exception("ILocalStorage not found");
    }

    final result = await prefs.getString('product');
    if (result == null || result.isEmpty) {
      return null;
    }
    return dson.fromJson<ProductModel?>(json.decode(result));
  }

  @override
  Future<void> setDarkMode(bool enabled) async {
    final prefs = _injector.tryGet<ILocalStorage>();

    if (prefs == null) {
      throw Exception("ILocalStorage not found");
    }

    await prefs.setBool('dark_mode', enabled);
  }

  @override
  Future<bool?> getDarkMode() async {
    final prefs = _injector.tryGet<ILocalStorage>();

    if (prefs == null) {
      throw Exception("ILocalStorage not found");
    }

    return await prefs.getBool('dark_mode');
  }
}
