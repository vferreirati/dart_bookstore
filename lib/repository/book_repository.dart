import 'package:postgres/postgres.dart';

import '../models/book.dart';

class BookRepository {
  final Connection _connection;

  BookRepository(this._connection);

  Future<Book?> getBookById(int id) async {
    final res = await _connection.execute(
      Sql.named(
        'SELECT id, title, author, price, user_id FROM books WHERE id = @id',
      ),
      parameters: {'id': id},
    );

    if (res.isEmpty) {
      return null;
    }

    return Book.fromRow(res.first);
  }

  Future<List<Book>> getAllBooks() async {
    final res = await _connection.execute(
      'SELECT id, title, author, price, user_id FROM books',
    );

    return res.map(Book.fromRow).toList();
  }

  Future<int> createBook({
    required String title,
    required String author,
    required int price,
    required int userId,
  }) async {
    final res = await _connection.execute(
      Sql.named(
        'INSERT INTO books (title, author, price, user_id) VALUES (@title, @author, @price, @user_id) RETURNING id',
      ),
      parameters: {
        'title': title,
        'author': author,
        'price': price,
        'user_id': userId,
      },
    );

    return res.first[0] as int;
  }
}
