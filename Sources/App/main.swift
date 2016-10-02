import Vapor
import HTTP
import Fluent
import VaporSQLite
import Foundation


let drop = Droplet(preparations:[Temperature.self], providers:[VaporSQLite.Provider.self])
let _ = drop.config["app", "key"]?.string ?? ""






/*


DispatchQueue(label: "init").async {
    
    let dispatchQueue = DispatchQueue(label: "queuename", attributes: .concurrent)
    
    for  index1 in 1...400 {
        sleep(1)
        
        for  index2 in 1...10 {
            dispatchQueue.async {
                
                do {
                    let urlString = "http://api.openweathermap.org/data/2.5/weather?zip=54360,fr&APPID=9c44d7610c061d8c3a7873c51da2e885&units=metric"
                    
                    
                    
                    
                    let resp = try drop.client.request(.get, urlString, headers: ["Connection":"close"], query: ["":""], body: "")
                
                    
                    print("\(index1)-\(index2)")

                } catch {
                    print(error)
                }
                
            }
        }
    }
}

class FooMiddleware: Middleware {
    init() {}
    func respond(to request: Request, chainingTo next: Responder) throws -> Response {
        request.headers["foo"] = "bar"
        let response = try next.respond(to: request)
        response.headers["bar"] = "baz"
        return response
    }
}
 */
/*
let drop2 = Droplet(availableMiddleware: [
    "foo": FooMiddleware()
    ], clientMiddleware: ["foo"])
 */
let drop2 = Droplet()
drop2.middleware.append(FooMiddleware())

let res = try? drop2.client.get("http://httpbin.org/headers")

let ident = drop2.sessions.makeIdentifier()
drop2.sessions.destroy(ident)



/*
drop.resource("temperatures", TemperatureController())

var outdoorTempManager = OutdoorTempManager(droplet: drop)

drop.get("outdoorTemp") { request in
    guard let degresValue = outdoorTempManager.degresValue else {var res = try Response(status: .badRequest, json:  JSON(node:[])); return res}
    return String(describing: degresValue)
 }
*/

/*
var indoorTempManager = IndoorTempManager()

var sunriseSunsetManager = SunriseSunsetManager()

drop.get("sunriseTime") { request in
    guard let sunriseTime = sunriseSunsetManager.sunriseTime else {var res = try Response(status: .badRequest, json:  JSON(node:[])); return res}
    return String(describing: sunriseTime)
}

drop.get("sunsetTime") { request in
    guard let sunsetTime = sunriseSunsetManager.sunsetTime else {var res = try Response(status: .badRequest, json:  JSON(node:[])); return res}
    return String(describing: sunsetTime)
}
*/
drop.middleware.append(SampleMiddleware())
let port = drop.config["app", "port"]?.int ?? 80
drop.serve()

/**
    Vapor configuration files are located
    in the root directory of the project
    under `/Config`.

    `.json` files in subfolders of Config
    override other JSON files based on the
    current server environment.

    Read the docs to learn more
*/
/*
let _ = drop.config["app", "key"]?.string ?? ""
 */

/**
    This first route will return the welcome.html
    view to any request to the root directory of the website.

    Views referenced with `app.view` are by default assumed
    to live in <workDir>/Resources/Views/

    You can override the working directory by passing
    --workDir to the application upon execution.
*/
/*
drop.get("/") { request in
    return try drop.view.make("index.html")
}

drop.get("/", String.self) { request, arg in
    return try drop.view.make(arg)
}
 */




/**
    Return JSON requests easy by wrapping
    any JSON data type (String, Int, Dict, etc)
    in JSON() and returning it.

    Types can be made convertible to JSON by
    conforming to JsonRepresentable. The User
    model included in this example demonstrates this.

    By conforming to JsonRepresentable, you can pass
    the data structure into any JSON data as if it
    were a native JSON data type.
*/
/*
drop.get("json") { request in
    return try JSON(node: [
        "number": 123,
        "string": "test",
        "array": try JSON(node: [
            0, 1, 2, 3
        ]),
        "dict": try JSON(node: [
            "name": "Vapor",
            "lang": "Swift"
        ])
    ])
}
 */

/**
    This route shows how to access request
    data. POST to this route with either JSON
    or Form URL-Encoded data with a structure
    like:

    {
        "users" [
            {
                "name": "Test"
            }
        ]
    }

    You can also access different types of
    request.data manually:

    - Query: request.data.query
    - JSON: request.data.json
    - Form URL-Encoded: request.data.formEncoded
    - MultiPart: request.data.multipart
*/
/*
drop.get("data", Int.self) { request, int in
    return try JSON(node: [
        "int": int,
        "name": request.data["name"]?.string ?? "no name"
    ])
}
 */

/**
    Here's an example of using type-safe routing to ensure
    only requests to "posts/<some-integer>" will be handled.

    String is the most general and will match any request
    to "posts/<some-string>". To make your data structure
    work with type-safe routing, make it StringInitializable.

    The User model included in this example is StringInitializable.
*/
/*
drop.get("posts", Int.self) { request, postId in
    return "Requesting post with ID \(postId)"
}
*/
/**
    This will set up the appropriate GET, PUT, and POST
    routes for basic CRUD operations. Check out the
    UserController in App/Controllers to see more.

    Controllers are also type-safe, with their types being
    defined by which StringInitializable class they choose
    to receive as parameters to their functions.
*/
/*
let temperatures = TemperatureController(droplet: drop)
drop.resource("temperatures", temperatures)
*/


/*
drop.get("leaf") { request in
    return try drop.view.make("template", [
        "greeting": "Hello, world!"
    ])
}
 */

/**
    A custom validator definining what
    constitutes a valid name. Here it is
    defined as an alphanumeric string that
    is between 5 and 20 characters.
*/
/*
class Name: ValidationSuite {
    static func validate(input value: String) throws {
        let evaluation = OnlyAlphanumeric.self
            && Count.min(5)
            && Count.max(20)

        try evaluation.validate(input: value)
    }
}
 */

/**
    By using `Valid<>` properties, the
    employee class ensures only valid
    data will be stored.
*/
/*
class Employee {
    var email: Valid<Email>
    var name: Valid<Name>

    init(request: Request) throws {
        email = try request.data["email"].validated()
        name = try request.data["name"].validated()
    }
}
*/
/**
    Allows any instance of employee
    to be returned as Json
*/
/*
extension Employee: JSONRepresentable {
    func makeJSON() throws -> JSON {
        return try JSON(node: [
            "email": email.value,
            "name": name.value
        ])
    }
}
 */

// Temporarily unavailable
//drop.any("validation") { request in
//    return try Employee(request: request)
//}

/**
    This simple plaintext response is useful
    when benchmarking Vapor.
*/
/*
drop.get("plaintext") { request in
    return "Hello, World!"
}
 */

/**
    Vapor automatically handles setting
    and retreiving sessions. Simply add data to
    the session variable and–if the user has cookies
    enabled–the data will persist with each request.
*/
/*
drop.get("session") { request in
    let json = try JSON(node: [
        "session.data": "\(request.session)",
        "request.cookies": "\(request.cookies)",
        "instructions": "Refresh to see cookie and session get set."
    ])
    var response = try Response(status: .ok, json: json)

    request.session?["name"] = "Vapor"
    response.cookies["test"] = "123"

    return response
}
 */

/**
    Add Localization to your app by creating
    a `Localization` folder in the root of your
    project.

    /Localization
       |- en.json
       |- es.json
       |_ default.json

    The first parameter to `app.localization` is
    the language code.
*/
/*
drop.get("localization", String.self) { request, lang in
    return try JSON(node: [
        "title": drop.localization[lang, "welcome", "title"],
        "body": drop.localization[lang, "welcome", "body"]
    ])
}
 */

/**
    Middleware is a great place to filter
    and modifying incoming requests and outgoing responses.

    Check out the middleware in App/Middleware.

    You can also add middleware to a single route by
    calling the routes inside of `app.middleware(MiddlewareType) {
        app.get() { ... }
    }`
*/


/*
 
 Droplets are service containers that make accessing
 all of Vapor's features easy. Just call
 `drop.serve()` to serve your application
 or `drop.client()` to create a client for
 request data from other servers.
 */




