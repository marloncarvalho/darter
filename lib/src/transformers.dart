library darter.transformers;

import 'package:darter/src/annotations.dart';
import 'package:dartson/dartson.dart';

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
    return "<xml></xml>";
  }

  String getMediaType() {
    return MediaType.XML;
  }

}