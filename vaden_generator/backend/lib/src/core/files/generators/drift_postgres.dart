import 'dart:io';

import 'package:backend/src/core/files/file_generate.dart';
import 'package:backend/src/core/files/file_manager.dart';

/// Generator for Drift ORM with PostgreSQL integration.
///
/// This generator adds Drift dependencies, configuration files, and settings
/// to a Vaden project with PostgreSQL support.
class DriftPostgresGenerator extends FileGenerator {
  @override
  Future<void> generate(
    FileManager fileManager,
    Directory directory, {
    Map<String, dynamic> variables = const {},
  }) async {
    // Create Drift configuration file
    final libConfigDriftDriftConfiguration = File(
        '${directory.path}${Platform.pathSeparator}lib${Platform.pathSeparator}config${Platform.pathSeparator}drift${Platform.pathSeparator}drift_configuration.dart');
    await libConfigDriftDriftConfiguration.create(recursive: true);
    await libConfigDriftDriftConfiguration
        .writeAsString(_libConfigDriftDriftConfigurationContent);

    // Create example database file
    final libConfigDriftAppDatabase = File(
        '${directory.path}${Platform.pathSeparator}lib${Platform.pathSeparator}config${Platform.pathSeparator}drift${Platform.pathSeparator}app_database.dart');
    await libConfigDriftAppDatabase.create(recursive: true);
    await libConfigDriftAppDatabase
        .writeAsString(_libConfigDriftAppDatabaseContent);

    // Add Drift dependencies to pubspec.yaml
    final pubspec =
        File('${directory.path}${Platform.pathSeparator}pubspec.yaml');
    await fileManager.insertLineInFile(
      pubspec,
      RegExp(r'^dependencies:$'),
      parseVariables('  drift: {{drift}}', variables),
    );
    await fileManager.insertLineInFile(
      pubspec,
      RegExp(r'^dependencies:$'),
      parseVariables('  drift_postgres: {{drift_postgres}}', variables),
    );

    // Add dev dependencies
    await fileManager.insertLineInFile(
      pubspec,
      RegExp(r'^dev_dependencies:$'),
      parseVariables('  drift_dev: {{drift_dev}}', variables),
    );

    // Add Drift configuration to application.yaml
    final application =
        File('${directory.path}${Platform.pathSeparator}application.yaml');
    await fileManager.insertLineInFile(
      position: InsertLinePosition.before,
      application,
      RegExp(r'^server:$'),
      'drift:',
    );
    await fileManager.insertLineInFile(
      application,
      RegExp(r'^drift:$'),
      '  log_statements: true',
    );
  }
}

const _libConfigDriftDriftConfigurationContent =
    '''import 'package:drift/drift.dart';
import 'package:vaden/vaden.dart';
import 'package:postgres/postgres.dart' as pg;

import 'app_database.dart';

@Configuration()
class DriftConfiguration {
  @Bean()
  AppDatabase appDatabase(
    pg.Connection postgresConnection,
    ApplicationSettings settings,
  ) {
    final logStatements = settings['drift']['log_statements'] == 'true';
    
    return AppDatabase(
      postgresConnection,
      logStatements: logStatements,
    );
  }
  
  void closeDatabase(AppDatabase database) {
    database.close();
  }
}
''';

const _libConfigDriftAppDatabaseContent = '''import 'package:drift/drift.dart';
import 'package:drift_postgres/drift_postgres.dart';
import 'package:postgres/postgres.dart' as pg;

part 'app_database.g.dart';

// Example table definition
// class Users extends Table {
//   IntColumn get id => integer().autoIncrement()();
//   TextColumn get name => text().withLength(min: 1, max: 50)();
//   TextColumn get email => text().unique()();
//   DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
// }

@DriftDatabase(tables: [])
class AppDatabase extends _\$AppDatabase {
  final pg.Connection _connection;
  
  AppDatabase(
    this._connection, {
    bool logStatements = false,
  }) : super(
          PgDatabase(
            endpoint: _connection.endpoint,
            settings: _connection.settings,
            logStatements: logStatements,
          ),
        );

  @override
  int get schemaVersion => 1;

  // Example migration
  // @override
  // MigrationStrategy get migration {
  //   return MigrationStrategy(
  //     onCreate: (Migrator m) async {
  //       await m.createAll();
  //     },
  //     onUpgrade: (Migrator m, int from, int to) async {
  //       // Run migration steps
  //     },
  //   );
  // }
}
''';
