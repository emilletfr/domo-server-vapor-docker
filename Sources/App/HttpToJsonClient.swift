//
//  Service.swift
//  VaporApp
//
//  Created by Eric on 27/12/2016.
//
//

import Foundation

protocol HttpToJsonClientable
{
    var items:[String]? {get}
    func internalFetch(url:String, jsonPaths:[String], fromFile: String) -> [String]?
    
}
extension HttpToJsonClientable
{
    func fetch(url:String, jsonPaths:String...,fromFile: String = #file) -> [String]?
    {
        return internalFetch(url: url, jsonPaths: jsonPaths, fromFile: fromFile)
    }
}

class HttpToJsonClient : HttpToJsonClientable
{
    var items:[String]?
    func internalFetch(url:String, jsonPaths:[String], fromFile: String) -> [String]? // print("\(#file)  \(#line)  \(#column)  \(#function)")
    {
        self.items = [String]()
        do
        {
            let response = try drop.client.get(url)
            for path in jsonPaths {
                guard let item = response.json?[path]?.string else
                {
                    log("ERROR - HttpToJsonClientable:guard:response: \(response)  from \(fromFile)")
                    self.items = nil
                    return self.items
                }
                self.items? += [item]
            }
        }
        catch
        {
            log("ERROR - HttpToJsonClientable:catch:error: \(error)  from \(fromFile)");
            self.items = nil
        }
        return self.items
    }
}

