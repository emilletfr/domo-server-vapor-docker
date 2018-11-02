//
//  Service.swift
//  VaporApp
//
//  Created by Eric on 27/12/2016.
//
//

let isIpAdress: Bool = true

enum RollerShutter: Int
{
    case livingRoom = 0, diningRoom, office, kitchen, bedroom, count
    
    func baseUrl(appendPath pathComponent: String = "") -> String {
        let scheme = "http://"
        var base = ""
        switch self {
        case .livingRoom: base = isIpAdress
            ?  "10.0.1.10" : "living-room"
        case .diningRoom: base = isIpAdress
            ?  "10.0.1.11" : "dining-room"
        case .office: base = isIpAdress
            ?  "10.0.1.12" : "office"
        case .kitchen: base = isIpAdress
            ?  "10.0.1.13" : "kitchen"
        case .bedroom: base = isIpAdress
            ?  "10.0.1.14" : "bedroom"
        case .count: base = ""
        }
        return scheme + base + "/" + pathComponent
    }
}

enum Boiler: Int
{
    case heaterAndPomp = 0, temperature, count
    
    func baseUrl(appendPath pathComponent: String = "") -> String {
        let scheme = "http://"
        var base = ""
        switch self {
        case .heaterAndPomp: base = isIpAdress
            ?  "10.0.1.15:8015" : "boiler-heater-pomp"
        case .temperature: base = isIpAdress
            ?  "10.0.1.25" : "boiler-temperature"
        case .count: base = ""
        }
        return scheme + base + "/" + pathComponent
    }
}

struct InBed {
    static func baseUrl(appendPath pathComponent: String = "") -> String {
        let scheme = "http://"
        let base = isIpAdress
            ? "10.0.1.24" : "bed-occupancy"
        return scheme + base + "/" + pathComponent
    }
}

struct IndoorTemp {
    static func baseUrl(appendPath pathComponent: String = "") -> String {
        return RollerShutter.livingRoom.baseUrl(appendPath: pathComponent)
    }
}




