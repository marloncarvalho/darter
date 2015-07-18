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
