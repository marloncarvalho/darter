library darter.interceptor;

import 'package:darter/src/http.dart';
import 'package:darter/src/metadata/api.dart';
import 'package:darter/src/util/reflector.dart';

class Chain {
  List<ApiInterceptor> _interceptors = [];
  Response response;
  Request request;
  bool aborted = false;
  Response respondWith;

  void addInterceptor(ApiInterceptor interceptor) {
    _interceptors.add(interceptor);
    _interceptors.sort((x, y) => x.priority.compareTo(y.priority));
  }

  void abort(Response response) {
    aborted = true;
    respondWith = response;
  }

  void clear() {
    response = null;
    request = null;
    respondWith = null;
    aborted = false;
  }

  void execute() {
    Reflector reflector = new Reflector();

    for (ApiInterceptor interceptor in _interceptors) {
      if (reflector.existsMethod(new Symbol('intercept'), interceptor.object)) {
        reflector.invoke(interceptor.object, new Symbol('intercept'), [this]);
        if (aborted) {
          break;
        }
      } else {
        throw "Could not find method 'intercept' in Interceptor class [${interceptor.object.runtimeType}]";
      }
    }
  }
}