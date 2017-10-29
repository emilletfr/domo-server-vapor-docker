//
//  Service.swift
//  VaporApp
//
//  Created by Eric on 27/12/2016.
//
//

import HTTP
import Vapor
import Dispatch


protocol HttpClientable
{
    func sendGet(_ url:String) -> Self?
    func parseToStringFrom(path:[String]) -> String?
    func parseToDoubleFrom(path:[String]) -> Double?
    func parseToIntFrom(path:[String]) -> Int?
    func parseToJSONFrom(path:[String]) -> JSON?
}

let actionSerialQueue = DispatchQueue(label: "net.emillet.domo.HttpClient")

class HttpClient : HttpClientable
{
    
    var response : Response?
    
    func sendGet(_ url:String) -> Self?
    {
        actionSerialQueue.async {
        self.response = nil
        do {self.response = try drop.client.get(url)}
        catch {print("ERROR - \(self):\(#function) \(error) \(url)");}
         }
        return self
            
    }
    
    func parseToStringFrom(path:[String]) -> String?
    {
        guard let response = self.response?.json?[path]?.string else {print("ERROR - \(self):\(#function):\(path)");return nil}
        return response
    }
    
    func parseToDoubleFrom(path:[String]) -> Double?
    {
        guard let response = self.response?.json?[path]?.double else {print("ERROR - \(self):\(#function):\(path)");return nil}
        return response
    }
    
    func parseToIntFrom(path:[String]) -> Int?
    {
        guard let response = self.response?.json?[path]?.int else {print("ERROR - \(self):\(#function):\(path)");return nil}
        return response
    }
    
    func parseToJSONFrom(path:[String]) -> JSON?
    {
        guard let response = self.response?.json else {print("ERROR - \(self):\(#function):\(path)");return nil}
        return response
    }
}

