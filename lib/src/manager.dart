library darter.manager;

import 'dart:async';
import 'dart:io';
import 'package:darter/src/metadata/api.dart';
import 'package:darter/src/path.dart';
import 'package:darter/src/http.dart';
import 'package:darter/src/metadata/parser.dart';
import 'package:darter/src/processor.dart';
import 'package:darter/src/annotations.dart';
import 'package:darter/src/interceptor.dart';
import 'package:logging/logging.dart';

/**
 * It's an internal class and has some main responsibilities:
 *
 * 1. Search in the classpath for all classes annotated with @API and parse them.
 * 2. Cache all available routes.
 * 3. Receive requests.
 *  3.1. Find the route responsible to this request.
 *  3.2. Ask the processor to process this request.
 */
class Manager {
  final Logger _log = new Logger('Manager');
  static const API_NULL_VERSION = 'darter-null-version';
  Chain _beforeChain = new Chain();
  Chain _afterChain = new Chain();
  Parser _parser = new Parser();
  Processor _processor = new Processor();
  Map<String, PathTree> _versions = new Map();

  /**
   * Adds an API.
   *
   * Eventually, it will be replaced by an automatic mechanism that scans the classpath and
   * figure out which classes have the @API annotation.
   */
  void registerAPI(apiObject) {
    Api api = _parser.parseApi(apiObject);
    _log.fine("DARTER/Manager - Registering API: ${api}");
    _register(api);
  }

  void _register(Api api) {
    if (api.version == null) {
      _log.fine("DARTER/Manager - No version provided. Using '${API_NULL_VERSION}'.");
      api.version = new ApiVersion(version: API_NULL_VERSION, using: Using.HEADER);
    }

    if (!_versions.containsKey(api.version.version)) {
      _log.fine("DARTER/Manager - Version not cached yet. Creating it: ${api.version}");

      _versions[api.version.version] = new PathTree(new Path.fromString('/'));
    }

    PathTree pathTree = _versions[api.version.version];
    api.methods.forEach((wm) => pathTree.addChild(wm.path, wm));

    _registerChildren(api);
  }

  void _registerChildren(Api api) {
    api.children.forEach((Api child) => _register(child));
  }

  void registerInterceptor(var interceptor) {
    ApiInterceptor apiInt = _parser.parseInterceptor(interceptor);

    if (apiInt.when == Interceptor.AFTER) {
      _log.fine("DARTER/Manager - Registering After Interceptor: ${interceptor}");
      _afterChain.addInterceptor(apiInt);
    } else if (apiInt.when == Interceptor.BEFORE) {
      _log.fine("DARTER/Manager - Registering Before Interceptor: ${interceptor}");
      _beforeChain.addInterceptor(apiInt);
    }
  }

  /**
   * Handles a request.
   */
  Future<Response> handle(Request request) async {
    ApiMethod apiMethod = null;
    List<ApiMethod> list = null;
    bool hasPathsForVersion = false;

    ApiVersion version = _extractVersion(request);
    if (_versions.containsKey(version.version)) {
      _log.fine("DARTER/Manager - Version found. ${version.version}.");

      PathTree pathTree = _versions[version.version];

      Path path = new Path.fromString(request.urlNoExtension);
      if (version.using == Using.HEADER) {
        list = pathTree.getMethodsForPath(path);
      } else if (version.using == Using.PATH) {
        list = pathTree.getMethodsForPath(path.subPath(start:1));
      }

      _log.fine("DARTER/Manager - API Methods: ${list}.");

      if (list != null) {
        hasPathsForVersion = true;
        list.forEach((ApiMethod m) {
          ApiVersion cachedVersion = m.apiMeta.version;
          if (cachedVersion.using == version.using && cachedVersion.vendor == version.vendor) {
            if (m.method == request.method) {
              _log.fine("DARTER/Manager - Found a method responsible to handle the request ${request.uri}. Method: ${m}");
              apiMethod = m;
            }
          }
        });
      }
    }

    if (hasPathsForVersion && apiMethod == null) {
      _log.fine("DARTER/Manager - No method found to handle request. Request: ${request}");
      return _processor.processNotFound();
    } else if (list != null && list.length > 0 && apiMethod == null) {
      _log.fine("DARTER/Manager - Method found but with a Method not allowed. Request: ${request}");
      return _processor.processMethodNowAllowed();
    } else {
      if (apiMethod == null) {
        return _processor.processNotFound();
      }

      if (!apiMethod.consumes.contains(request.headers[HttpHeaders.CONTENT_TYPE])) {
        _log.fine("DARTER/Manager - Method found but doesn't consume the specified media type. MediaType: ${request.headers[HttpHeaders.CONTENT_TYPE]}.");
        return _processor.processContentTypeNotAccepted(request.headers[HttpHeaders.CONTENT_TYPE]);
      } else {

        String reqMediaType = request.getMediaType();
        if (apiMethod.produces.contains(reqMediaType)) {
          Response response = await _process(request, apiMethod);
          _log.info("DARTER/Manager - Generated response ${response}");
          return response;
        } else {
          _log.fine("DARTER/Manager - Method found but doesn't produce the specified media type. Request: ${request}.");
          return _processor.processContentTypeNotAccepted('');
        }
      }
    }
  }

  Future<Response> _process(request, apiMethod) async {
    Response response = null;

    _log.fine("DARTER/Manager - Processing request.");

    try {

      if (!_processBeforeInterceptors(request)) {
        response = _beforeChain.respondWith;
      } else {
        response = await _processor.process(request, apiMethod);
        if (!_processAfterInterceptors(request, response)) {
          if (_afterChain.respondWith != null) {
            response = _afterChain.respondWith;
          }
        }
      }

      if (response == null) {
        _log.info("DARTER/Manager - No response provided from API Method or Interceptors.");
        response = _processor.processFatalError();
      }
    } catch (e) {
      _log.info("DARTER/Manager - Exception thrown from API method: ${e}");

      response = await _handleError(apiMethod.apiMeta, request, e);
      if (response == null) {
        response = _processor.processFatalError();
      }
    }

    _afterChain.clear();
    _beforeChain.clear();

    return response;
  }

  bool _processBeforeInterceptors(Request request) {
    _log.fine("DARTER/Manager - Processing Before Interceptors.");

    _beforeChain.request = request;
    _beforeChain.execute();

    return !_beforeChain.aborted;
  }

  bool _processAfterInterceptors(Request request, Response response) {
    _log.fine("DARTER/Manager - Processing After Interceptors.");

    _afterChain.request = request;
    _afterChain.response = response;
    _afterChain.execute();

    return !_afterChain.aborted;
  }

  Future<Response> _handleError(Api api, Request request, Object exception) {
    _log.fine("DARTER/Manager - Exception thrown ${exception}. Processing Error Handlers.");

    for (ApiErrorHandler handler in api.errorHandlers) {
      if (handler.exception == exception.runtimeType) {
        _log.info("DARTER/Manager - Executing Error Handler: ${handler}");
        return _processor.processError(request, handler, exception);
      }
    }

    if (api.parent != null) {
      _log.info("DARTER/Manager - Searching parents for error handlers.");
      return _handleError(api.parent, request, exception);
    }
  }

  ApiVersion _extractVersion(Request request) {
    _log.fine("DARTER/Manager - Extracting version from Request.");
    ApiVersion result = new ApiVersion(version: API_NULL_VERSION, using: Using.HEADER);

    try {
      Path path = new Path.fromString(request.uri);
      if (_versions.containsKey(path.parts[0])) {
        result.version = path.parts[0];
        result.vendor = null;
        result.using = Using.PATH;
        result.format = null;
      } else {
        String acceptHeader = request.headers[HttpHeaders.ACCEPT];
        if (acceptHeader.indexOf("application/") == 0) {
          acceptHeader = acceptHeader.substring(12);
          if (acceptHeader.indexOf("vnd.") == 0) {
            acceptHeader = acceptHeader.substring(4);

            var vendorVersionFormat = acceptHeader.split(".");
            result.vendor = vendorVersionFormat[0];

            var versionFormat = vendorVersionFormat[1].split("\+");
            result.version = versionFormat[0];
            result.format = versionFormat[1];
            result.using = Using.HEADER;
          }
        }
      }
    } catch (e) {

    }

    _log.fine("DARTER/Manager - Version extracted: ${result}");

    return result;
  }

}

class

PathTree {
  Path path;
  List<ApiMethod> methods = [];
  Map<String, PathTree> _children = new Map<String, PathTree>();

  PathTree(this.path);

  bool isAbstract() {
    return methods.length <= 0;
  }

  List<ApiMethod> getMethodsForPath(Path lPath) {
    List<ApiMethod> result = null;

    if (lPath != null) {
      if (_children.containsKey(lPath.parts[0])) {
        result = _children[lPath.parts[0]].getMethodsForPath(lPath.subPath(start: 1));
      } else {
        if (lPath == path && !isAbstract()) {
          result = methods;
        } else {
          for (var key in _children.keys) {
            PathTree pathTree = _children[key];
            if (key.indexOf(":") > -1) {
              var res = pathTree.getMethodsForPath(lPath.subPath(start: 1));
              if (res != null && res.length > 0) {
                result = res;
                break;
              }
            }
          }
        }
      }
    } else {
      if (!isAbstract()) {
        result = methods;
      }
    }

    return result;
  }

  void addChild(Path lPath, ApiMethod apiMethod) {
    if (apiMethod != null) {
      if (lPath != null && lPath.length > 0) {
        if (lPath != path) {
          String prefix = lPath.parts[0];
          if (_children.containsKey(prefix)) {
            PathTree child = _children[prefix];
            if (lPath.subPath(start: 1) != null && lPath.subPath(start: 1).length > 0) {
              child.addChild(lPath.subPath(start: 1), apiMethod);
            } else {
              child.methods.add(apiMethod);
            }
          } else {
            PathTree child = new PathTree(new Path.fromString(prefix));
            if (lPath.parts.length > 1) {
              child.addChild(lPath.subPath(start: 1), apiMethod);
            } else {
              child.methods.add(apiMethod);
            }
            _children[prefix] = child;
          }
        }
      }
    }
  }

}





