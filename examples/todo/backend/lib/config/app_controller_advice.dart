import 'dart:convert';

import 'package:vaden/vaden.dart';

@ControllerAdvice()
class AppControllerAdvice {
  final DSON _dson;
  AppControllerAdvice(this._dson);

  @ExceptionHandler(ResponseException)
  Future<Response> handleResponseException(ResponseException e) async {
    return e.generateResponse(_dson);
  }

  @ExceptionHandler(Exception)
  Response handleException(Exception e) {
    return Response.internalServerError(
      body: jsonEncode({
        'message': 'Internal server error',
      }),
    );
  }
}