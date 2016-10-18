//
//  Loggable.swift
//  VaporApp
//
//  Created by Eric on 18/10/2016.
//
//

import Foundation

class Loggable
{
    
    init() {
        
    }
    
    func log(_ items:Any...)
    {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .short
        dateFormatter.timeStyle = .short
        Log.shared.printString(string:"\(dateFormatter.string(from: Date(timeIntervalSinceNow: 0))) : \(items)")
    }
    
}