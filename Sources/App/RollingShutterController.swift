//
//  RollingShutterController.swift
//  VaporApp
//
//  Created by Eric on 04/10/2016.
//
//

import Vapor
import Foundation
import Dispatch
import HTTP

final class RollingShutterController: ResourceRepresentable {
    typealias Item = RollingShutter
    private var client: ClientProtocol.Type
    let serialQueue = DispatchQueue(label: "net.emilletfr.domo.RollingShutterController.Database")
    
    init(droplet: Droplet) {
        self.client = droplet.client
        /*
         let clientResponse = try? droplet.client.get("http://10.0.1.12/status")
         let status = clientResponse?.data["status"]?.bool ?? nil
         
         guard let open = status else {return}
         let rollingShutter = RollingShutter(open: open, index:0)
         */
        
        
        do
        {
            for rollingShutter in try RollingShutter.all() {try? rollingShutter.delete()}
            let clientResponse = try? self.client.get("http://10.0.1.12/status")
            let status = clientResponse?.data["status"]?.bool ?? false
            let names = ["Salon", "Salle a manger", "Bureau", "Cuisine"]
            for order in 0...3
            {
                do
                {
                var rollingShutter = try RollingShutter(from: names[order], open: status, order: order, progOrManual: true, progOnSunriseOrFixed: true, progOnSunriseOffset: "0", progOnFixedTime: "08:00", progOffSunsetOrFixed: true, progOffSunsetOffset: "0", progOffFixedTime: "20:00")
                try rollingShutter?.save()
                }
                catch {print(error)}
            }
        }
        catch{print(error)}
    }
    
    
    func index(request: Request) throws -> ResponseRepresentable
    {
        var responseRepresentable : ResponseRepresentable?
        try? self.serialQueue.sync
            {
                responseRepresentable = try RollingShutter.query().sort("order", .ascending).makeQuery().all().makeNode().converted(to: JSON.self)
        }
        return  responseRepresentable!
    }
    
    
    func create(request: Request) throws -> ResponseRepresentable
    {
        var responseRepresentable : ResponseRepresentable?
        try? self.serialQueue.sync
            {
                var previousOpenState = false
                var rollingShutter = try request.rollingShutter()
                for rs in try RollingShutter.query().filter("order", rollingShutter.order).makeQuery().all()
                {
                    previousOpenState = rs.open
                    do {try  rs.delete()} catch {print(error)}
                }
                do {try rollingShutter.save()} catch{print(error)}
                
                if rollingShutter.order == 2 && rollingShutter.open != previousOpenState
                {
                    _ = try? self.client.get("http://10.0.1.1\(rollingShutter.order)/\(rollingShutter.open == true ? "1" : "0")")
                }
                responseRepresentable = try RollingShutter.query().filter("order", rollingShutter.order).makeQuery().first()!.makeNode().converted(to: JSON.self)
        }
        return  responseRepresentable!
    }
    
    
    /**
    	Since item is of type User,
    	only instances of user will be received
     */
    func show(request: Request, item rollingShutter: RollingShutter) throws -> ResponseRepresentable {
        return try JSON(node: [rollingShutter])
    }
    
    func update(request: Request, item rollingShutter: RollingShutter) throws -> ResponseRepresentable {
        //User is JsonRepresentable
        return rollingShutter.makeJSON()
    }
    
    func destroy(request: Request, item rollingShutter: RollingShutter) throws -> ResponseRepresentable {
        //User is ResponseRepresentable by proxy of JsonRepresentable
        return rollingShutter
    }
    
    func makeResource() -> Resource<RollingShutter> {
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
    func rollingShutter() throws -> RollingShutter {
        guard let json = json else
        {
            throw Abort.badRequest
        }
        return try RollingShutter(node: json)
    }
    
}


/*
 class RollingShutterController
 {
 private var client: ClientProtocol.Type
 
 init(droplet:Droplet)
 {
 self.client = droplet.client
 
 droplet.get("rollingShutter", String.self) { request, wildcard in
 let index = wildcard.index(wildcard.startIndex, offsetBy: 0)
 let shutterNumberString =  String(wildcard[index])
 var urlString = "http://10.0.1.1\(shutterNumberString)"
 
 if wildcard.characters.count == 2
 {
 let index = wildcard.index(wildcard.startIndex, offsetBy: 1)
 urlString += "/" + String(wildcard[index])
 }
 else if wildcard.characters.count == 1
 {
 urlString += "/status";
 }
 print(wildcard)
 print(urlString)
 let clientResponse = try droplet.client.get(urlString)
 let status = clientResponse.data["status"]?.bool ?? nil
 print(status)
 let json = try JSON(node: ["status": status])
 let response = try Response(status: .ok, json: json)
 response.headers = ["Access-Control-Allow-Origin": "*", "Content-Type":"application/json"]
 return response
 }
 }
 
 
 }
 */
