library cryogen.test;

import 'package:test/test.dart';
import 'package:darter/src/util/reflector.dart';
import 'src/reflector_data.dart';
import 'dart:mirrors';

void main() {
  var reflector = new Reflector();

  group('Testing Reflector', () {

    test('getAnnotation() correctly finds an annotation in a class.', () {
      AnnotatedClass anCls = new AnnotatedClass();
      var annotation = reflector.getAnnotation(anCls, CryogenAnnotation);
      expect(annotation, new isInstanceOf<CryogenAnnotation>());
    });

    test('searchByAnnotations() correctly finds an annotation in a class.', () {
      AnnotatedClass anCls = new AnnotatedClass();

      var annotation = reflector.searchByAnnotations(reflectClass(anCls.runtimeType), [CryogenAnnotation]);
      expect(annotation, new isInstanceOf<CryogenAnnotation>());

      annotation = reflector.searchByAnnotations(reflectClass(anCls.runtimeType), [CryogenAnnotation2]);
      expect(annotation, new isInstanceOf<CryogenAnnotation2>());
    });

    test('existsMethod() correctly finds the method.', () {
      AnnotatedClass anCls = new AnnotatedClass();
      expect(reflector.existsMethod(new Symbol('methodExists'), anCls), equals(true));
    });

    test('existsMethod() correctly doesnt find the method.', () {
      AnnotatedClass anCls = new AnnotatedClass();
      expect(reflector.existsMethod(new Symbol('methodExistsss'), anCls), equals(false));
    });

    test('instantiage() correctly instantiates the object.', () {
      AnnotatedClass anCls = reflector.instantiate(AnnotatedClass, new Symbol(''), []);
      expect(anCls, new isInstanceOf<AnnotatedClass>());
    });

    test('invoke() correctly invokes the method.', () {
      AnnotatedClass anCls = new AnnotatedClass();
      var object = reflector.invoke(anCls, new Symbol('invokeMe'), []);
      expect(object, equals("Invoked"));
    });

    test('getFieldsValueAnnotatedWith() correctly gets all fields values from a class annotated with an specific annotation.', () {
      AnnotatedClass anCls = new AnnotatedClass();
      List list = reflector.getFieldsValueAnnotatedWith(anCls, CryogenAnnotation);
      expect(list.length, equals(3));
      expect(list[0], equals(1));
      expect(list[1], equals("2"));
      expect(list[2], equals(3.0));
    });

  });

}
