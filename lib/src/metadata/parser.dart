library darter.metadata.parser;

import 'dart:mirrors';
import 'package:darter/src/annotations.dart';
import 'package:darter/src/metadata/api.dart';
import 'package:darter/src/util/reflector.dart';
import 'package:darter/src/path.dart';
import 'package:darter/src/exceptions.dart';

/**
 * It's responsible for parsing API objects (objects annotated with @API)
 * and extracting every important data from annotations around this class (API, Version, etc).
 */
class Parser {
  Reflector _reflector = new Reflector();

  ApiInterceptor parseInterceptor(dynamic object) {
    ApiInterceptor result = new ApiInterceptor();
    Interceptor annotation = _reflector.getAnnotation(object, Interceptor);

    if (annotation != null) {
      result.priority = annotation.priority;
      result.object = object;
      result.when = annotation.when;
    }

    return result;
  }

  Api parseApi(dynamic apiObject, [Api parentApi]) {
    API annotation = _reflector.getAnnotation(apiObject, API);
    if (annotation == null) {
      throw "ParserError: Class is not annotated with the @API annotation.";
    }

    Path path = new Path.fromString((annotation.path == null ? "" : annotation.path));

    if (parentApi != null) {
      path = parentApi.path.join(path);
    }

    MediaType mediaType = _getMediaType(apiObject, parentApi);

    Api result = new Api(object:apiObject, path:path, consume: mediaType.consume, produce: mediaType.produce);
    result.parent = parentApi;
    result.methods = _getMethods(apiObject, result);
    result.version = _getVersion(apiObject, (parentApi != null ? parentApi.version : null));
    result.errorHandlers = _getErrorHandlers(apiObject);
    result.children = _getChildren(result, apiObject);

    return result;
  }

  List<Api> _getChildren(Api api, apiObject) {
    List<Api> result = [];

    _reflector.getFieldsValueAnnotatedWith(apiObject, Include).forEach((dynamic r) {
      result.add(parseApi(r, api));
    });

    return result;
  }

  MediaType _getMediaType(dynamic apiObject, dynamic parentApi) {
    MediaType mediaType = _reflector.getAnnotation(apiObject, MediaType);

    String consume = MediaType.JSON;
    String produce = MediaType.JSON;
    if (mediaType != null) {
      consume = (mediaType.consume == null ? MediaType.JSON : mediaType.consume);
      produce = (mediaType.produce == null ? MediaType.JSON : mediaType.produce);
    } else {
      if (parentApi != null) {
        consume = (parentApi.consume == null ? MediaType.JSON : parentApi.consume);
        produce = (parentApi.produce == null ? MediaType.JSON : parentApi.produce);
      }
    }

    List medias = [MediaType.JSON, MediaType.XML, MediaType.IMAGE_PNG];
    if(!medias.contains(consume) || !medias.contains(produce)) {
      throw new ParserError("Incorrect Media Type");
    }

    return new MediaType(consume: consume, produce: produce);
  }

  List<ApiErrorHandler> _getErrorHandlers(dynamic apiObject) {
    List<ApiErrorHandler> result = [];
    ClassMirror classMirror = reflectClass(apiObject.runtimeType);

    for (var key in classMirror.instanceMembers.keys) {
      MethodMirror methodMirror = classMirror.instanceMembers[key];

      for (var instance in methodMirror.metadata) {
        if (instance.hasReflectee) {
          if (instance.reflectee.runtimeType == ErrorHandler) {
            ApiErrorHandler handler = new ApiErrorHandler();
            handler.methodName = methodMirror.simpleName;
            handler.objectHandler = apiObject;

            if (methodMirror.parameters.length > 1) {
              throw "An error handle must have only one parameter.";
            }

            if (methodMirror.parameters.length == 0) {
              throw "An error handle must have at least one parameter.";
            }

            handler.exception = methodMirror.parameters[0].type.reflectedType;
            result.add(handler);
          }
        }
      }
    }

    return result;
  }

  ApiVersion _getVersion(dynamic apiObject, [ApiVersion parentVersion]) {
    ApiVersion result = null;

    Version annotation = _reflector.getAnnotation(apiObject, Version);
    if (annotation != null) {
      result = new ApiVersion(version: annotation.version, vendor: annotation.vendor, using: annotation.using, format: annotation.format);

      if (result.version.isEmpty || result.version == null) {
        throw "ParserError: 'version' attribute can't be neither an empty string nor null.";
      }

      if (result.using != 'header' && result.using != 'path') {
        throw "ParserError: Possible values for the 'using' attribute in @Version annotation are Using.HEADER and Using.PATH.";
      }

      if (result.using == 'header') {
        if (result.format.isEmpty || result.format == null) {
          throw "ParserError: When 'header' is provided at 'using' attribute, 'vendor' is required.";
        }

        if (result.format != 'json' && result.format != 'xml') {
          throw "ParserError: Possible values for the 'format' attribute in @Version annotation are Format.JSON and Format.XML.";
        }

        if (result.vendor.isEmpty || result.vendor == null) {
          throw "ParserError: When 'header' is provided at 'using' attribute, 'vendor' is required.";
        }
      }
    } else {
      if (parentVersion != null) {
        result = parentVersion;
      }
    }

    return result;
  }

  // FIXME Refactoring required. :P
  List<ApiMethod> _getMethods(dynamic object, Api api) {
    List<ApiMethod> result = [];
    ClassMirror classMirror = reflectClass(object.runtimeType);

    for (var key in classMirror.instanceMembers.keys) {
      MethodMirror methodMirror = classMirror.instanceMembers[key];
      Method m = _reflector.searchAnnotation(methodMirror, [GET, POST, PUT, DELETE, PATCH]);
      MediaType mediaType = _reflector.searchAnnotation(methodMirror, [MediaType]);

      if (m != null) {
        if (m.path != null && (m.path.isEmpty || m.path == null)) {
          throw "ParserError: 'path' parameter can't be neither null nor empty in annotations @GET, @POST, @PUT, @DELETE and @PATCH.";
        }

        String consume = api.consume;
        String produce = api.produce;
        if (mediaType != null) {
          consume = (mediaType.consume == null ? api.consume : mediaType.consume);
          produce = (mediaType.produce == null ? api.produce : mediaType.produce);
        }

        Path p = api.path.join(new Path.fromString((m.path == null ? "" : m.path)));
        String methodName = "";

        // FIXME Create class HttpMethods and constants to each method inside it.
        if (m.runtimeType == GET) {
          methodName = 'GET';
        } else if (m.runtimeType == POST) {
          methodName = 'POST';
        } else if (m.runtimeType == PUT) {
          methodName = 'PUT';
        } else if (m.runtimeType == PATCH) {
          methodName = 'PATCH';
        } else if (m.runtimeType == DELETE) {
          methodName = 'DELETE';
        }

        ApiMethod method = new ApiMethod(apiMeta:api, name: methodMirror.simpleName, path: p, method: methodName, produce: produce, consume: consume);
        methodMirror.parameters.forEach((ParameterMirror param) {
          method.parameters.add(new ApiMethodParameter(name: param.simpleName, type: param.type.reflectedType));
        });

        result.add(method);
      }
    }

    return result;
  }

}