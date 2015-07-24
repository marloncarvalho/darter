library darter.http.wrappers;

import 'dart:io' as io;
import 'dart:async';
import 'package:darter/src/annotations.dart';
import 'package:shelf/shelf.dart' as shelf;
import 'dart:convert' show UTF8;

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
    return headers[io.HttpHeaders.CONTENT_TYPE];
  }

  void setContentType(String value) {
    headers[io.HttpHeaders.CONTENT_TYPE] = value;
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

  String get urlNoExtension {
    return uri.replaceAll("\.json", "").replaceAll("\.xml", "");
  }

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

/**
 * Responsible to build Darter request objects using as model the
 * request object that comes from the underlying http server.
 */
abstract class RequestBuilder {
  static ShelfRequestBuilder _shelf = new ShelfRequestBuilder();
  static IORequestBuilder _io = new IORequestBuilder();

  /**
   * Build the Darter request object.
   */
  Future<Request> build(dynamic request);

  /**
   * Creates and returns the Builder responsible to handle the `request` object.
   */
  static RequestBuilder getBuilderFor(dynamic request) {
    RequestBuilder result = null;

    if(request is shelf.Request) {
      result = _shelf;
    } else if (request is io.HttpRequest) {
      result = _io;
    }

    return result;
  }

}

/**
 * Builds Darter objects using a Shelf Request object as model.
 */
class ShelfRequestBuilder implements RequestBuilder {

  Future<Request> build(dynamic request) async {
    String body = await request.readAsString();

    Request req = new Request(uri: request.url.path, method: request.method, body: body);
    req.queryParameters = request.url.queryParameters;
    req.headers = request.headers;

    return req;
  }

}

/**
* Builds Darter objects using a IO.Request object as model.
*/
class IORequestBuilder implements RequestBuilder {

  Future<Request> build(dynamic request) async {
    String body = await request.transform(UTF8.decoder).join();

    Request req = new Request(uri: request.uri.path, method: request.method, body: body);
    req.queryParameters = request.uri.queryParameters;
    request.headers.forEach((String name, List<String> list) => req.headers[name] = request.headers.value(name));

    return req;
  }

}