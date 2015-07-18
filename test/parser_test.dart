library darter.tests.path;

import 'package:test/test.dart';
import 'src/apis.dart';
import 'package:darter/src/metadata/parser.dart';
import 'package:darter/src/metadata/api.dart';
import 'package:darter/src/annotations.dart';

void main() {

  group("testing parser", ()
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

    test('it should create a default path when no path is provided.', () {
      Parser parser = new Parser();
      APIWithoutPath api = new APIWithoutPath();
      Api a = parser.parseApi(api);
      expect(a.path.parts.length, equals(0));
    });

    test('it should set the attributes consume and produce to JSON when no values are provided.', () {
      Parser parser = new Parser();
      APIWithoutMediaType api = new APIWithoutMediaType();
      Api a = parser.parseApi(api);
      expect(a.consume, equals(MediaType.JSON));
      expect(a.produce, equals(MediaType.JSON));
    });

    test('it should respect the provided media types values.', () {
      Parser parser = new Parser();
      APIWithMediaType api = new APIWithMediaType();

      Api a = parser.parseApi(api);
      expect(a.consume, equals(MediaType.XML));
      expect(a.produce, equals(MediaType.XML));
    });

    test('it should throw an expcetion when an incorrect media type is provided.', () {
      Parser parser = new Parser();
      APIWithIncorrectMediaType api = new APIWithIncorrectMediaType();

      expect(() => parser.parseApi(api), throws);
    });

    test('it should create a correct path when apis are grouped.', () {

    });
  });

}