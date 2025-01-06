class BookWithUser {
  final int id;
  final String title;
  final String author;
  final int price;
  final BookUser user;

  BookWithUser({
    required this.id,
    required this.title,
    required this.author,
    required this.price,
    required this.user,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'author': author,
      'price': price,
      'user': user.toJson(),
    };
  }
}

class BookUser {
  final int id;
  final String name;
  final String email;

  BookUser({
    required this.id,
    required this.name,
    required this.email,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
    };
  }
}
