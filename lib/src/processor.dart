library dart.processor;

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:dartson/dartson.dart';
import 'package:darter/src/metadata/api.dart';
import 'package:darter/src/util/reflector.dart';
import 'package:darter/src/http.dart';

class Processor {
  static final String CONTENT_TYPE_JSON = 'application/json; charset=UTF-8';

  Reflector _reflector = new Reflector();
  Dartson _dson = new Dartson.JSON();

  Future<Response> processError(Request request, ApiErrorHandler error, Object exception) async {
    Response result = new Response(statusCode: 200);
    var returned = _reflector.invoke(error.objectHandler, error.methodName, [exception]);

    if (returned.runtimeType == Response) {
      result.statusCode = returned.statusCode;
      result.headers.addAll(returned.headers);
      result.body = _dson.encode(returned.entity);
    } else if (returned.runtimeType == String) {
      result.body = returned;
    } else {
      result.body = _dson.encode(returned);
    }

    return result;
  }

  Future<Response> process(Request request, ApiMethod method) async {
    Response result = new Response(statusCode: -1);

    if (method == null) {
      result = processNotFound();
    } else {
      var returned = null;
      if (method.parameters.length > 0) {
        returned = _reflector.invoke(method.apiMeta.object, method.name, _parseParameters(method, request));
      } else {
        returned = _reflector.invoke(method.apiMeta.object, method.name);
      }

      if (returned.runtimeType == Response) {
        result.statusCode = returned.statusCode;
        result.headers.addAll(returned.headers);
        result.body = _dson.encode(returned.entity);
      } else {
        result.body = _dson.encode(returned);
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

    _setContentHeaders(result, method);

    return result;
  }

  void _setContentHeaders(Response response, ApiMethod apiMethod) {
    if (apiMethod.produce != null) {
      response.headers[HttpHeaders.CONTENT_TYPE] = apiMethod.produce;
    } else {
      response.headers[HttpHeaders.CONTENT_TYPE] = CONTENT_TYPE_JSON;
    }

    response.headers[HttpHeaders.CONTENT_LENGTH] = response.body.length.toString();
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
    List result = [];
    String body = request.body;

    apiMethod.parameters.forEach((ApiMethodParameter param) {
      if (param.type == Map && param.name == new Symbol("pathParams")) {
        result.add(apiMethod.getParamsFromURI(request.uri));
      } else if (param.type == Map && param.name == new Symbol("queryParams")) {
        result.add(request.queryParameters);
      } else if (param.type == Map && param.name == new Symbol("headers")) {
        result.add(request.headers);
      } else if (param.type == Map && param.name == new Symbol("params")) {
        result.add(_getParamsFromAllOverThePlace(apiMethod, request));
      } else if (param.type == Map || param.type == List) {
        result.add(JSON.decode(body));
      } else {
        result.add(_handleComplexObjectParam(apiMethod, param, body));
      }
    });

    return result;
  }

  Object _handleComplexObjectParam(ApiMethod apiMethod, ApiMethodParameter param, String body) {
    var result = _reflector.instantiate(param.type, new Symbol(''), []);

    if (body != null && !body.isEmpty) {
      try {
        result = _dson.decode(body, result);
      } catch (e) {
        throw "The incoming request body could not be transformed into the requested parameter. Error converting parameter [${param.name.toString()}] with type [${param.type.toString()}] from method [${apiMethod.name.toString()}].";
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