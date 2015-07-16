library darter.tests.path;

import 'package:test/test.dart';
import 'package:darter/darter.dart';
import 'package:darter/src/path.dart';

void main() {

  group("teting constructor fromString()", () {

    setUp(() {
    });

    test('constructor "fromString" creates a correct path array', () {
      Path path = new Path.fromString("/testing/darter/path/creation");

      expect(path.parts.length, equals(4));
      expect(path.parts[0], equals('testing'));
      expect(path.parts[1], equals('darter'));
      expect(path.parts[2], equals('path'));
      expect(path.parts[3], equals('creation'));
    });

    test("constructor 'fromString' shouldn't create empty paths when incorrect URIs are used.", () {
      Path path = new Path.fromString("/testing//test//");

      expect(path.parts.length, equals(2));
      expect(path.parts[0], equals('testing'));
      expect(path.parts[1], equals('test'));
    });

    test("constructor 'fromString' should ignore null strings and create an empty path.", () {
      Path path = new Path.fromString(null);

      expect(path.parts.length, equals(0));
    });
  });

  group("testing method subPath()", () {

    test("subPath returns correct paths.", () {
      Path path = new Path.fromString('/testing/darter/subpath');

      Path subPath1 = path.subPath(start:0, end:1);
      expect(subPath1.parts.length, equals(1));
      expect(subPath1.parts[0], equals('testing'));

      Path subPath2 = path.subPath(start:1, end:2);
      expect(subPath2.parts.length, equals(1));
      expect(subPath2.parts[0], equals('darter'));

      Path subPath3 = path.subPath(start:2, end:3);
      expect(subPath3.parts.length, equals(1));
      expect(subPath3.parts[0], equals('subpath'));
    });

    test("subPath with start smaller than end should throw a RangeError exception.", () {
      Path path = new Path.fromString('/testing/darter/subpath');
      expect(() => path.subPath(start:2, end:1), throws);
    });

    test("subPath with range out of bounds should throws an exception.", () {
      Path path = new Path.fromString('/testing/darter/subpath');
      expect(() => path.subPath(start:5, end:6), throws);
    });
  });

  group("testing method join()", () {
    test("it should join two paths correctly.", () {
      Path path = new Path.fromString('/testing/');
      Path path2 = new Path.fromString('/darter');
      Path pathJoined = path.join(path2);

      expect(pathJoined.parts.length, equals(2));
      expect(pathJoined.parts[0], equals('testing'));
      expect(pathJoined.parts[1], equals('darter'));
    });

    test("trying to join null value returns ArgumentError.", () {
      expect(() => new Path.fromString("/").join(null), throwsA(new isInstanceOf<ArgumentError>()));
    });
  });

  group("testing method ==", () {
    test("it should return false when two paths are different", () {
      Path path = new Path.fromString('/testing/');
      Path path2 = new Path.fromString('/darter');

      expect(path == path2, equals(false));
    });

    test("it should return true when two paths are equal", () {
      Path path = new Path.fromString('/testing/');
      Path path2 = new Path.fromString('/testing');

      expect(path == path2, equals(true));
    });
  });

}