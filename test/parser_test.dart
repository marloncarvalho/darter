library darter.tests.path;

import 'package:test/test.dart';
import 'src/apis.dart';
import 'package:darter/src/metadata/parser.dart';
import 'package:darter/src/metadata/api.dart';
import 'package:darter/src/annotations.dart';
import 'package:darter/src/path.dart';

void main() {

  group("testing parser", () {

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

    test('it should create the correct hierarchy of APIs when using @Include annotation', () {
      Parser parser = new Parser();
      APIGroup apiGroup = new APIGroup();
      Api api = parser.parseApi(apiGroup);

      expect(api.children.length, equals(1));
      expect(api.children[0].children.length, equals(1));
    });

    test('it should create a correct path when APIs are grouped.', () {
      Parser parser = new Parser();
      APIGroup apiGroup = new APIGroup();
      Api api = parser.parseApi(apiGroup);

      Path path1 = new Path.fromString("group/level_1_include");
      Path path2 = new Path.fromString("group/level_1_include/level_2_include");

      expect(api.children[0].path, equals(path1));
      expect(api.children[0].children[0].path, equals(path2));
    });
  });

}