import 'package:crypt/crypt.dart';
import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';

import '../dto/create_user_request.dart';
import '../exceptions/handler_exception.dart';
import '../models/auth_result.dart';
import '../models/jwt_payload.dart';
import '../models/user_without_password.dart';
import '../repository/user_repository.dart';

class UserService {
  final UserRepository _userRepository;

  UserService(
    this._userRepository,
  );

  Future<List<UserWithoutPassword>> getUsers() async {
    return _userRepository.getUsers();
  }

  Future<UserWithoutPassword> createUser(
    CreateUserRequest req,
  ) async {
    final existingUser = await _userRepository.getByEmail(req.email);
    if (existingUser != null) {
      throw BadRequestException(message: 'Email already exists');
    }
    final hashedPassword = Crypt.sha256(req.password).toString();

    final id = await _userRepository.createUser(
      req.name,
      req.email,
      hashedPassword,
    );

    return UserWithoutPassword(
      id: id,
      name: req.name,
      email: req.email,
    );
  }

  Future<AuthResult> login(
    String email,
    String password,
  ) async {
    final user = await _userRepository.getByEmail(email);
    if (user == null) {
      throw UnauthorizedException(message: 'Email or password is incorrect');
    }

    final matches = Crypt(user.password).match(password);
    if (!matches) {
      throw UnauthorizedException(message: 'Email or password is incorrect');
    }

    final jwt = JWT(
      JwtPayload(
        userId: user.id,
        email: user.email,
      ),
      issuer: 'dart-bookstore',
    );

    final token = jwt.sign(
      SecretKey('secret'),
      expiresIn: Duration(days: 1),
    );

    return AuthResult(
      token: token,
      expiry: DateTime.now().add(Duration(days: 1)).toIso8601String(),
      userId: user.id,
    );
  }
}
