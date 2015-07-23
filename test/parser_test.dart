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
      expect(a.consumes, equals([MediaType.JSON, MediaType.XML]));
      expect(a.produces, equals([MediaType.JSON, MediaType.XML]));
    });

    test('it should respect the provided media types values.', () {
      Parser parser = new Parser();
      APIWithMediaType api = new APIWithMediaType();

      Api a = parser.parseApi(api);
      expect(a.consumes, equals([MediaType.XML]));
      expect(a.produces, equals([MediaType.XML]));
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

    test('it should set the correct parents in a grouped api.', () {
      Parser parser = new Parser();
      APIGroup apiGroup = new APIGroup();
      Api api = parser.parseApi(apiGroup);

      expect(api.children[0].parent, equals(api));
      expect(api.children[0].children[0].parent, equals(api.children[0]));
    });

    test('it should ignore methods without annotations.', () {
      Parser parser = new Parser();
      APIMustIgnoreMethodsWithoutAnnotations api = new APIMustIgnoreMethodsWithoutAnnotations();
      Api parsed = parser.parseApi(api);

      expect(parsed.methods.length, equals(0));
    });

    test('it should parse all methods.', () {
      Parser parser = new Parser();
      APIWithMethods api = new APIWithMethods();
      Api parsed = parser.parseApi(api);

      expect(parsed.methods.length, equals(4));
      expect(parsed.methods[0].method, equals('GET'));
      expect(parsed.methods[1].method, equals('POST'));
      expect(parsed.methods[2].method, equals('PUT'));
      expect(parsed.methods[3].method, equals('DELETE'));

      expect(parsed.methods[0].name, equals(new Symbol('get')));
      expect(parsed.methods[1].name, equals(new Symbol('post')));
      expect(parsed.methods[2].name, equals(new Symbol('put')));
      expect(parsed.methods[3].name, equals(new Symbol('delete')));
    });

    test('it should respect media type inheritance from class to method when method doesnt define it.', () {
      Parser parser = new Parser();
      APIMethodsInheritsMediaTypeFromClass api = new APIMethodsInheritsMediaTypeFromClass();
      Api parsed = parser.parseApi(api);
      expect(parsed.methods[0].consumes, equals([MediaType.JSON]));
      expect(parsed.methods[0].produces, equals([MediaType.XML]));
    });

    test('it should override media type from class.', () {
      Parser parser = new Parser();
      APIOverrideMediaTypeFromClass api = new APIOverrideMediaTypeFromClass();
      Api parsed = parser.parseApi(api);
      expect(parsed.methods[0].consumes, equals([MediaType.XML]));
      expect(parsed.methods[0].produces, equals([MediaType.JSON]));
    });

    test('it should compose the method path using the class path.', () {
      Parser parser = new Parser();
      APIComposedPath api = new APIComposedPath();
      Api parsed = parser.parseApi(api);

      expect(parsed.methods[0].path.length, equals(3));
      expect(parsed.methods[0].path.parts[0], equals('api'));
      expect(parsed.methods[0].path.parts[1], equals('path1'));
      expect(parsed.methods[0].path.parts[2], equals('path2'));
    });

    test('it should get all method parameters.', () {
      Parser parser = new Parser();
      APIMethodParameters api = new APIMethodParameters();
      Api parsed = parser.parseApi(api);

      expect(parsed.methods[0].parameters.length, equals(3));
      expect(parsed.methods[0].parameters[0].name, equals(new Symbol('str')));
      expect(parsed.methods[0].parameters[1].name, equals(new Symbol('map')));
      expect(parsed.methods[0].parameters[2].name, equals(new Symbol('list')));

      expect(parsed.methods[0].parameters[0].type, equals(String));
      expect(parsed.methods[0].parameters[1].type, equals(Map));
      expect(parsed.methods[0].parameters[2].type, equals(List));
    });

  });

}