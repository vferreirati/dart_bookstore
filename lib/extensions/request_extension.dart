import 'package:shelf/shelf.dart';

extension RequestExtension on Request {
  int get userId => context['userId'] as int? ?? 0;
  String get userEmail => context['email'] as String? ?? '';
}
