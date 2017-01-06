//
//  DataStore.swift
//  VaporApp
//
//  Created by Eric on 13/12/2016.
//
//

import Foundation
import Vapor

class ViewModelStore {

    /*
    let dataStore : DataModelStore
    var data : DataModel {didSet{   }}
    var viewModel = ViewModel()
 */
    
    init(dataStore: DataModelStore) {
      //  self.dataStore = dataStore
     //   self.data = dataStore.data
        
    }
    
    // Reducer
    
    
    
    // Action
    
    func setTargetPosition(targetPosition:Int)
    {
        
    }
    
    func setAllTargetPosition(targetPosition:Int)
    {
        
    }
    
}

class ViewModel
{
    var rollerShuttersTargetPositions = [0,0,0,0,0]
    var isInBed = 1
    var outdoorTemperature : Double = 0.0
    var sunriseTime : String = ""
    var sunsetTime : String = ""
    var indoorHumidity : Int = 50
    var indoorTemperature : Double = 15.0
}

/*
protocol DataStoreProtocol
{
    func actionRollerShutter(index: Int, position : Int)
    var data : Data {get}

    
}


protocol DataProtocol
{
    var isInBed : Bool {get}
    var outdoorTemperature : Double {get}
    var sunriseTime : String {get}
    var sunsetTime : String {get}
    var indoorHumidity : Int {get}
    var indoorTemperature : Double {get}
}
 */


 class DataModelStore
{
   // static let shared : DataModelStore = DataModelStore()
     /*
    var data = DataModel() {didSet{print(data)/*; dataChanged?(data)*/}}

    var outdoorTempService : OutdoorTempService?
    var sunriseSunsetService : SunriseSunsetService?
    
    var rollerShutters = [RollerShutterService]()
    var indoorTempService : IndoorTempServiceable
   
    var degresDidChange = { (degres:Double) in
        print(degres)
    }
    var humidityDidChange = {(humidity:Int) in
        print(humidity)
    }
    */
 //   init(inDoorTempService:IndoorTempServiceable)
   // {
      //  self.indoorTempService = inDoorTempService
       // self.indoorTempService.degresDidChange = {print(self.indoorTempService.degres)}
/*
        outdoorTempService = OutdoorTempService(completion: { [weak self] (temp:Double?) in
            if let temp = temp {self?.data.outdoorTemperature = temp}
            })
 */
        /*
        sunriseSunsetService = SunriseSunsetService{ [weak self] (sunrise:String?, sunset:String?) in
            if let sunrise = sunrise, let sunset = sunset
            {
            self?.data.sunriseTime = sunrise
            self?.data.sunsetTime = sunset
            }
        }
 */
        
        /*
        if let temperature = temperature, let humidity = humidity
            {
                self?.data.indoorTemperature = temperature
                self?.data.indoorHumidity = humidity
            }
        })

        
        for shutterIndex in 0...4
        {
            self.rollerShutters.append(RollerShutterService(rollerShutterIndex: shutterIndex))
        }
 */
        
         /*
        self.rollerShutters[0].moveToPosition(targetPosition: 50) {
            print("50")
        }
 */

 //   }
}
/*
extension DataModelStore
{
    func actionRollerShutter(index: Int, position : Int)
    {
        
    }
}
*/
struct DataModel //: DataProtocol
{

    var isInBed = false
    var outdoorTemperature : Double = 0.0
    var sunriseTime : String = ""
    var sunsetTime : String = ""
    var indoorHumidity : Int = 50
    var indoorTemperature : Double = 15.0
    

}



class Controller {
    
    var temp = 0
    var rollerShuttersCurrentPositions = [0,0,0,0,0] {didSet{}}
    var rollerShuttersTargetPositions = [0,0,0,0,0] {didSet{}}
    
    init(view:ViewProtocol) {

        // Actions
        
        view.changeTemp { (temp) in }
        
        // Bindings
        
        view.renderTemp {  (Void) -> Int in return self.temp}

    }
    
    // Reducer
    
    func hjfjfghfjgh()
    {
        
    }
}

protocol ViewProtocol {
    
    // Actions
    
    func renderTemp(temp:@escaping  (Void) -> Int)
    
    // Bindings
    
    func changeTemp(temp:@escaping (Int) -> Void)
}

class View : ViewProtocol
{
    func renderTemp(temp:@escaping (Void) -> Int)
    {
        drop.get("thermostat/getCurrentHeatingCoolingState") { request in
            return try JSON(node: ["value": temp()])
        }
    }
    
    func changeTemp(temp:@escaping (Int) -> Void)
    {
        drop.get("thermostat/setCurrentHeatingCoolingState", Int.self) { request, value in
            temp(value)
            return try JSON(node: ["value": value])
        }
    }
}





