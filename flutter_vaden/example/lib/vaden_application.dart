// GENERATED CODE - DO NOT MODIFY BY HAND
// Aggregated Vaden application file
// ignore_for_file: prefer_function_declarations_over_variables, implementation_imports
import 'package:dio/dio.dart' as dioPackage;
import 'package:flutter_example/config/dio_configuration.dart';
import 'package:flutter_example/data/api/product_api.dart';
import 'package:flutter_example/models/product_model.dart';
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

    final configurationDioConfiguration = DioConfiguration();

    _injector.addLazySingleton(configurationDioConfiguration.dioFactory);

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
