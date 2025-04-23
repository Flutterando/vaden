import 'dart:convert';
import 'dart:io';

import 'package:backend/src/domain/entities/dependency.dart';
import 'package:backend/src/domain/repositories/dependency_repository.dart';
import 'package:result_dart/result_dart.dart';
import 'package:vaden/vaden.dart';

@Repository()
class DependencyRepositoryImpl implements DependencyRepository {
  final DSON dson;

  final List<Dependency> _dependencies = [];

  DependencyRepositoryImpl(this.dson);

  @override
  AsyncResult<List<Dependency>> getDependencies() async {
    if (_dependencies.isNotEmpty) {
      return Success(_dependencies);
    }

    final file = File('assets${Platform.pathSeparator}dependencies.json');

    if (!file.existsSync()) {
      return Failure(
        ResponseException(
          404,
          {'message': 'Dependencies file not found'},
        ),
      );
    }

    final content = await file.readAsString();
    final dependencies = List<Map<String, dynamic>>.from(jsonDecode(content));

    _dependencies.addAll(dson.fromJsonList<Dependency>(dependencies));

    return Success(_dependencies);
  }
}
