library darter.exceptions;

class ParserError implements Exception {
  final message;

  ParserError([this.message]);

  String toString() {
    if (message == null) return "ParserError";
    return "ParserError: $message";
  }
}
