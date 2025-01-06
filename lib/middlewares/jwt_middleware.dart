import 'dart:convert';

import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';
import 'package:shelf/shelf.dart';

import '../models/jwt_payload.dart';

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
