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
   * Eventually, it will be removed because we're gonna implement a better
   * way to find all classes annotated with @API.
   */
  void addApi(api) {
    _manager.registerAPI(api);
  }

  void addInterceptor(interceptor) {
    _manager.registerInterceptor(interceptor);
  }

  /**
   * Iterates over each API and asks it to handle this request.
   * If false is returned, then this API didn't handle the request. Otherwise, the API handled it
   * and we should stop the iteration.
   */
  Future<Response> _handleRequest(Request request) async {
    return _manager.handle(request);
  }

}