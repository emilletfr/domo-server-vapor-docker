//
//  RollerShuttersView.swift
//  VaporApp
//
//  Created by Eric on 20/12/2016.
//
//

import Foundation

struct RollerShuttersView : RollerShuttersViewable
{
    var rollerShuttersViewModel : RollerShuttersViewModelable!
    {
        didSet {print(rollerShuttersViewModel)}
    }
    init(rollerShuttersViewModel:RollerShuttersViewModelable) {
        self.rollerShuttersViewModel = rollerShuttersViewModel

        
        self.rollerShuttersViewModel.changeTarget(shutterIndex: 1, position: 1)
    }
    
    /*
    func render(status: (Void) -> (index: Int, position: Int)) {
        print(status())
    }
    
    func renderAll(status: (Void) -> Int)
    {
        print(status())
    }
 */
    
}


protocol RollerShuttersViewable
{
    init(rollerShuttersViewModel:RollerShuttersViewModelable)
  //  func renderAll(status: (Void) -> Int)
   // func render(status: (Void) -> (index:Int, position:Int))
}

