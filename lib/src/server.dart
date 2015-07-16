library darter.server;

import 'dart:async';
import 'dart:io';
import 'package:shelf/shelf_io.dart' as io;
import 'package:shelf/shelf.dart' as shelf;
import 'package:darter/src/manager.dart';
import 'package:darter/src/http.dart';

const JSON = 'JSON';
const XML = 'XML';
const _DEFAULT_ADDRESS = '0.0.0.0';
const _DEFAULT_PORT = 8080;

typedef Future HttpRequestHandler(HttpRequest);

/**
 * Handles server setup stuff.
 */
class DarterServer {

  Manager _manager = new Manager();

  /**
   * Starts the HTTP Server.
   */
  Future<HttpServer> start({address: _DEFAULT_ADDRESS, int port: _DEFAULT_PORT}) async {
    var handler = const shelf.Pipeline().addMiddleware(shelf.logRequests()).addHandler(_handleShelfRequest);
    io.serve(handler, address, port);
  }

  /**
   * Handles a Shelf Request.
   *
   * Create a Darter.Request object and hand it over to the manager.
   */
  Future<shelf.Response> _handleShelfRequest(shelf.Request request) async {
    String body = await request.readAsString();

    Request req = new Request(uri: request.url.path, method: request.method, body: body);
    req.queryParameters = request.url.queryParameters;
    req.headers = request.headers;
    Response resp = await _handleRequest(req);

    return new shelf.Response(resp.statusCode, body: resp.body, headers: resp.headers);
  }

  /**
   * Add a new API to this server.
   *
   * This object must be an instance of a class annotated with `@API`, otherwise,
   * it will throw an exception.
   */
  void addApi(api) {
    _manager.registerAPI(api);
  }

  /**
   * Add a new Interceptor to this server.
   *
   * This object must be an instance of a class annotated with `@Interceptor`, otherwise,
   * it will throw an exception.
   */
  void addInterceptor(interceptor) {
    _manager.registerInterceptor(interceptor);
  }

  /**
   * Hand over the request to the manager.
   */
  Future<Response> _handleRequest(Request request) async {
    return _manager.handle(request);
  }

}