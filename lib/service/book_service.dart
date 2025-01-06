import '../dto/create_book_request.dart';
import '../exceptions/handler_exception.dart';
import '../models/book.dart';
import '../repository/book_repository.dart';

class BookService {
  final BookRepository _bookRepository;

  BookService(this._bookRepository);

  Future<Book> getBookById(int id) async {
    final book = await _bookRepository.getBookById(id);
    if (book == null) {
      throw NotFoundException(message: 'Book not found');
    }

    return book;
  }

  Future<List<Book>> getAllBooks() async {
    return _bookRepository.getAllBooks();
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
