library darter.util.reflector;

import 'dart:mirrors';

class Reflector {

  Object invoke(Object object, Symbol method, [List params]) {
    if (params == null) params = [];
    return reflect(object).invoke(method, params).reflectee;
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

    for(MethodMirror mm in cm.instanceMembers.values) {
      if(mm.simpleName == method) {
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