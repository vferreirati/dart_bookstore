import 'package:postgres/postgres.dart';

import '../models/book.dart';
import '../models/book_with_user.dart';

class BookRepository {
  final Connection _connection;

  BookRepository(this._connection);

  Future<BookWithUser?> getBookById(int id) async {
    final row = await _connection.execute(
      Sql.named('''
        SELECT 
          b.id AS book_id, 
          b.title AS book_title, 
          b.author AS book_author, 
          b.price AS book_price, 
          u.id AS user_id,
          u.name AS user_name,
          u.email AS user_email 
        FROM books b
        JOIN users u ON b.user_id = u.id 
        WHERE b.id = @id
    '''),
      parameters: {'id': id},
    );

    if (row.isEmpty) {
      return null;
    }

    final map = row.first.toColumnMap();

    return BookWithUser(
      id: map['book_id'] as int,
      title: map['book_title'] as String,
      author: map['book_author'] as String,
      price: map['book_price'] as int,
      user: BookUser(
        id: map['user_id'] as int,
        name: map['user_name'] as String,
        email: map['user_email'] as String,
      ),
    );
  }

  Future<List<Book>> getAllBooks(
    int userId,
  ) async {
    final res = await _connection.execute(
      Sql.named('''
        SELECT id, title, author, price, user_id
        FROM books
        WHERE user_id = @user_id
      '''),
      parameters: {
        'user_id': userId,
      },
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
