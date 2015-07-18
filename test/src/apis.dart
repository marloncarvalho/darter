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
