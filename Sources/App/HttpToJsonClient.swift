//
//  Service.swift
//  VaporApp
//
//  Created by Eric on 27/12/2016.
//
//

import Foundation

protocol HttpToJsonClientable// : Equatable
{
    var items:[String]? {get}
    func fetch(url:String, jsonPaths:String...) -> [String]?
}


class HttpToJsonClient : HttpToJsonClientable
{
    var items:[String]?
    
    func fetch(url:String, jsonPaths:String...) -> [String]? // print("\(#file)  \(#line)  \(#column)  \(#function)")
    {
        self.items = [String]()
        do
        {
            let response = try drop.client.get(url)
            for path in jsonPaths {
                guard let item = response.json?[path]?.string else
                {
                    log("ERROR - HttpToJsonClientable:guard:response: \(response)  from \(Thread.callStackSymbols)")
                    self.items = nil
                    return self.items
                }
                self.items? += [item]
            }
        }
        catch
        {
            log("ERROR - HttpToJsonClientable:catch:error: \(error)  from \(Thread.callStackSymbols)");
            self.items = nil
        }
        return self.items
    }
}

