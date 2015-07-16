# Darter
Darter is an effort to create a simple and efficient framework in the Dart Language that embraces all REST principles, as proposed by Roy Fielding in his thesis. Darter doesn't impose annoying limitations that you'll find in the available Dart libraries, like forcing you to use only one versioning strategy (through the URI, for example). Darter is straightforward and really easy to setup as you'll see in our documentation and examples.

## Why should I use Darter?
Because you want flexibility to implement your API using all REST principles. We believe that you shouldn't be limited by a framework when building a new application. Instead, it should empower you with compeling tools that help you to create amazing REST APIs.

## Darter by Example
Darter is really simple. To convince you of it, lets create a simple example. First off, create your `pubspec.yaml` file and create a dependency to Darter inside it.

    dependencies:
        darter: any

Now, create a file named `main.dart` in the root directory of your project, create a class with a name of your choice and to it the `@API` annotation:

    import 'package:darter/darter.dart';

    @API(path: 'categories')
    @Version(version: 'v1', vendor: 'company', format: Format.JSON, using: Using.HEADER)
    class MyDarterAPI {
    
        @GET()
        List<MyModel> list() {
            ...
        }
        
        @GET(path: ':id')
        MyModel get(Map pathParams) {
            return MyModel.findById(pathParams['id']);
        }
        
        @PUT(path: ':id')
        Response put(PathParams params, MyModel myModel) {
            if(MyModel.get(params.get("id")) == null) {
              return new Response
                 ..statusCode == 201
                 ..entity = "Created";
            } else {
              return new Response
                 ..statusCode == 200
                 ..entity = "Updated";
            }
        }
        
        @POST()
        MyModel post(MyModel myModel) {
        }
        
        @DELETE(path: 'id')
        void delete(Map pathParams) {
            MyModel.get(pathParams['id']).delete();
        }
    }
    
    main() {
        new DarterServer()
            ..addApi(new MyDarterAPI())
            ..start();
    }
    
This annotation receives only one argument that informs the base path to this API.

## Interceptors
Interceptors are useful to implement features like authentication, cors, and body transformations. For example, create an interceptor if you want to intercept a request before your resource method has been called and check if the user has authorization to access this resource. 

You define an interceptor using the `@Interceptor` annotation and defining `when` it must be called (`Interceptor.BEFORE` or `Interceptor.AFTER`) and its `priority` in the chain. Observe that your annotated class must have a method named `intercept` receiving only one argument of the type `Chain` as in the example below.

    @Interceptor(when: Interceptor.AFTER, priority: 0)
    class Cors {
    
        void intercept(Chain chain) {
            chain.response.headers["Access-Control-Allow-Origin"] = "*";
            chain.response.headers["Access-Control-Allow-Credentials"] = "true";
            chain.response.headers["Access-Control-Allow-Methods"] = "GET, POST, DELETE, PUT";
            chain.response.headers["Access-Control-Allow-Headers"] = "*";
        }
        
    }

You can do a lot of things in your interceptor including manipulate the request headers, as pointed in the example above. You're even able to abort the execution before your resource method has been called.

    @Interceptor(when:Interceptor.BEFORE, priority: 1)
    class Authentication {
        
        void intercept(Chain chain) {
            String token = chain.request.headers["X-Token"];
            if (token != "Test") {
              chain.abort(new Response()
                ..body = "{\"error\":\"Permission Denied\"}"
                ..statusCode = 401);
            }
        }
    }
    
## Path Parameters
In order to get access to all path parameters, you must add an argument of the type Map in your resource method and name it `pathParams`. Notice that it's a convention and therefore this parameter must be named like that.

    @DELETE(path: 'id')
    void delete(Map pathParams) {
        MyModel.get(pathParams['id']).delete();
    }
    
## Query Parameters
The same happens with the Query Parameters. You can access it adding an argument of the type Map and named `queryParams`.
    @GET()
    List<MyModel> list(Map queryParams) {
    }

## Versioning
Darter allows you to choose two versioning strategies: Path or Header. In the Path strategy, the version is provided in the URI, like in `http://domain/<version>`. To use this strategy, use the the `@Version` annotation with the `using` attribute setted to `Using.HEADER`.
    
    @API(path: 'categories')
    @Version(version: 'v1', using: Using.PATH)
    class MyDarterAPI {
    }
    
In the other hand, the header strategy searches the `Accept` header for the version. Notice that you must follow a convention to create this header. It must be something like `application/vnd.<vendor>.<version>+<format>`. We didn't invent it, it's in the RFC! Therefore, when you choose the Header strategy, you are forced to declare three more parameters to the `@Version` annotation: `vendor`, `version`, and `format`.

    @API(path: 'categories')
    @Version(version: 'v1', vendor: 'company', format: Format.JSON, using: Using.HEADER)
    class MyDarterAPI {
    }

## Is it ready for production?
Not yet. This project is in early stages. But if you liked it, contact us and help us create an amazing REST framework!
