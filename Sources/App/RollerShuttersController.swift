//
//  RollerShutters.swift
//  VaporApp
//
//  Created by Eric on 18/10/2016.
//
//

import Foundation
import Dispatch
import Vapor
import HTTP

class RollerShuttersController
{
    let actionQueue = DispatchQueue(label: "RollerShuttersController.Action")
    var allOpened = false
    
    init()
    {
        drop.get("rollershutters", "status")
        { request in
            return self.allOpened ? "1" : "0"
        }

        drop.get("rollershutters", Int.self)
        { request, open in
            self.actionQueue.sync {
                self.allOpened = open == 1
                self.action(openOrClose: open == 1)
            }
            return try JSON(node: ["open": open])
        }
    }
    
    func action(openOrClose:Bool)
    {
        let state = openOrClose ? "1" : "0"
        do
        {
            for index in 0...3
            {
                let urlString = "http://10.0.1.1\(index)/\(state)"
                _ = try drop.client.get(urlString)
                log("RollerShuttersOpen : \(state)")
                sleep(13)
            }
        }
        catch {log(error)}
    }
}
