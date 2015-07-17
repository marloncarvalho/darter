library beer;

import 'package:darter/darter.dart';

@API(path: 'beers')
class BeerAPI {

  @GET()
  List get() {
    return ["Beer 1", "Beer 2"];
  }

}

main() {
  new DarterServer()
    ..addApi(new BeerAPI())
    ..start();
}