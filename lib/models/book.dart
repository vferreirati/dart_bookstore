class Book {
  final int id;
  final String title;
  final String author;
  final int price;
  final int userId;

  Book({
    required this.id,
    required this.title,
    required this.author,
    required this.price,
    required this.userId,
  });

  factory Book.fromRow(List<dynamic> row) {
    return Book(
      id: row[0] as int,
      title: row[1] as String,
      author: row[2] as String,
      price: row[3] as int,
      userId: row[4] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'author': author,
      'price': price,
      'userId': userId,
    };
  }
}
