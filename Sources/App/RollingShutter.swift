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


final class RollingSutter: Model {
    
    var id: Node?
    var open: Bool
    
    
    // used by fluent internally
    var exists: Bool = false
    
    init(open: Bool) {
        self.open = open
    }
    
    init(node: Node, in context: Context) throws {
        self.id = UUID().uuidString.makeNode()
        self.open = try node.extract("open")
     }
    
    func makeNode() throws -> Node {
        return try Node(node: [
            "open": open
            ])
    }
    
}

extension RollingSutter: Preparation {
    static func prepare(_ database: Database) throws {
        
        print("static func prepare(_ database: Database) throws {")
        
        try database.create(entity) { builder in
            builder.id()
            builder.bool("open")
        }
    }
    
    static func revert(_ database: Database) throws {
        //
    }
}


extension RollingSutter {
    public convenience init?(from open: Bool) throws {
        self.init(open:open)
    }
    


}
