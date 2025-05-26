import 'dart:io';

import 'package:backend/src/core/files/file_generate.dart';
import 'package:backend/src/core/files/file_manager.dart';

class EmailSendgridGenerator extends FileGenerator {
  @override
  Future<void> generate(
    FileManager fileManager,
    Directory directory, {
    Map<String, dynamic> variables = const {},
  }) async {
    final libConfigEmailSendgridEmailConfiguration = File(
        '${directory.path}${Platform.pathSeparator}lib${Platform.pathSeparator}config${Platform.pathSeparator}email_sendgrid${Platform.pathSeparator}email_configuration.dart');
    await libConfigEmailSendgridEmailConfiguration.create(recursive: true);
    await libConfigEmailSendgridEmailConfiguration
        .writeAsString(_libConfigEmailSendgridEmailConfiguration);

    final libConfigEmailSendgrideEmailEntity = File(
        '${directory.path}${Platform.pathSeparator}lib${Platform.pathSeparator}config${Platform.pathSeparator}email_sendgrid${Platform.pathSeparator}email_entity.dart');
    await libConfigEmailSendgrideEmailEntity.create(recursive: true);
    await libConfigEmailSendgrideEmailEntity
        .writeAsString(_libConfigEmailSendgrideEmailEntity);

    final libConfigEmailSendgrideEmailService = File(
        '${directory.path}${Platform.pathSeparator}lib${Platform.pathSeparator}config${Platform.pathSeparator}email_sendgrid${Platform.pathSeparator}email_service.dart');
    await libConfigEmailSendgrideEmailService.create(recursive: true);
    await libConfigEmailSendgrideEmailService
        .writeAsString(_libConfigEmailSendgrideEmailService);

    final application =
        File('${directory.path}${Platform.pathSeparator}application.yaml');
    await fileManager.insertLineInFile(
      position: InsertLinePosition.before,
      application,
      RegExp(r'^server:$'),
      'emailSendgrid:',
    );
    await fileManager.insertLineInFile(
      application,
      RegExp(r'^emailSendgrid:$'),
      '',
    );
    await fileManager.insertLineInFile(
      application,
      RegExp(r'^emailSendgrid:$'),
      '  token: token',
    );
    await fileManager.insertLineInFile(
      application,
      RegExp(r'^emailSendgrid:$'),
      '  fromEmail: email@email.com.br',
    );
    await fileManager.insertLineInFile(
      application,
      RegExp(r'^emailSendgrid:$'),
      '  fromName: Name',
    );
  }
}

const _libConfigEmailSendgridEmailConfiguration =
    '''import 'package:backend/config/email/email_service.dart';
import 'package:dio/dio.dart';
import 'package:vaden/vaden.dart';

@Configuration()
class EmailConfiguration {
  @Bean()
  EmailService emailService(Dio dio, ApplicationSettings settings) {
    return EmailService(
      fromEmail: settings['emailSendgrid']['fromEmail'],
      fromName: settings['emailSendgrid']['fromName'],
      settings: settings,
      dio: dio,
    );
  }
}
''';

const _libConfigEmailSendgrideEmailEntity = '''class Email {
  final String addressee;
  final String recipientName;
  final String title;
  final String? emailBody;
  final String? templateId;
  final Map<String, dynamic>? templateData;

  Email.text({
    required this.addressee,
    required this.recipientName,
    required this.title,
    required this.emailBody,
  })  : templateId = null,
        templateData = null;

  Email.template({
    required this.addressee,
    required this.recipientName,
    required this.title,
    required this.templateId,
    this.templateData,
  }) : emailBody = null;

  Map<String, dynamic> _personalizationsMap() {
    Map<String, dynamic> returnMap = {
      "to": [
        {"email": addressee, "name": recipientName},
      ],
      "subject": title,
    };

    if (templateData != null) {
      returnMap['dynamic_template_data'] = templateData;
    }

    return returnMap;
  }

  Map<String, dynamic> toMap(
      {required String fromEmail, required String fromName}) {
    Map<String, dynamic> returnMap = {
      "from": {"email": fromEmail, "name": fromName},
      "personalizations": [_personalizationsMap()],
    };
    if (emailBody != null) {
      returnMap['content'] = [
        {"type": "text/plain", "value": emailBody},
      ];
    }
    if (templateId != null) {
      returnMap['template_id'] = templateId;
    }

    return returnMap;
  }
}
''';

const _libConfigEmailSendgrideEmailService =
    r'''import 'package:backend/config/email/email_entity.dart';
import 'package:dio/dio.dart' as client;
import 'package:result_dart/result_dart.dart';
import 'package:vaden/vaden.dart';

class EmailService {
  final String fromEmail;
  final String fromName;
  final ApplicationSettings settings;
  final client.Dio dio;
  EmailService({
    required this.fromEmail,
    required this.fromName,
    required this.settings,
    required this.dio,
  });

  AsyncResult<Unit> send(Email email) async {
    try {
      final response = await dio.post(
        'https://api.sendgrid.com/v3/mail/send',
        data: email.toMap(fromEmail: fromEmail, fromName: fromName),
        options: client.Options(
          headers: {
            'Authorization': 'Bearer ${settings['emailSendgrid']['token']}',
            'Content-Type': 'application/json',
          },
          responseType: client.ResponseType.json,
          receiveTimeout: const Duration(seconds: 5),
          sendTimeout: const Duration(seconds: 5),
        ),
      );

      if (response.statusCode == 202) {
        return Success(unit);
      }
      return Failure(Exception('Email not send'));
    } on client.DioException catch (e) {
      return Failure(e);
    }
  }
}
''';
