//
//  RollingSutter.swift
//  VaporApp
//
//  Created by Eric on 05/10/2016.
//
//

import Vapor
import Fluent
import Foundation


final class RollingShutter: Model {
    
    var id: Node?
    var open: Bool
    var order: Int
    
    
    // used by fluent internally
    var exists: Bool = false
    
    init(open: Bool, order: Int) {
        self.open = open
        self.order = order
    }
    
    init(node: Node, in context: Context) throws {
        self.id = UUID().uuidString.makeNode()
        self.open = try node.extract("open")
        self.order = try node.extract("order")
     }
    
    func makeNode() throws -> Node {
        return try Node(node: ["open": open, "order": order])
    }
    
}

extension RollingShutter: Preparation {
    static func prepare(_ database: Database) throws {
        
        print("static func prepare(_ database: Database) throws {")
        
        try database.create(entity) { builder in
            builder.id()
            builder.bool("open")
            builder.int("order")
        }
    }
    
    static func revert(_ database: Database) throws {
        //
    }
}


extension RollingShutter {
    public convenience init?(from open: Bool, order: Int) throws {
        self.init(open:open, order:order)
    }
    


}
