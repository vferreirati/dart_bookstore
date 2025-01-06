import '../dto/create_book_request.dart';
import '../exceptions/handler_exception.dart';
import '../models/book.dart';
import '../models/book_with_user.dart';
import '../repository/book_repository.dart';

class BookService {
  final BookRepository _bookRepository;

  BookService(this._bookRepository);

  Future<BookWithUser> getBookById(int id) async {
    final book = await _bookRepository.getBookById(id);
    if (book == null) {
      throw NotFoundException(message: 'Book not found');
    }

    return book;
  }

  Future<List<Book>> getAllBooks(
    int userId,
  ) async {
    return _bookRepository.getAllBooks(userId);
  }

  Future<Book> createBook(
    CreateBookRequest request,
    int userId,
  ) async {
    final id = await _bookRepository.createBook(
      title: request.title,
      author: request.author,
      price: request.price,
      userId: userId,
    );

    return Book(
      id: id,
      title: request.title,
      author: request.author,
      price: request.price,
      userId: userId,
    );
  }
}
