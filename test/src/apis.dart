import 'package:darter/darter.dart';

class APIWithoutAnnotation {
}

@API()
class APIWithoutPath {
}

@API()
class APIWithoutMediaType {
}

@API()
@MediaType(consumes: const [MediaType.XML], produces: const [MediaType.XML])
class APIWithMediaType {
}

@API()
@MediaType(consumes: const ['Wrong'], produces: const [MediaType.XML])
class APIWithIncorrectMediaType {
}

@API(path: 'group')
class APIGroup {

  @Include()
  IncludeLevel1API i = new IncludeLevel1API();
}

@API(path: 'level_1_include')
class IncludeLevel1API {

  @Include()
  IncludeLevel2API i = new IncludeLevel2API();

}

@API(path: 'level_2_include')
class IncludeLevel2API {
}

@API(path: '')
class APIMustIgnoreMethodsWithoutAnnotations {

  String get() {
  }

  String post() {
  }
}

@API(path: '')
class APIWithMethods {

  @GET()
  get() {
  }

  @POST()
  post() {
  }

  @PUT()
  put() {
  }

  @DELETE()
  delete() {
  }

}

@API(path: '')
@MediaType(consumes: const [MediaType.JSON], produces: const [MediaType.XML])
class APIMethodsInheritsMediaTypeFromClass {

  @GET()
  get() {
  }

}

@API(path: '')
@MediaType(consumes: const [MediaType.JSON], produces: const [MediaType.XML])
class APIOverrideMediaTypeFromClass {

  @GET()
  @MediaType(consumes: const [MediaType.XML], produces: const [MediaType.JSON])
  get() {
  }

}

@API(path: 'api')
class APIComposedPath {

  @GET(path: 'path1/path2')
  get() {
  }

}

@API(path: 'api')
class APIMethodParameters {

  @GET()
  get(String str, Map map, List list) {
  }

}