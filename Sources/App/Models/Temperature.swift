import Vapor
import Fluent
import Foundation

final class Temperature: Model
{
    /**
     Turn the convertible into a node
     
     - throws: if convertible can not create a Node
     - returns: a node if possible
     */
    public func makeNode(context: Context) throws -> Node {
        return try Node(node: [
            "color": color,
            "value":value
            ])
    }

    var id: Node?
    var color: String
    var value:Float
    
    
    // used by fluent internally
    var exists: Bool = false
    
    init(value:Float, color: String) {
        self.color = color
        self.value = value
    }

    init(node: Node, in context: Context) throws {
        self.id = UUID().uuidString.makeNode()
        self.color = try node.extract("color")
        self.value = try node.extract("value")
    }
/*
    func makeNode() throws -> Node {
        return try Node(node: [
            "color": color,
            "value":value
        ])
    }
 */

}

extension Temperature: Preparation {
    static func prepare(_ database: Database) throws {
        try database.create(entity) { builder in
            builder.id()
            builder.string("color")
            builder.double("value")
        }
    }
    
    static func revert(_ database: Database) throws {
        //
    }
}


extension Temperature {
    public convenience init?(from value: Float, color:String) throws {
        self.init(value:value, color:color)
    }
 
}

