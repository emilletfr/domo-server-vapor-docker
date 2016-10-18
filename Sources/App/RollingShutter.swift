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
    /**
     Turn the convertible into a node
     
     - throws: if convertible can not create a Node
     - returns: a node if possible
     */
    public func makeNode(context: Context) throws -> Node {
              return try Node(node: ["name":name, "open":open , "order":order , "progOrManual":progOrManual , "progOnSunriseOrFixed":progOnSunriseOrFixed , "progOnSunriseOffset":progOnSunriseOffset , "progOnFixedTime":progOnFixedTime , "progOffSunsetOrFixed":progOffSunsetOrFixed , "progOffSunsetOffset":progOffSunsetOffset , "progOffFixedTime":progOffFixedTime ])
    }

    
    var id: Node?
    var name: String
    var open: Bool
    var order: Int
    var progOrManual:Bool
    var progOnSunriseOrFixed:Bool
    var progOnSunriseOffset:String
    var progOnFixedTime:String
    var progOffSunsetOrFixed:Bool
    var progOffSunsetOffset:String
    var progOffFixedTime:String

    
    // used by fluent internally
    var exists: Bool = false
    
    init(name: String, open:Bool, order:Int, progOrManual:Bool, progOnSunriseOrFixed:Bool, progOnSunriseOffset:String, progOnFixedTime:String, progOffSunsetOrFixed:Bool, progOffSunsetOffset:String, progOffFixedTime:String)
    {
        self.name = name
        self.open = open
        self.order = order
        self.progOrManual = progOrManual
        self.progOnSunriseOrFixed = progOnSunriseOrFixed
        self.progOnSunriseOffset = progOnSunriseOffset
        self.progOnFixedTime = progOnFixedTime
        self.progOffSunsetOrFixed = progOffSunsetOrFixed
        self.progOffSunsetOffset = progOffSunsetOffset
        self.progOffFixedTime = progOffFixedTime
    }
    
    init(node: Node, in context: Context) throws {
        self.id = UUID().uuidString.makeNode()
        self.name = try node.extract("name")
        self.open = try node.extract("open")
        self.order = try node.extract("order")
        self.progOrManual = try node.extract("progOrManual")
        self.progOnSunriseOrFixed = try node.extract("progOnSunriseOrFixed")
        self.progOnSunriseOffset = try node.extract("progOnSunriseOffset")
        self.progOnFixedTime = try node.extract("progOnFixedTime")
        self.progOffSunsetOrFixed = try node.extract("progOffSunsetOrFixed")
        self.progOffSunsetOffset = try node.extract("progOffSunsetOffset")
        self.progOffFixedTime = try node.extract("progOffFixedTime")
     }
    /*
    func makeNode() throws -> Node {
        return try Node(node: ["name":name, "open":open , "order":order , "progOrManual":progOrManual , "progOnSunriseOrFixed":progOnSunriseOrFixed , "progOnSunriseOffset":progOnSunriseOffset , "progOnFixedTime":progOnFixedTime , "progOffSunsetOrFixed":progOffSunsetOrFixed , "progOffSunsetOffset":progOffSunsetOffset , "progOffFixedTime":progOffFixedTime ])
    }
 */
    
}

extension RollingShutter: Preparation {
    static func prepare(_ database: Database) throws
    {
        try database.create(entity) { builder in
            builder.id()
            builder.string("name")
            builder.bool("open")
            builder.int("order")
            builder.bool("progOrManual")
            builder.bool("progOnSunriseOrFixed")
            builder.string("progOnSunriseOffset")
            builder.string("progOnFixedTime")
            builder.bool("progOffSunsetOrFixed")
            builder.string("progOffSunsetOffset")
            builder.string("progOffFixedTime")
        }
    }
    
    static func revert(_ database: Database) throws {
        //
    }
}


extension RollingShutter {
    public convenience init?(from name: String, open:Bool, order:Int, progOrManual:Bool, progOnSunriseOrFixed:Bool, progOnSunriseOffset:String, progOnFixedTime:String, progOffSunsetOrFixed:Bool, progOffSunsetOffset:String, progOffFixedTime:String) throws {
        self.init(name:name, open:open, order:order, progOrManual:progOrManual, progOnSunriseOrFixed:progOnSunriseOrFixed, progOnSunriseOffset:progOnSunriseOffset, progOnFixedTime:progOnFixedTime, progOffSunsetOrFixed:progOffSunsetOrFixed, progOffSunsetOffset:progOffSunsetOffset, progOffFixedTime:progOffFixedTime)
    }
    


}
