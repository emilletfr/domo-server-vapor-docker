//
//  Log.swift
//  VaporApp
//
//  Created by Eric on 18/10/2016.
//
//

import Foundation

class Log {

    // Can't init is singleton
    private init() { }
    
    //MARK: Shared Instance
    
    static let shared: Log = Log()
    
    //MARK: Local Variable
    
    var emptyStringArray : [String] = []
    
    func printString(string:String) -> Void
    {
        emptyStringArray.append(string)
        print(string)
    }
    
}
