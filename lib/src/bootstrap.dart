library darter.bootstrap;

import 'dart:mirrors';
import 'package:darter/src/annotations.dart';

class Scanner {
  Set<ClassMirror> _seen = new Set();
  List<ClassMirror> apiClasses = [];
  List<ClassMirror> interceptorClasses = [];

  void scan([LibraryMirror libraryMirror]) {
    if (libraryMirror == null) {
      libraryMirror = currentMirrorSystem().isolate.rootLibrary;
    }

    if (libraryMirror.uri.toString().contains("dart:")) {
      return;
    }

    libraryMirror.libraryDependencies.where((d) => d.isImport).forEach((LibraryDependencyMirror d) {
      if (d.targetLibrary != null) {
        d.targetLibrary.declarations.values.where((dm) => dm is ClassMirror && _seen.add(dm)).forEach((ClassMirror cm) {
          cm.metadata.forEach((metadata) {
            if (metadata.reflectee is API) {
              apiClasses.add(cm);
            } else if (metadata.reflectee is Interceptor) {
              interceptorClasses.add(cm);
            }
          });
        });
        scan(d.targetLibrary);
      }
    });
  }

}