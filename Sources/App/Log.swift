//
//  Log.swift
//  VaporApp
//
//  Created by Eric on 18/10/2016.
//
//

import Foundation

func log(_ items:Any...)
{
    let dateFormatter = DateFormatter()
    dateFormatter.dateStyle = .short
    dateFormatter.timeStyle = .short
    dateFormatter.timeZone = TimeZone(abbreviation: "CEST")
    dateFormatter.locale = Locale(identifier: "fr_FR")
    Log.shared.printString(string:"\(dateFormatter.string(from: Date(timeIntervalSinceNow: 0))) : \(items)")
}

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
