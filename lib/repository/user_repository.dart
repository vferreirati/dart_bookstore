import 'package:postgres/postgres.dart';

import '../models/user.dart';
import '../models/user_without_password.dart';

class UserRepository {
  final Connection _connection;

  UserRepository(
    this._connection,
  );

  Future<List<UserWithoutPassword>> getUsers() async {
    final res = await _connection.execute(
      'SELECT u.id, u.name, u.email FROM users u',
    );

    return res.map(UserWithoutPassword.fromRow).toList();
  }

  Future<int> createUser(String name, String email, String password) async {
    final res = await _connection.execute(
      Sql.named(
        'INSERT INTO users (name, email, password) VALUES (@name, @email, @password) RETURNING ID',
      ),
      parameters: {
        'name': name,
        'email': email,
        'password': password,
      },
    );

    return res.first[0] as int;
  }

  Future<User?> getByEmail(
    String email,
  ) async {
    final res = await _connection.execute(
      Sql.named(
          'SELECT u.id, u.name, u.email, u.password FROM users u WHERE u.email = @email'),
      parameters: {
        'email': email,
      },
    );

    if (res.isEmpty) {
      return null;
    }

    return User.fromRow(res.first);
  }
}
