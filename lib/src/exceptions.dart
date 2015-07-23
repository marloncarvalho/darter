library darter.exceptions;

class ParserError implements Exception {
  final message;

  ParserError([this.message]);

  String toString() {
    if (message == null) return "ParserError";
    return "ParserError: $message";
  }
}

class DarterException implements Exception {
  final message;

  DarterException([this.message]);

  String toString() {
    if (message == null) return "ParserError";
    return "ParserError: $message";
  }
}