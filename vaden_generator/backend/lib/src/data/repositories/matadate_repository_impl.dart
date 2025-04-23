import 'dart:convert';
import 'dart:io';

import 'package:backend/src/domain/entities/metadata.dart';
import 'package:backend/src/domain/repositories/matadate_repository.dart';
import 'package:result_dart/result_dart.dart';
import 'package:vaden/vaden.dart';

@Repository()
class MatadateRepositoryImpl implements MatadateRepository {
  final DSON dson;
  final ApplicationSettings settings;

  Metadata? _metadata;

  MatadateRepositoryImpl(this.dson, this.settings);

  @override
  AsyncResult<Metadata> getMetadata() async {
    if (_metadata != null) {
      return Success(_metadata!);
    }
    final file = File('assets${Platform.pathSeparator}metadata.json');

    if (!file.existsSync()) {
      return Failure(
        ResponseException(
          404,
          {'message': 'Metadata file not found'},
        ),
      );
    }

    final content = await file.readAsString();
    final metadataJson = jsonDecode(content);

    final matadata = dson.fromJson<Metadata>(metadataJson);

    _metadata = matadata;

    return Success(matadata);
  }
}
