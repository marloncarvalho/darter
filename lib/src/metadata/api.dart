library darter.metadata;

import 'package:darter/src/path.dart';

class Api {
  List<Api> children = [];
  Api parent;
  dynamic object;
  List<String> consumes;
  List<String> produces;
  Path path;
  List<ApiMethod> methods = [];
  ApiVersion version;
  List<ApiErrorHandler> errorHandlers = [];

  Api({this.object, this.path, this.consumes, this.produces});

  String toString() {
    return "(Parent: ${parent != null ? parent.path : ''}), (produces: ${produces}), (consumes: ${consumes}), (path: ${path.toString()}), (methods: ${methods.length}), (errorHandlers: ${errorHandlers.length}), (children: ${children.length}), (Version: ${version})";
  }

}

class ApiInterceptor {
  Type type;
  String when;
  int priority;

  ApiInterceptor({this.type, this.when, this.priority});

  String toString() {
    return "Type: ${type}, When: ${when}, Priority: ${priority}";
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
  List<String> consumes;
  List<String> produces;
  Api apiMeta;
  Symbol name;
  List parameters = [];
  Path path;
  String method;

  ApiMethod({this.apiMeta, this.name, this.path, this.method, this.consumes, this.produces});

  String toString() {
    return "Method: ${method}, Path: ${path}, Consume: ${consumes}, Produce: ${produces}, Name: ${name}, Parameters: ${parameters.length}";
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