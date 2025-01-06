class CreateBookRequest {
  final String title;
  final String author;
  final int price;

  CreateBookRequest({
    required this.title,
    required this.author,
    required this.price,
  });

  factory CreateBookRequest.fromJson(Map<String, dynamic> json) {
    return CreateBookRequest(
      title: json['title'],
      author: json['author'],
      price: json['price'],
    );
  }
}
