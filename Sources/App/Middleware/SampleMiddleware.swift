import Vapor
import HTTP

class SampleMiddleware: Loggable, Middleware
{
	func respond(to request: Request, chainingTo chain: Responder) throws -> Response {
        // You can manipulate the request before calling the handler
        // and abort early if necessary, a good injection point for
        // handling auth.

        log("SampleMiddleware")
        log(request)

        let response = try chain.respond(to: request)
        
      //  print("startLine:"+response.startLine)
        if request.startLine.range(of: ".css")?.isEmpty == false
        {
            response.headers["Content-Type"] = "text/css"
        }
        
        response.headers["Access-Control-Allow-Origin"] = "*"
        response.headers["Access-Control-Allow-Headers"] = "Origin, X-Requested-With, Content-Type, Accept"
        response.headers["Access-Control-Allow-Methods"] = "POST, GET, OPTIONS, DELETE, PUT"
        response.headers["Access-Control-Max-Age"] = "1000"
        
        
       // content-type, accept
       // print(response)
        
   //     response.h

        // You can also manipulate the response to add headers
        // cookies, etc.

        return response

        // Vapor Middleware is based on S4 Middleware.
        // This means you can share it with any other project
        // that uses S4 Middleware. 
	}

}
