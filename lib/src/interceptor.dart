library darter.interceptor;

import 'package:darter/src/http.dart';
import 'package:darter/src/metadata/api.dart';
import 'package:darter/src/util/reflector.dart';
import 'package:logging/logging.dart';

class Chain {
  final Logger _log = new Logger('Chain');
  List<ApiInterceptor> _interceptors = [];
  Response response;
  Request request;
  bool aborted = false;
  Response respondWith;

  void addInterceptor(ApiInterceptor interceptor) {
    _log.fine("Adding interceptor to the chain: ${interceptor}");

    _interceptors.add(interceptor);
    _interceptors.sort((x, y) => x.priority.compareTo(y.priority));
  }

  void abort(Response response) {
    _log.fine("Chain aborted with response: ${response}");

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
    _log.fine("Initiating chain.");

    Reflector reflector = new Reflector();

    for (ApiInterceptor interceptor in _interceptors) {
      if (reflector.existsMethod(new Symbol('intercept'), interceptor.object)) {
        reflector.invoke(interceptor.object, new Symbol('intercept'), [this]);
        if (aborted) {
          break;
        }
      } else {
        _log.severe("Interceptor object doesn't contain the method 'intercept'. ${interceptor}");
        throw "Could not find method 'intercept' in Interceptor class [${interceptor.object.runtimeType}]";
      }
    }
  }
}