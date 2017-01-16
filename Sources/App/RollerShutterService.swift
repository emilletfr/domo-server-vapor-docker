//
//  RollerShutterService.swift
//  VaporApp
//
//  Created by Eric on 14/12/2016.
//
//

import Foundation
import Dispatch

enum Places: Int { case LIVING_ROOM = 0, DINING_ROOM, OFFICE, KITCHEN, BEDROOM, count }

class RollerShutterService
{
    var targetPositionCompletion : ((Void) -> Void)?
    var currentPosition : Int = 0
    var rollerShutterIndex = 0
   // var completionStatus : (((idle:Bool , currentPosition:Int)?) -> Void)
    var statusOnCompletion : ((Bool?) -> Void)?
    
    
    init(_ rollerShutterIndex : Places) {
        self.rollerShutterIndex = rollerShutterIndex.rawValue
    }
    
     func retrieveStatus(statusOnCompletion : @escaping ((Bool?) -> Void))
    {
        self.statusOnCompletion = statusOnCompletion
        do
        {
            let urlString = "http://10.0.1.1\(rollerShutterIndex)/status"
            let response = try drop.client.get(urlString)
            guard let open = response.data["open"]?.int else {statusOnCompletion(nil);log("error getting outdoor temp from ws"); return}
            return statusOnCompletion(open == 1)
        }
        catch
        {
            log("error getting outdoor temp from ws");
            statusOnCompletion(nil)
        }
    }
    
      func moveToPosition( targetPosition : Int, targetPositionCompletion:  @escaping ((Void) -> Void) )
    {
        self.targetPositionCompletion = targetPositionCompletion
        let currentPosition = self.currentPosition
      //  DispatchQueue.global(qos:.default).async(execute: @escaping DispatchWorkItem)
     //   var selfCopy = self
        DispatchQueue.global(qos:.default).async{
            do
            {
                //    let currentPos = self.rollerShuttersCurrentPositions[rollerShutterIndex]
                //   let targetPos = self.rollerShuttersTargetPositions[rollerShutterIndex]
                let open = targetPosition > currentPosition ? "1" : "0"
                let urlString = "http://10.0.1.1\(self.rollerShutterIndex)/\(open)"
                _ = try drop.client.get(urlString)
                let offset = self.currentPosition > targetPosition ? self.currentPosition - targetPosition : targetPosition - self.currentPosition
                var delay = 140000*(offset)
                if targetPosition == 0 || targetPosition == 100 {delay = 14_000_000}
                usleep(useconds_t(delay))
                _ = try drop.client.get(urlString)
                self.currentPosition = targetPosition
                sleep(2)
            }
            catch {log(error)}
            targetPositionCompletion()
 
        }
    }
}
