class HandlerException extends Error {
  final int statusCode;
  final String message;

  HandlerException({
    required this.statusCode,
    required this.message,
  });
}

class NotFoundException extends HandlerException {
  NotFoundException({
    required super.message,
    super.statusCode = 404,
  });
}

class BadRequestException extends HandlerException {
  BadRequestException({
    required super.message,
    super.statusCode = 400,
  });
}

class UnauthorizedException extends HandlerException {
  UnauthorizedException({
    required super.message,
    super.statusCode = 401,
  });
}

class ForbiddenException extends HandlerException {
  ForbiddenException({
    required super.message,
    super.statusCode = 403,
  });
}

class InternalServerErrorException extends HandlerException {
  InternalServerErrorException({
    required super.message,
    super.statusCode = 500,
  });
}
