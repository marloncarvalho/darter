[![Build Status](https://drone.io/github.com/marloncarvalho/darter/status.png?random=1)](https://drone.io/github.com/marloncarvalho/darter/latest)

# Darter
Darter is an effort to create a simple and efficient framework that allows you to create RESTful APIs in the Dart Language. Our goal is to create a simple and easy-to-use library, through which you'll be able to create APIs using whatever approach you prefer. Do you prefer the path versioning strategy? Darter allows you to do it. Would like to use the content type through extension strategy? Darter allows you to do it too.

## Why should I use Darter?
Because you want flexibility to implement your API. We believe that you shouldn't be limited by a framework when building a new application. Instead, it should empower you with compeling tools that help you to create amazing REST APIs.

Because you want performance. Because you would like to create an API using one of the most cool languages in the world. Because, it's cool!

## First Example

Lets create our first Darter API!

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
  List<Beer> get() {
    return Beer.all();
  }

  @POST()
  Beer post(Beer beer) {
    beer.save();
    return beer;
  }

  @GET(path: ':id')
  Beer getById(Parameters pathParams) {
    return Beer.get(pathParams.getInt('id'));
  }

  @PUT(path: ':id')
  Response put(Beer iBeer, Parameters pathParams) {
    Response response = new Response(statusCode: 200);

    Beer beer = Beer.get(pathParams.getInt('id'));
    if(beer != null) {
      beer.name = iBeer.name;
      response.statusCode = 201;
      response.entity = beer;
    } else {
      iBeer.id = pathParams.getInt('id');
      iBeer.save();
      response.entity = iBeer;
    }


    return response;
  }

  @DELETE(path: ':id')
  Beer delete(Parameters pathParams) {
    Beer.get(pathParams.getInt('id')).delete();
  }

}

class Beer {
  int id;
  String name;

  Beer({this.name, this.id});

  void save() {}
  void delete() {}

  static Beer get(int id) {
    return new Beer(id: id, name: "Beer ${id}");
    }

    static List<Beer> all() {
      return [new Beer(id: 1, name: 'Beer 1'), new Beer(id: 2, name: 'Beer 2')];
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
