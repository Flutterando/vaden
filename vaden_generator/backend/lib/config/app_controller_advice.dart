import 'dart:convert';

import 'package:dio/dio.dart' hide Response;
import 'package:vaden/vaden.dart';

@ControllerAdvice()
class AppControllerAdvice {
  final DSON _dson;
  AppControllerAdvice(this._dson);

  @ExceptionHandler(DioException)
  Future<Response> handleDioException(DioException e) async {
    return Response(
      e.response?.statusCode ?? 500,
      body: jsonEncode(
        {
          'message': e.response?.data['message'] ?? 'Internal server error',
        },
      ),
    );
  }

  @ExceptionHandler(ResponseException)
  Future<Response> handleResponseException(ResponseException e) async {
    return e.generateResponse(_dson);
  }

  @ExceptionHandler(Exception)
  Response handleException(Exception e) {
    return Response.internalServerError(
      body: jsonEncode(
        {
          'message': 'Internal server error',
        },
      ),
    );
  }
}
