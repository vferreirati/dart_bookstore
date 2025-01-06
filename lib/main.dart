import 'dart:convert';

import 'package:postgres/postgres.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart';
import 'package:shelf_router/shelf_router.dart';

import 'handler/user_handler.dart';
import 'middlewares/error_handling_middleware.dart';
import 'middlewares/jwt_middleware.dart';
import 'migrations.dart';
import 'repository/user_repository.dart';
import 'service/user_service.dart';

void main() async {
  late Connection connection;
  try {
    connection = await connectToDatabase();
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

  const secret = 'secret';
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

Future<Connection> connectToDatabase() async {
  final endpoint = Endpoint(
    host: 'localhost',
    database: 'bookstore',
    username: 'bookstore',
    password: '123456',
  );

  return Connection.open(
    endpoint,
    settings: ConnectionSettings(
      sslMode: SslMode.disable,
    ),
  );
}
