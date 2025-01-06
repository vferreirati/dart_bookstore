import 'dart:convert';

import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import 'package:zod_validation/zod_validation.dart';

import '../dto/create_book_request.dart';
import '../extensions/request_extension.dart';
import '../service/book_service.dart';

final _createBookRequest = {
  'title': Zod().min(1).max(255),
  'author': Zod().min(1).max(255),
  'price': Zod().type<int>().custom(
        (value) => value > 0,
        errorMessage: 'Price must be greater than 0',
      ),
};

class BookHandler {
  final BookService _bookService;

  BookHandler(this._bookService);

  Future<Response> getBookById(Request request) async {
    final bookId = int.tryParse(request.params['id'] ?? '');
    if (bookId == null) {
      return Response.badRequest(
        body: jsonEncode({'error': 'Invalid book ID'}),
        headers: {'Content-Type': 'application/json'},
      );
    }

    final book = await _bookService.getBookById(bookId);

    return Response.ok(
      jsonEncode(book.toJson()),
      headers: {'Content-Type': 'application/json'},
    );
  }

  Future<Response> getAllBooks(Request request) async {
    final books = await _bookService.getAllBooks(request.userId);

    return Response.ok(
      jsonEncode(books.map((book) => book.toJson()).toList()),
      headers: {'Content-Type': 'application/json'},
    );
  }

  Future<Response> createBook(Request request) async {
    final body = await request.readAsString();
    final json = jsonDecode(body);

    final zod = Zod.validate(data: json, params: _createBookRequest);
    if (zod.isNotValid) {
      return Response.badRequest(
        body: jsonEncode({
          'error': 'Invalid request',
          'params': zod.result,
        }),
        headers: {'Content-Type': 'application/json'},
      );
    }

    final createBookRequest = CreateBookRequest.fromJson(json);
    final userId = request.userId;

    final createdBook = await _bookService.createBook(
      createBookRequest,
      userId,
    );

    return Response.ok(
      jsonEncode(createdBook.toJson()),
      headers: {'Content-Type': 'application/json'},
    );
  }
}
