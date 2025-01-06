import 'dart:convert';

import 'package:postgres/postgres.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart';
import 'package:shelf_router/shelf_router.dart';
import 'package:dotenv/dotenv.dart';

import 'handler/user_handler.dart';
import 'middlewares/error_handling_middleware.dart';
import 'middlewares/jwt_middleware.dart';
import 'migrations.dart';
import 'repository/user_repository.dart';
import 'service/user_service.dart';

void main() async {
  final env = DotEnv()..load();

  late Connection connection;
  try {
    connection = await connectToDatabase(
      host: env['DATABASE_HOST']!,
      database: env['DATABASE_NAME']!,
      username: env['DATABASE_USER']!,
      password: env['DATABASE_PASSWORD']!,
    );
  } catch (e) {
    print('Failed to connect to database: $e');
    return;
  }

  try {
    runMigrations(connection);
  } catch (e) {
    print('Failed to run migrations: $e');
    return;
  }

  String secret = env['JWT_SECRET']!;
  final userHandler = UserHandler(UserService(UserRepository(connection)));

  final publicRouter = Router();
  publicRouter.post('/users', userHandler.createUser);
  publicRouter.post('/login', userHandler.login);
  publicRouter.get(
    '/ping',
    (Request request) => Response.ok(
      jsonEncode({'message': 'pong'}),
      headers: {'Content-Type': 'application/json'},
    ),
  );

  final authenticatedRouter = Router();
  authenticatedRouter.get('/users', userHandler.getUsers);

  final publicHandler = const Pipeline()
      .addMiddleware(errorHandlingMiddleware())
      .addHandler(publicRouter);

  final authenticatedHandler = const Pipeline()
      .addMiddleware(errorHandlingMiddleware())
      .addMiddleware(jwtMiddleware(secret))
      .addHandler(authenticatedRouter);

  final router = Cascade().add(publicHandler).add(authenticatedHandler).handler;

  final server = await serve(router, 'localhost', 3000);
  print('Server running on localhost:${server.port}');
}

Future<Connection> connectToDatabase({
  required String host,
  required String database,
  required String username,
  required String password,
}) async {
  final endpoint = Endpoint(
    host: host,
    database: database,
    username: username,
    password: password,
  );

  return Connection.open(
    endpoint,
    settings: ConnectionSettings(
      sslMode: SslMode.disable,
    ),
  );
}
