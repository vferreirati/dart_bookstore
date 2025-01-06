import 'dart:convert';

import 'package:shelf/shelf.dart';

import '../exceptions/handler_exception.dart';

Middleware errorHandlingMiddleware() {
  return (Handler innerHandler) {
    return (Request request) async {
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
    };
  };
}
