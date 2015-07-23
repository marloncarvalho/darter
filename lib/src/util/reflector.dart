library darter.util.reflector;

import 'dart:mirrors';

class Reflector {

  Object invoke(Object object, Symbol method, [List params]) {
    if (params == null) params = [];
    return reflect(object).invoke(method, params).reflectee;
  }

  List getFieldsValueAnnotatedWith(dynamic apiObject, dynamic annot) {
    List result = [];

    InstanceMirror instanceMirror = reflect(apiObject);
    ClassMirror classMirror = reflectClass(apiObject.runtimeType);

    for (var v in classMirror.declarations.values) {
      if (v is VariableMirror) {
        var annotation = searchByAnnotations(v, [annot]);
        if (annotation != null) {
          result.add(instanceMirror.getField(v.simpleName).reflectee);
        }
      }
    }

    return result;
  }

  dynamic searchByAnnotations(dynamic mirror, List annotations) {
    var result = null;

    for (var instance in mirror.metadata) {
      if (instance.hasReflectee) {
        for (var a in annotations) {
          if (instance.reflectee.runtimeType == a) {
            result = instance.reflectee;
            break;
          }
        }
      }
    }

    return result;
  }

  Object getAnnotation(Object obj, Type annotationType) {
    var result = null;
    ClassMirror classMirror = reflectClass(obj.runtimeType);

    for (var instance in classMirror.metadata) {
      if (instance.hasReflectee) {
        if (instance.reflectee.runtimeType == annotationType) {
          result = instance.reflectee;
          break;
        }
      }
    }

    return result;
  }

  bool existsMethod(Symbol method, dynamic object) {
    ClassMirror cm = reflectClass(object.runtimeType);
    bool result = false;

    for (MethodMirror mm in cm.instanceMembers.values) {
      if (mm.simpleName == method) {
        result = true;
        break;
      }
    }

    return result;
  }

  Object instantiate(Type type, Symbol name, List params) {
    ClassMirror cm = reflectClass(type);
    return cm.newInstance(name, params).reflectee;
  }

}