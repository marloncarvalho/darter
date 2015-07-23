library dart.processor;

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:darter/src/metadata/api.dart';
import 'package:darter/src/util/reflector.dart';
import 'package:darter/src/http.dart';
import 'package:darter/src/parameters.dart';
import 'package:logging/logging.dart';
import 'package:darter/src/exceptions.dart';
import 'package:darter/src/transformers.dart';
import 'package:dartson/dartson.dart';

class Processor {
  static final String CONTENT_TYPE_JSON = 'application/json; charset=UTF-8';
  final Logger _log = new Logger('Processor');

  Reflector _reflector = new Reflector();

  Future<Response> processError(Request request, ApiErrorHandler error, Object exception) async {
    _log.fine("Processing Error. ${error}");

    Transformer transformer = Transformer.create(request.getMediaType());
    Response result = new Response(statusCode: 200);
    var returned = _reflector.invoke(error.objectHandler, error.methodName, [exception]);

    if (returned.runtimeType == Response) {
      result.statusCode = returned.statusCode;
      result.headers.addAll(returned.headers);
      result.body = transformer.transform(returned.entity);
    } else if (returned.runtimeType == String) {
      result.body = returned;
    } else {
      result.body = transformer.transform(returned);
    }

    _log.fine("Error: ${result}");

    return result;
  }

  Future<Response> process(Request request, ApiMethod method) async {
    _log.fine("Processing request: ${request}");

    Transformer transformer = Transformer.create(request.getMediaType());
    Response result = new Response(statusCode: -1, headers: new Map());

    if (method == null) {
      result = processNotFound();
    } else {
      var returned = null;
      if (method.parameters.length > 0) {
        returned = _reflector.invoke(method.apiMeta.object, method.name, _parseParameters(method, request));
      } else {
        returned = _reflector.invoke(method.apiMeta.object, method.name);
      }

      if (returned is Response) {
        _log.fine("API method returned a response object. ${returned}");

        result.statusCode = returned.statusCode;
        if (returned.headers != null) {
          _log.fine("Adding headers from API method.");
          result.headers.addAll(returned.headers);
        }

        if (returned.entity != null) {
          result.body = transformer.transform(returned.entity);
        } else if (returned.body != null) {
          result.body = returned.body;
        }
      } else if (returned is Future) {
        result.body = transformer.transform(await returned);
      } else {
        result.body = transformer.transform(returned);
      }
    }

    if (result.statusCode == -1) {
      if (request.method == "POST") {
        result.statusCode = 201;
      } else if (request.method == "DELETE") {
        result.statusCode = 204;
      } else {
        result.statusCode = 200;
      }
    }

    _setContentHeaders(result, transformer.getMediaType());

    _log.fine("Response generated: ${result}");

    return result;
  }

  void _setContentHeaders(Response response, String mediaType) {
    if (mediaType != null) {
      response.headers[HttpHeaders.CONTENT_TYPE] = mediaType;
    } else {
      response.headers[HttpHeaders.CONTENT_TYPE] = CONTENT_TYPE_JSON;
    }

    if (response.body != null) {
      response.headers[HttpHeaders.CONTENT_LENGTH] = response.body.length.toString();
    } else {
      response.headers[HttpHeaders.CONTENT_LENGTH] = "0";
    }
  }

  Response processContentTypeNotAccepted(contentType) {
    return new Response(body: "{\"error\": \"The requested content-type '${contentType}' is not supported.\"}", statusCode: HttpStatus.UNSUPPORTED_MEDIA_TYPE);
  }

  Response processFatalError() {
    return new Response(body: "Internal Server Error", statusCode: 500);
  }

  Response processMethodNowAllowed() {
    return new Response(body: "", statusCode: 405);
  }

  Response processNotFound() {
    return new Response(body: "NOT FOUND", statusCode: 404);
  }

  List _parseParameters(ApiMethod apiMethod, Request request) {
    _log.fine("Parsing Parameters from API Method: ${apiMethod}");

    List result = [];
    String body = request.body;

    apiMethod.parameters.forEach((ApiMethodParameter param) {
      if (param.type == Map && param.name == new Symbol("pathParams")) {
        _log.fine("Map PathParams found.");
        result.add(apiMethod.getParamsFromURI(request.uri));
      } else if (param.type == Parameters && param.name == new Symbol("pathParams")) {
        _log.fine("Parameters PathParams found.");
        result.add(new Parameters(apiMethod.getParamsFromURI(request.uri)));
      } else if (param.type == Parameters && param.name == new Symbol("queryParams")) {
        _log.fine("Parameters QueryParams found.");
        result.add(new Parameters(request.queryParameters));
      } else if (param.type == Map && param.name == new Symbol("queryParams")) {
        _log.fine("Map QueryParams found.");
        result.add(request.queryParameters);
      } else if (param.type == Map && param.name == new Symbol("headers")) {
        _log.fine("Map Headers found.");
        result.add(request.headers);
      } else if (param.type == Map && param.name == new Symbol("params")) {
        _log.fine("Map Parameters found.");
        result.add(_getParamsFromAllOverThePlace(apiMethod, request));
      } else if (param.type == Map || param.type == List) {
        _log.fine("Map or List found.");
        result.add(JSON.decode(body));
      } else {
        _log.fine("Complex object found.");
        result.add(_handleComplexObjectParam(apiMethod, param, body));
      }
    });

    _log.fine("Parameters parsing result: ${result}");

    return result;
  }

  Object _handleComplexObjectParam(ApiMethod apiMethod, ApiMethodParameter param, String body) {
    var result = _reflector.instantiate(param.type, new Symbol(''), []);

    if (body != null && !body.isEmpty) {
      try {
        result = new Dartson.JSON().decode(body, result);
      } catch (e) {
        _log.severe("The incoming request body could not be transformed into the requested parameter. Error converting parameter [${param.name.toString()}] with type [${param.type.toString()}] from method [${apiMethod.name.toString()}].");
        throw new DarterException("The incoming request body could not be transformed into the requested parameter. Error converting parameter [${param.name.toString()}] with type [${param.type.toString()}] from method [${apiMethod.name.toString()}].");
      }
    }

    return result;
  }

  Map _getParamsFromAllOverThePlace(ApiMethod methodMeta, Request request) {
    Map result = new Map();

    result.addAll(request.queryParameters);
    result.addAll(methodMeta.getParamsFromURI(request.uri));

    return result;
  }

}