library darter.http.wrappers;

/**
 * Wraps a Response object.
 */
class Response {
  Object entity;
  String body;
  int statusCode;
  Map<String, String> headers = new Map<String, String>();

  Resposne() {
  }

  Response({this.body, this.statusCode}) {
  }

}

/**
 * Wraps a request object.
 */
class Request {
  String uri;
  String method;
  String body;
  Map<String, String> queryParameters;
  Map<String, String> headers;

  Request({this.uri, this.method, this.body});
}