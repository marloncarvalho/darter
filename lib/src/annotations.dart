library darter.annotations;

/**
 * Holds constants about resource formats.
 */
class Format {
  static const String JSON = 'json';
  static const String XML = 'xml';
}

/**
 * Holds constants about version strategies.
 */
class Using {
  static const String HEADER = 'header';
  static const String PATH = 'path';
}

class Interceptor {
  static const String BEFORE = "1";
  static const String AFTER = "2";

  final int priority;
  final String when;

  const Interceptor({this.when, this.priority});
}

/**
 * Use this annotation to tell Darter that a class has
 * route handlers. Routes handlers are methods annotated with
 * @GET, @PUT, @POST, @PATCH or @DELETE.
 *
 * Just annotating methods with these annotations isn't enough to
 * turns Darter aware that it must create these routes. The class containing
 * these annotated methods must be annotated with @API.
 *
 * The path attribute will be used to create a default route.
 */
class API {
  final String path;
  final String format;

  const API({this.path, this.format});
}

/**
 * Use as annotation to declare the API version.
 * Use it in conjunction with @API annotation.
 *
 * @API(path:'tests')
 * @Version(using:Using.PATH)
 * class MyAPI {}
 */
class Version {
  final String version;
  final String using;
  final String vendor;
  final String format;

  const Version({this.version, this.using, this.vendor, this.format});
}

/**
 * It's a method level annotation. Shouldn't be used at a class.
 */
class ErrorHandler {
  const ErrorHandler();
}

class Method {
  final String path;

  const Method({this.path});
}

/**
 * Creates a GET route using the provided path.
 */
class GET extends Method {
  const GET({path}):super(path:path);
}

/**
 * Creates a POST route using the provided path.
 */
class POST extends Method {
  const POST({path}):super(path:path);
}

/**
 * Creates a PUT route using the provided path.
 */
class PUT extends Method {
  const PUT({path}):super(path:path);
}

/**
 * Creates a DELETE route using the provided path.
 */
class DELETE extends Method {
  const DELETE({path}):super(path:path);
}

/**
 * Creates a PATCH route using the provided path.
 */
class PATCH extends Method {
  const PATCH({path}):super(path:path);
}

class MediaType {
  static const String JSON = 'application/json';
  static const String XML = 'application/xml';
  static const String IMAGE_PNG = 'image/png';

  final List<String> produces;
  final List<String> consumes;

  const MediaType({this.produces, this.consumes});
}

class Include {
  const Include();
}

class Before {
  const Before();
}

class After {
  const After();
}