import 'package:dio/dio.dart';
import 'package:flutter_example/config/adapter.dart';
import 'package:flutter_vaden/flutter_vaden.dart';
import 'package:shared_preferences/shared_preferences.dart';

@Configuration()
class AppConfiguration {
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

  @Bean()
  ILocalStorage preferencesFactory() {
    final sharedPreferences = SharedPreferences.getInstance();
    return SharedPreferencesAdapter(sharedPreferences);
  }
}
