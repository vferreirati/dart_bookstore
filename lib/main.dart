import 'dart:convert';

import 'package:dart_bookstore/exceptions/handler_exception.dart';
import 'package:dart_bookstore/handler/user_handler.dart';
import 'package:dart_bookstore/migrations.dart';
import 'package:dart_bookstore/models/jwt_payload.dart';
import 'package:dart_bookstore/repository/user_repository.dart';
import 'package:dart_bookstore/service/user_service.dart';
import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';
import 'package:postgres/postgres.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart';
import 'package:shelf_router/shelf_router.dart';

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
  publicRouter.post(
    '/users',
    (req) => safeEndpoint(req, userHandler.createUser),
  );
  publicRouter.post(
    '/login',
    (req) => safeEndpoint(req, userHandler.login),
  );
  publicRouter.get(
    '/ping',
    (Request request) => Response.ok(
      jsonEncode({'message': 'pong'}),
      headers: {'Content-Type': 'application/json'},
    ),
  );

  final authenticatedRouter = Router();
  authenticatedRouter.get(
    '/users',
    (req) => safeEndpoint(req, userHandler.getUsers),
  );

  final publicHandler = const Pipeline().addHandler(publicRouter);
  final authenticatedHandler = const Pipeline()
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

Future<Response> safeEndpoint(
  Request request,
  Handler innerHandler,
) async {
  try {
    return await innerHandler(request);
  } catch (e) {
    if (e is HandlerException) {
      return Response(
        e.statusCode,
        body: jsonEncode({'message': e.message}),
        headers: {'Content-Type': 'application/json'},
      );
    }

    print(e);

    return Response.internalServerError(
      body: jsonEncode({'message': 'Internal server error'}),
      headers: {'Content-Type': 'application/json'},
    );
  }
}

Middleware jwtMiddleware(String secret) {
  return (Handler innerHandler) {
    return (Request request) async {
      final authHeader = request.headers['Authorization'];
      if (authHeader == null || !authHeader.startsWith('Bearer ')) {
        return Response.forbidden(
          jsonEncode({'message': 'Missing or invalid Authorization header'}),
          headers: {'Content-Type': 'application/json'},
        );
      }

      final token = authHeader.substring(7);
      try {
        final jwt = JWT.verify(token, SecretKey(secret));
        final payload = JwtPayload.fromJson(jwt.payload);
        request = request.change(
          context: {
            'jwt': jwt,
            'userId': payload.userId,
            'email': payload.email,
          },
        );
        return await innerHandler(request);
      } catch (e) {
        return Response.forbidden(
          jsonEncode({'message': 'Invalid token'}),
          headers: {'Content-Type': 'application/json'},
        );
      }
    };
  };
}
