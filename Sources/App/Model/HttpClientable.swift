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
   // func parseToJSONFrom(path:[String]) -> JSON?
}
