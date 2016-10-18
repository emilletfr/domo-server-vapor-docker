import Vapor
import HTTP

final class TemperatureController: ResourceRepresentable {
    typealias Item = Temperature
    

    func index(request: Request) throws -> ResponseRepresentable {
     return try Temperature.all().makeNode().converted(to: JSON.self)
    }

    func create(request: Request) throws -> ResponseRepresentable {
        var temp = try request.temperature()
        try temp.save()
        return try temp.makeJSON()
    }

    
    
    /**
    	Since item is of type User,
    	only instances of user will be received
    */
    func show(request: Request, item user: Temperature) throws -> ResponseRepresentable {
        //User can be used like JSON with JsonRepresentable
        return try JSON(node: [
            "controller": "UserController.show",
            "user": user
        ])
    }

    func update(request: Request, item temperature: Temperature) throws -> ResponseRepresentable {
        //User is JsonRepresentable
        return try temperature.makeJSON()
    }

    func destroy(request: Request, item temperature: Temperature) throws -> ResponseRepresentable {
        //User is ResponseRepresentable by proxy of JsonRepresentable
        return temperature
    }

    func makeResource() -> Resource<Temperature> {
        return Resource(
            index: index,
            store: create,
            show: show,
            replace: update,
            destroy: destroy
        )
    }
}

extension Request {
    func temperature() throws -> Temperature {
        guard let json = json else
        {
            throw Abort.badRequest
        }
        return try Temperature(node: json)
    }

}
