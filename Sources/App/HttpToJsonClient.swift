//
//  Service.swift
//  VaporApp
//
//  Created by Eric on 27/12/2016.
//
//

import Foundation

protocol HttpToJsonClientable : Equatable
{
    var items:[String]? {get}
    func fetch(url:String, jsonPaths:String...) -> [String]?
   // func `init`()
    init()
}
/*
extension HttpToJsonClientable : Equatable
{
    
}
*/

func ==<T: HttpToJsonClientable>(lhs: T, rhs: T) -> Bool
{
return lhs.items! == rhs.items!
}

/*
extension HttpToJsonClientable
{

    public static func ==(lhs: Self, rhs: Self) -> Bool {
       return lhs.items! == rhs.items!
    }
}
*/


class HttpToJsonClient : HttpToJsonClientable
{



   required init() {
        
    }
 

    
    var items:[String]?
    func fetch(url:String, jsonPaths:String...) -> [String]?
    {
        self.items = [String]()
        do
        {
            let response = try drop.client.get(url)
            for path in jsonPaths {
                guard let item = response.json?[path]?.string else
                {
                    log("ERROR - Service:minuteRepeatTimerFired:guard:response: \(response)")
                    self.items = nil
                    return self.items
                }
                self.items? += [item]
            }
        }
        catch
        {
            log("ERROR - Service:minuteRepeatTimerFired:catch:error: \(error)");
            self.items = nil
        }
        return self.items
    }
}

