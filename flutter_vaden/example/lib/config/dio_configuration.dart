import 'package:dio/dio.dart';
import 'package:flutter_vaden/flutter_vaden.dart';

@Configuration()
class DioConfiguration {
  @Bean()
  Dio dioFactory() {
    final dio = Dio();
    dio.options.baseUrl = 'https://60aa948c66f1d00017772ffb.mockapi.io';
    dio.interceptors.add(
      LogInterceptor(
        request: true,
        responseBody: true,
        requestBody: true,
        error: true,
      ),
    );
    return dio;
  }
}
