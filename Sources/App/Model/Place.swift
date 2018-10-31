//
//  Service.swift
//  VaporApp
//
//  Created by Eric on 27/12/2016.
//
//

enum Place: Int
{
    case LIVING_ROOM = 0, DINING_ROOM, OFFICE, KITCHEN, BEDROOM, count
    
    func baseUrl() -> String {
        let scheme = "http://"
        var base = ""
        switch self {
        case .LIVING_ROOM: base = "living-room"
        case .DINING_ROOM: base = "dining-room"
        case .OFFICE: base = "office"
        case .KITCHEN: base = "kitchen"
        case .BEDROOM: base = "bedroom"
        case .count: base = ""
        }
        return scheme + base + "/"
    }
}
