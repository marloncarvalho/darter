library darter.tests.path;

import 'package:test/test.dart';
import 'package:darter/darter.dart';
import 'package:darter/src/path.dart';
import 'src/apis.dart';
import 'package:darter/src/metadata/parser.dart';

void main() {

  group("testing parse the api", ()
  {

    test('it should throw an exception when a class without annotation is parsed.', () {
      Parser parser = new Parser();
      APIWithoutAnnotation api = new APIWithoutAnnotation();
      expect(() => parser.parseApi(api), throws);
    });

    test('it should throw an exception when a class without annotation is parsed.', () {
      Parser parser = new Parser();
      APIWithoutAnnotation api = new APIWithoutAnnotation();
      expect(() => parser.parseApi(api), throws);
    });

  });

}