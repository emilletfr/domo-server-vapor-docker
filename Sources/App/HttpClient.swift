//
//  Service.swift
//  VaporApp
//
//  Created by Eric on 27/12/2016.
//
//

import HTTP
import Vapor


protocol HttpClientable
{
    func sendGet(_ url:String) -> Self?
    func parseToStringFrom(path:[String]) -> String?
    func parseToDoubleFrom(path:[String]) -> Double?
    func parseToIntFrom(path:[String]) -> Int?
}


class HttpClient : HttpClientable
{
    var response : Response?
    
    func sendGet(_ url:String) -> Self? // print("\(#file)  \(#line)  \(#column)  \(#function)")
    {
        self.response = nil
        do {self.response = try drop.client.get(url)}
        catch {log("ERROR - \(self):\(#function) \(error) \(url)");}
        return self
    }
    
    func parseToStringFrom(path:[String]) -> String?
    {
        guard let response = self.response?.json?[path]?.string else {log("ERROR - \(self):\(#function):\(path)");return nil}
        return response
    }
    
    func parseToDoubleFrom(path:[String]) -> Double?
    {
        guard let response = self.response?.json?[path]?.double else {log("ERROR - \(self):\(#function):\(path)");return nil}
        return response
    }
    
    func parseToIntFrom(path:[String]) -> Int?
    {
        guard let response = self.response?.json?[path]?.int else {log("ERROR - \(self):\(#function):\(path)");return nil}
        return response
    }
}

