library darter.http.wrappers;

import 'dart:io';
import 'package:darter/src/annotations.dart';

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

  String toString() {
    return "Entity: ${entity}, Body: ${body}, StatusCode: ${statusCode}, Headers: ${headers}";
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

  String getMediaType() {
    String result = null;

    if (uri.endsWith('.json')) {
      result = MediaType.JSON;
    } else if (uri.endsWith('.xml')) {
      result = MediaType.XML;
    } else {
      String accept = headers[HttpHeaders.ACCEPT];
      if (accept.indexOf('application/json') > -1 || accept.indexOf('+json') > -1) {
        result = MediaType.JSON;
      } else if (accept.indexOf('application/xml') > -1 || accept.indexOf('+xml') > -1) {
        result = MediaType.XML;
      }
    }

    return result;
  }

  String toString() {
    return "Method: ${method}, URI: ${uri}";
  }
}