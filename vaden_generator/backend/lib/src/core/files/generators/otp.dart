import 'dart:io';

import 'package:backend/src/core/files/file_generate.dart';
import 'package:backend/src/core/files/file_manager.dart';

class OtpGenerator extends FileGenerator {
  @override
  Future<void> generate(
    FileManager fileManager,
    Directory directory, {
    Map<String, dynamic> variables = const {},
  }) async {
    final libConfigOtpOtpConfiguration = File(
        '${directory.path}${Platform.pathSeparator}lib${Platform.pathSeparator}config${Platform.pathSeparator}otp${Platform.pathSeparator}otp_configuration.dart');
    await libConfigOtpOtpConfiguration.create(recursive: true);
    await libConfigOtpOtpConfiguration
        .writeAsString(_libConfigOtpOtpConfiguration);

    final libConfigOtpOtpSender = File(
        '${directory.path}${Platform.pathSeparator}lib${Platform.pathSeparator}config${Platform.pathSeparator}otp${Platform.pathSeparator}otp_sender.dart');
    await libConfigOtpOtpSender.create(recursive: true);
    await libConfigOtpOtpSender.writeAsString(_libConfigOtpOtpSender);

    final libConfigOtpOtpService = File(
        '${directory.path}${Platform.pathSeparator}lib${Platform.pathSeparator}config${Platform.pathSeparator}otp${Platform.pathSeparator}otp_service.dart');
    await libConfigOtpOtpService.create(recursive: true);
    await libConfigOtpOtpService.writeAsString(_libConfigOtpOtpService);
  }
}

const _libConfigOtpOtpConfiguration =
    '''import 'package:backend/config/otp/otp_sender.dart';
import 'package:backend/config/otp/otp_service.dart';
import 'package:redis/redis.dart';
import 'package:vaden/vaden.dart';

@Configuration()
class OtpConfiguration {
  @Bean()
  OtpService otpService(Command redis, OtpSender otpSender) {
    return OtpService(redis: redis, sender: otpSender);
  }

  // Example using sendgrid email service
  /* @Bean()
  OtpSender otpSender(EmailService emailService, ApplicationSettings settings) {
    return EmailOtpSender(
        title: 'Title',
        settings: settings,
        emailService: emailService);
  } */
}
''';

const _libConfigOtpOtpSender =
    r'''import 'package:result_dart/result_dart.dart';

abstract interface class OtpSender {
  AsyncResult<Unit> sendOtp(
      {required String id, required String code, Map<String, dynamic>? map});
}

// Example using sendgrid email service
/* class EmailOtpSender implements OtpSender {
  final String title;
  final ApplicationSettings settings;
  final EmailService emailService;

  EmailOtpSender({
    required this.title,
    required this.settings,
    required this.emailService,
  });

  @override
  AsyncResult<Unit> sendOtp(
      {required Map<String, dynamic> map, required String code}) async {
    final Email email = Email.text(
      addressee: map['email'] ?? '',
      recipientName: map['name'] ?? '',
      title: title,
      emailBody: 'The code is $code',
    );

    return emailService.send(email);
  }
} */
''';

const _libConfigOtpOtpService = r'''import 'dart:math';

import 'package:backend/config/otp/otp_sender.dart';
import 'package:redis/redis.dart';
import 'package:result_dart/result_dart.dart';
import 'package:vaden/vaden.dart';

class OtpService {
  final Command redis;
  final OtpSender sender;

  OtpService({
    required this.redis,
    required this.sender,
  });

  String key(String context, String id) => 'otp:$context:$id';

  AsyncResult<Unit> statusOtp({
    required String context,
    required String username,
  }) {
    return _validationRequest(key(context, username));
  }

  AsyncResult<Unit> sendOtp(
      {required String context,
      required String id,
      Map<String, dynamic>? map}) {
    // ignore: no_leading_underscores_for_local_identifiers
    final _key = key(context, id);
    return _validationRequest(_key) //
        .flatMap((_) => Success(_codeGenerator(4)))
        .flatMap((code) => _setCode(code, _key))
        .flatMap((code) => sender.sendOtp(id: id, code: code, map: map));
  }

  AsyncResult<Unit> checkOtp({
    required String context,
    required String id,
    required String code,
  }) {
    return _getCode(key(context, id)) //
        .flatMap((verification) => _validateCode(verification, code))
        .flatMap((_) => _deleteCode(key(context, id)));
  }

  String _codeGenerator(int digits) {
    final random = Random();

    int min = pow(10, digits - 1).toInt();
    int max = pow(10, digits).toInt() - 1;

    return '${min + random.nextInt(max - min)}';
  }

  Result<Unit> _validateCode(String verification, String code) {
    if (code == verification) {
      return Success(unit);
    }
    return Failure(ResponseException.unauthorized('Invalid code'));
  }

  AsyncResult<String> _getCode(String key) async {
    try {
      final String? result = await redis.send_object(["GET", key]);
      if (result == null) {
        return Failure(
            ResponseException.badRequest('User request unavailable'));
      }
      return Success(result);
    } catch (e) {
      print('OtpService erro: $e');
      return Failure(e is Exception ? e : Exception(e));
    }
  }

  AsyncResult<String> _setCode(String code, String key) async {
    try {
      await redis.send_object(["SET", key, code]);
      await redis.send_object(["EXPIRE", key, "240"]);
      return Success(code);
    } catch (e) {
      print('OtpService erro: $e');
      return Failure(e is Exception ? e : Exception(e));
    }
  }

  AsyncResult<Unit> _deleteCode(String key) async {
    try {
      await redis.send_object(['DEL', key]);
      return Success(unit);
    } catch (e) {
      print('OtpService erro: $e');
      return Failure(e is Exception ? e : Exception(e));
    }
  }

  AsyncResult<Unit> _validationRequest(String key) async {
    try {
      final ttl = await redis.send_object(["TTL", key]);
      if (ttl is int && ttl > 120) {
        return Failure(ResponseException.notAcceptable(
            'The request was sent to fewer than two minutes'));
      }
      return Success(unit);
    } catch (e) {
      print('OtpService erro: $e');
      return Failure(e is Exception ? e : Exception(e));
    }
  }
}
''';
