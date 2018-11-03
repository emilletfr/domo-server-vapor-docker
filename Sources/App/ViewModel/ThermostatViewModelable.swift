//
//  ThermostatViewModel.swift
//  VaporApp
//
//  Created by Eric on 13/01/2017.
//
//

import RxSwift

enum HeatingCoolingState: Int { case OFF = 0, HEAT, COOL, AUTO }

protocol ThermostatViewModelable
{
    //MARK: Subscribers
    var currentOutdoorTemperatureObserver : PublishSubject<Double> {get}
    var currentIndoorHumidityObserver : PublishSubject<Double> {get}
    var currentIndoorTemperatureObserver : PublishSubject<Double> {get}
    var targetIndoorTemperatureObserver : PublishSubject<Double> {get}
    var currentHeatingCoolingStateObserver : PublishSubject<HeatingCoolingState> {get}
    var targetHeatingCoolingStateObserver : PublishSubject<HeatingCoolingState> {get}
    var forcingWaterHeaterObserver : PublishSubject<Int> {get}
    var boilerHeatingLevelObserver : PublishSubject<Double> {get}
    //MARK: Actions
    var targetTemperaturePublisher : PublishSubject<Double> {get}
    var targetHeatingCoolingStatePublisher : PublishSubject<HeatingCoolingState> {get}
    var forcingWaterHeaterPublisher : PublishSubject<Int> {get}
    //MARK: Dispatcher
    init(outdoorTempService:OutdoorTempServicable, indoorTempService:IndoorTempServicable, inBedService:InBedServicable, boilerService:BoilerServicable)
}
