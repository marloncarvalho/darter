library darter.server;

import 'dart:async';
import 'dart:io' as io;
import 'package:shelf/shelf_io.dart' as shelf_io;
import 'package:shelf/shelf.dart' as shelf;
import 'dart:convert' show UTF8;
import 'package:darter/src/manager.dart';
import 'package:darter/src/http.dart';
import 'package:appengine/appengine.dart' as appengine;
import 'package:logging/logging.dart';

const _DEFAULT_ADDRESS = '0.0.0.0';
const _DEFAULT_PORT = 8080;

/**
 * Handles server setup stuff.
 */
class DarterServer {
  final Logger _log = new Logger('DarterServer');
  Manager _manager = new Manager();

  /**
   * Starts the HTTP Server.
   */
  Future<io.HttpServer> start({address: _DEFAULT_ADDRESS, int port: _DEFAULT_PORT}) async {
    _log.info("DARTER/Server - Darter Server starting with Shelf support. Listening ${address}:${port}");

    var handler = const shelf.Pipeline().addMiddleware(shelf.logRequests()).addHandler(_handleShelfRequest);
    shelf_io.serve(handler, address, port);
  }

  Future startIO({address: _DEFAULT_ADDRESS, int port: _DEFAULT_PORT}) async {
    _log.info("DARTER/Server - Darter Server starting with Dart:IO support. Listening ${address}:${port}");

    var requestServer = await io.HttpServer.bind(address, port);
    await for (io.HttpRequest request in requestServer) {
      _handleIORequest(request);
    }
  }

  Future startAppEngine() async {
    _log.info("DARTER/Server - Darter Server starting with Google AppEngine Support.");

    appengine.runAppEngine((io.HttpRequest request) {
      _handleIORequest(request);
    });
  }

  Future _handleIORequest(io.HttpRequest request) async {
    _log.info("DARTER/Server - Request: ${request.method} -> ${request.uri.toString()}");

    String body = await request.transform(UTF8.decoder).join();

    Request req = new Request(uri: request.uri.path, method: request.method, body: body);
    req.queryParameters = request.uri.queryParameters;
    request.headers.forEach((String name, List<String> list) => req.headers[name] = request.headers.value(name));

    Response resp = await _handleRequest(req);
    resp.headers.forEach((k, v) => request.response.headers.set(k, v));
    request.response.statusCode = resp.statusCode;
    request.response.write(resp.body);

    request.response.close();
  }

  /**
   * Handles a Shelf Request.
   *
   * Create a Darter.Request object and hand it over to the manager.
   */
  Future<shelf.Response> _handleShelfRequest(shelf.Request request) async {
    _log.info("DARTER/Server - Incoming Request: ${request.method} -> ${request.url.toString()}");

    String body = await request.readAsString();

    Request req = new Request(uri: request.url.path, method: request.method, body: body);
    req.queryParameters = request.url.queryParameters;
    req.headers = request.headers;
    Response resp = await _handleRequest(req);

    return new shelf.Response(resp.statusCode, body: (resp.body != null ? resp.body : ''), headers: resp.headers);
  }

  /**
   * Add a new API to this server.
   *
   * This object must be an instance of a class annotated with `@API`, otherwise,
   * it will throw an exception.
   */
  void addApi(var api) {
    _log.fine("DARTER/Server - New API registered on DarterServer. ${api.runtimeType}");

    _manager.registerAPI(api);
  }

  /**
   * Add a new Interceptor to this server.
   *
   * This object must be an instance of a class annotated with `@Interceptor`, otherwise,
   * it will throw an exception.
   */
  void addInterceptor(var interceptor) {
    _log.fine("DARTER/Server - New INTERCEPTOR registered on DarterServer. ${interceptor.runtimeType}");

    _manager.registerInterceptor(interceptor);
  }

  /**
   * Hand over the request to the manager.
   */
  Future<Response> _handleRequest(Request request) async {
    return _manager.handle(request);
  }

}