library darter.metadata;

import 'package:darter/src/path.dart';

class Api {
  List<Api> children = [];
  Api parent;
  dynamic object;
  String consume;
  String produce;
  Path path;
  List<ApiMethod> methods = [];
  ApiVersion version;
  List<ApiErrorHandler> errorHandlers = [];

  Api({this.object, this.path, this.consume, this.produce});

  String toString() {
    return "(Parent: ${parent != null ? parent.path : ''}), (produces: ${produce}), (consumes: ${consume}), (path: ${path.toString()}), (methods: ${methods.length}), (errorHandlers: ${errorHandlers.length}), (children: ${children.length}), (Version: ${version})";
  }

}

class ApiInterceptor {
  dynamic object;
  String when;
  int priority;

  ApiInterceptor({this.object, this.when, this.priority});

  String toString() {
    return "Object: ${object}, When: ${when}, Priority: ${priority}";
  }
}

class ApiVersion {
  String version;
  String vendor;
  String using;
  String format;

  ApiVersion({this.version, this.vendor, this.using, this.format});

  String toString() {
    return "Version: ${version}, Vendor: ${vendor}, Using: ${using}, Format: ${format}";
  }

}

class ApiMethod {
  String consume;
  String produce;
  Api apiMeta;
  Symbol name;
  List parameters = [];
  Path path;
  String method;

  ApiMethod({this.apiMeta, this.name, this.path, this.method, this.consume, this.produce});

  String toString() {
    return "Method: ${method}, Path: ${path}, Consume: ${consume}, Produce: ${produce}, Name: ${name}, Parameters: ${parameters.length}";
  }

  Map getParamsFromURI(String uri) {
    Map result = new Map<String, String>();

    Path pathUri = new Path.fromString(uri);
    for (var i = 0; i < path.parts.length; i++) {
      String part = path.parts[i];
      if (part.indexOf(":") > -1) {
        result[part.substring(1)] = pathUri.parts[i];
      }
    }

    return result;
  }

}

class ApiMethodParameter {
  Symbol name;
  Type type;

  ApiMethodParameter({this.name, this.type});
}

class ApiErrorHandler {
  Object objectHandler;
  Symbol methodName;
  Type exception;

  String toString() {
    return "MethodName: ${methodName}, Exception: ${exception}.";
  }
}