import 'package:postgres/postgres.dart';

typedef MigrationFunction = Future<void> Function(Connection connection);

class Migration {
  final String name;
  final MigrationFunction up;
  final MigrationFunction down;

  const Migration({
    required this.name,
    required this.up,
    required this.down,
  });
}

final migrations = <Migration>[
  Migration(
    name: 'Create users table',
    up: (Connection connection) async {
      await connection.execute('''
        CREATE TABLE users (
          id SERIAL PRIMARY KEY,
          email TEXT NOT NULL UNIQUE,
          password TEXT NOT NULL
        )
      ''');
    },
    down: (connection) async {
      await connection.execute('''
        DROP TABLE IF EXISTS users
      ''');
    },
  ),
  Migration(
    name: 'Create books table',
    up: (Connection connection) async {
      await connection.execute('''
        CREATE TABLE books (
          id SERIAL PRIMARY KEY,
          title TEXT NOT NULL,
          author TEXT NOT NULL,
          price NUMERIC NOT NULL,
          user_id INTEGER NOT NULL REFERENCES users(id)
        );
      ''');
    },
    down: (connection) async {
      await connection.execute('''
        DROP TABLE IF EXISTS books
      ''');
    },
  ),
];

Future<void> runMigrations(
  Connection connection,
) async {
  final migrationVersion = await _getCurrentMigrationVersion(connection);
  final migrationsToRun = migrations.sublist(migrationVersion);

  for (final migration in migrationsToRun) {
    print('Running ${migration.name}');
    try {
      await migration.up(connection);
      await connection.execute(
        Sql.named('INSERT INTO migrations (id) VALUES (@id)'),
        parameters: {'id': migrationVersion + 1},
      );
    } catch (e) {
      print('Failed to run ${migration.name}: $e');
      return;
    }

    print('Migration complete');
  }
}

Future<int> _getCurrentMigrationVersion(
  Connection connection,
) async {
  final res = await connection.execute('SELECT MAX(id) FROM migrations');
  return res.first.first as int;
}
