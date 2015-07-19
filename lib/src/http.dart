library darter.http.wrappers;

import 'dart:io';

/**
 * Wraps a Response object.
 */
class Response {
  Object entity;
  String body;
  int statusCode;
  Map<String, String> headers = new Map<String, String>();

  Response({this.body, this.statusCode, this.entity, this.headers});

  String getContentType() {
    return headers[HttpHeaders.CONTENT_TYPE];
  }

  void setContentType(String value) {
    headers[HttpHeaders.CONTENT_TYPE] = value;
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
  Map<String, String> headers = new Map<String, String>();

  Request({this.uri, this.method, this.body});
}