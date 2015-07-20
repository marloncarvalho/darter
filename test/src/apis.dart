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
@MediaType(consume: MediaType.XML, produce: MediaType.XML)
class APIWithMediaType {
}

@API()
@MediaType(consume: "Wrong", produce: MediaType.XML)
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
class APIMustIgnoreMethodsWithoutAnnotations{

  String get() {}
  String post() {}
}

@API(path: '')
class APIWithMethods {

  @GET()
  get() {}

  @POST()
  post() {}

  @PUT()
  put() {}

  @DELETE()
  delete() {}

}

@API(path: '')
@MediaType(consume: MediaType.JSON, produce: MediaType.XML)
class APIMethodsInheritsMediaTypeFromClass {

  @GET()
  get() {}

}

@API(path: '')
@MediaType(consume: MediaType.JSON, produce: MediaType.XML)
class APIOverrideMediaTypeFromClass {

  @GET()
  @MediaType(consume: MediaType.XML, produce: MediaType.JSON)
  get() {}

}

@API(path: 'api')
class APIComposedPath {

  @GET(path: 'path1/path2')
  get() {}

}

@API(path: 'api')
class APIMethodParameters {

  @GET()
  get(String str, Map map, List list) {}

}