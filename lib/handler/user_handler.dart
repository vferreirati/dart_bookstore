import 'dart:convert';

import 'package:shelf/shelf.dart';
import 'package:zod_validation/zod_validation.dart';

import '../dto/create_user_request.dart';
import '../service/user_service.dart';

final _createUserRequest = {
  'name': Zod().min(4).max(100),
  'email': Zod().email(),
  'password': Zod().min(6).max(64),
};

final _loginRequest = {
  'email': Zod().email(),
  'password': Zod().min(6),
};

class UserHandler {
  final UserService _userService;

  UserHandler(
    this._userService,
  );

  Future<Response> getUsers(Request request) async {
    final users = await _userService.getUsers();

    return Response.ok(
      jsonEncode(users.map((user) => user.toJson()).toList()),
      headers: {'Content-Type': 'application/json'},
    );
  }

  Future<Response> createUser(Request request) async {
    final body = await request.readAsString();
    final json = jsonDecode(body);

    final zod = Zod.validate(data: json, params: _createUserRequest);
    if (zod.isNotValid) {
      return Response.badRequest(
        body: jsonEncode({
          'error': 'Invalid request',
          'params': zod.result,
        }),
        headers: {'Content-Type': 'application/json'},
      );
    }

    final createUserRequest = CreateUserRequest.fromJson(json);
    final createdUser = await _userService.createUser(createUserRequest);

    return Response.ok(
      jsonEncode(createdUser.toJson()),
      headers: {'Content-Type': 'application/json'},
    );
  }

  Future<Response> login(Request request) async {
    final body = await request.readAsString();
    final json = jsonDecode(body);

    final zod = Zod.validate(data: json, params: _loginRequest);
    if (zod.isNotValid) {
      return Response.badRequest(
        body: jsonEncode({
          'error': 'Invalid request',
          'params': zod.result,
        }),
        headers: {'Content-Type': 'application/json'},
      );
    }

    final email = json['email'];
    final password = json['password'];
    final result = await _userService.login(
      email,
      password,
    );

    return Response.ok(
      jsonEncode(result.toJson()),
      headers: {'Content-Type': 'application/json'},
    );
  }
}
