import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:vaden/vaden.dart';

part 'drift_configuration.g.dart';

class TodoTable extends Table {
  late final id = integer().autoIncrement()();
  late final title = text()();
  late final check = boolean().withDefault(const Constant(false))();
}

@DriftDatabase(tables: [TodoTable])
class AppDatabase extends _$AppDatabase {
  AppDatabase(super.e);

  @override
  int get schemaVersion => 1;
}

@Configuration()
class DriftConfiguration {
  @Bean()
  AppDatabase appDatabaseCreate() {
    final queryExecutor =
        NativeDatabase.createInBackground(File('./database.sqlite'));
    return AppDatabase(queryExecutor);
  }
}
