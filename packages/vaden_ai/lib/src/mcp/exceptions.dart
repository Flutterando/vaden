import 'package:vaden/vaden.dart';

class VadenAiException implements Exception {
  final int code;
  final String massage;
  final dynamic data;

  VadenAiException.parseError({
    this.code = -32700,
    this.massage = 'Parse error',
    required this.data,
  });

  VadenAiException.invalidRequest({
    this.code = -32600,
    this.massage = 'Invalid Request',
    required this.data,
  });
  VadenAiException.methodNotFound({
    this.code = -32601,
    this.massage = 'Method not found',
    required this.data,
  });
  VadenAiException.invalidParams({
    this.code = -32602,
    this.massage = 'Invalid params',
    required this.data,
  });
  VadenAiException.internalError({
    this.code = -32603,
    this.massage = 'Internal error',
    required this.data,
  });
  VadenAiException.serverError({
    required this.code,
    this.massage = 'Server error',
    required this.data,
  }) : assert((code <= -32099 && code >= -32000));

  VadenAiException._fromJson({
    required this.code,
    required this.massage,
    required this.data,
  });
}

@Parse()
class VadenAiExceptionParse
    extends ParamParse<VadenAiException?, Map<String, dynamic>?> {
  const VadenAiExceptionParse();

  @override
  Map<String, dynamic>? toJson(VadenAiException? excption) {
    return excption == null
        ? null
        : {
            'code': excption.code,
            'message': excption.massage,
            'data': excption.data
          };
  }

  @override
  VadenAiException? fromJson(Map<String, dynamic>? json) {
    return json == null
        ? null
        : VadenAiException._fromJson(
            code: json['code'], massage: json['massage'], data: json['data']);
  }
}
