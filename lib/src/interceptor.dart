library darter.interceptor;

import 'package:darter/src/http.dart';
import 'package:darter/src/metadata/api.dart';
import 'package:darter/src/util/reflector.dart';
import 'package:logging/logging.dart';
import 'package:darter/src/exceptions.dart';

class ChainManager {
  final Logger _log = new Logger('ChainManager');
  List<ApiInterceptor> _interceptors = [];

  Chain fire(Request request, [Response response]) {
    _log.fine("DARTER/ChainManager - Creating a new chain.");

    Chain chain = new Chain();
    chain.response = response;
    chain.request = request;
    chain.interceptors = _interceptors;
    chain.execute();

    return chain;
  }

  void addInterceptor(ApiInterceptor interceptor) {
    _log.fine("Adding interceptor to the chain: ${interceptor}");

    _interceptors.add(interceptor);
    _interceptors.sort((x, y) => x.priority.compareTo(y.priority));
  }

}

class Chain {
  Reflector _reflector = new Reflector();
  final Logger _log = new Logger('Chain');
  List<ApiInterceptor> interceptors = [];
  Response response;
  Request request;
  bool aborted = false;
  Response respondWith;

  void abort(Response response) {
    _log.fine("Chain aborted with response: ${response}");

    aborted = true;
    respondWith = response;
  }

  void execute() {
    _log.fine("Initiating chain.");

    for (ApiInterceptor interceptor in interceptors) {
      var object = _reflector.instantiate(interceptor.type, new Symbol(''), []);
      if (_reflector.existsMethod(new Symbol('intercept'), object)) {
        _reflector.invoke(object, new Symbol('intercept'), [this]);
        if (aborted) {
          break;
        }
      } else {
        _log.severe("Interceptor object doesn't contain the method 'intercept'. ${interceptor}");
        throw new DarterException("Could not find method 'intercept' in Interceptor class [${interceptor.type}]");
      }
    }
  }
}