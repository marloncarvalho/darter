# Darter
Darter is a effort to create a simple framework that embraces all REST principles, as proposed by Roy Fielding in his thesis. You can say that there're good frameworks in this area, like Redstone.dart and RPC by Google. However, those frameworks impose some limitations that are really frustrating and go against some core REST principles.

For example, RPC doesn't have a good mechanism to handle API versioning. The only strategy available forces you to inform the version at the URI. Nevertheless remember that the URI should be used only to address resources. What about Redstone? It's an amazing tool but it wasn't created with API development in mind. With Redstone you can't even work with versions because of its internal implementation that restricts us from having the same route handled by different classes/objects.

Going further, RPC doesn't have the HTTP PATCH method but has a @AddAll annotation representing a method. What doesn't make any sense. I could cite many other problems but I think I've made my point here.

## Why you should use Darter?
Because you want flexibility to implement your API using all REST principles. We think that you shouldn't be limited by a framework. Instead, it should empower you with compeling tools that help you to create amazing REST APIs.

## Darter by Example
Darter is really simple. To convince you of it, lets create a simple example. First off, create your `pubspec.yaml` file and create a dependency to Darter inside it.

    dependencies:
        darter: any

Now, create a file named `main.dart` in the root directory of your project:

    import 'package:darter/darter.dart';

    @API(path: 'categories', format: JSON)
    @Version(version: 'v1', vendor: 'company', format: 'json')
    class MyDarterAPI {
    
        @Before()
        void before(Request request) {
            // Lets do something before calling each method below.
            // For example, you can validate if the user has permission to access this API.
        }
        
        @After()
        void after() {
            // Lets do something after calling each method below.
        }
        
        @GET()
        List<MyModel> list() {
            ...
        }
        
        @GET(path: ':id')
        MyModel get(PathParams params) {
            return new MyModel();
        }
        
        @PUT(path: ':id')
        Response put(PathParams params, MyModel myModel) {
            if(MyModel.get(params.get("id")) == null) {
              return Response.status(201).entity("Created");
            } else {
              return Response.status(200).entity("Updated");
            }
        }
        
        @POST()
        MyModel post(MyModel myModel) {
        }
        
    }
    
    main() {
        DarterServer server = new DarterServer();
        server.add(new MyDarterAPI());
        server.start();
    }
    
## Is it ready for production?
Not yet. This project is in early stages. But if you liked it, contact us and help us create an amazing REST-like framework!