# Darter
Darter is an effort to create a simple and efficient framework in the Dart Language that embraces all REST principles, as proposed by Roy Fielding in his thesis. Darter doesn't impose annoying limitations that you'll find in the available Dart libraries, like forcing you to use only one versioning strategy (through the URI, for example). Darter is straightforward and really easy to setup as you'll see in our documentation and examples.

## Why should I use Darter?
Because you want flexibility to implement your API using all REST principles. We believe that you shouldn't be limited by a framework when building a new application. Instead, it should empower you with compeling tools that help you to create amazing REST APIs.

## Simple Example

* Create a new directory named **mydarter**.
* In this directory, create a file named pubspec.yaml and put the code above inside it.

```
name: beer
version: 0.0.1
author: Your Name
description: API for exposing beer data.
homepage: Your Homepage
environment:
  sdk: '>=1.8.3 <2.0.0'
dependencies:
  collection: '>=1.1.1 <2.0.0'
  darter: '0.0.1.beta'
```

* Run `pub get` to update your project dependencies
* Create a file named `main.dart` in the project's main directory. 
* Add the following code to this file.

```dart
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
```

In the command line, just type `dart main.dart`, open your favorite browser, and point it to the address `http://localhost:8080/beers`. You'll see a JSON Array containing two Strings.

## Documentation and Examples
First off, read our [Getting Started](https://github.com/marloncarvalho/darter/wiki/Getting-Started) documentation and follow the links in our Wiki. Moreover, we're writing an example application that is hosted at https://github.com/marloncarvalho/beer-api-darter/.

## Is it ready for production?
Not yet. This project is in early stages. But if you liked it, contact us and help us create an amazing REST framework!
