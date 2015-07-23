library darter.transformers;

import 'package:darter/src/annotations.dart';
import 'package:dartson/dartson.dart';
import 'package:darter/src/util/reflector.dart';
import 'dart:mirrors';

abstract class Transformer {
  String transform(dynamic object);

  String getMediaType();

  static Transformer create(String mediaType) {
    Transformer result = new JSONTransformer();

    if (mediaType == MediaType.XML) {
      result = new XMLTransformer();
    }

    return result;
  }

}

class JSONTransformer implements Transformer {
  Dartson _dartson = new Dartson.JSON();

  String transform(dynamic object) {
    return _dartson.encode(object);
  }

  String getMediaType() {
    return MediaType.JSON;
  }
}

class XMLTransformer implements Transformer {

  String transform(dynamic object) {
//    Reflector reflector = new Reflector();
//    String result = "";
//
//    reflector.getPublicAttributes(object).forEach((VariableMirror vm) {
//      result += "<${MirrorSystem.getName(vm.simpleName)}>${reflector.getFieldValue(object, vm.simpleName)}</${MirrorSystem.getName(vm.simpleName)}>";
//    });

    return "<xml></xml>";
  }

  String getMediaType() {
    return MediaType.XML;
  }

}