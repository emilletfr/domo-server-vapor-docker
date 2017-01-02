//
//  RollerShuttersViewModel.swift
//  VaporApp
//
//  Created by Eric on 20/12/2016.
//
//

import Foundation

struct RollerShuttersViewModel : RollerShuttersViewModelable
{
    var rollerShuttersCurrentPositions =  [0,0,0,0,0]
    var rollerShuttersTargetPositions = [0,0,0,0,0]
    
    init() {
        
    }
    
    mutating func changeTarget(shutterIndex: Int, position: Int) {
        self.rollerShuttersTargetPositions = [1]
    }
    
    mutating func changeAllTarget(position: Int)
    {
        
    }
}


protocol RollerShuttersViewModelable
{
    var rollerShuttersCurrentPositions : [Int] {get}
    var rollerShuttersTargetPositions : [Int] {get}
    
    mutating func changeTarget(shutterIndex: Int, position: Int)
    mutating func changeAllTarget(position: Int)
}


