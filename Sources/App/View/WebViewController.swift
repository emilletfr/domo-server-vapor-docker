//
//  RollerShuttersViewController.swift
//  VaporApp
//
//  Created by Eric on 15/01/2017.
//
//

import Vapor
import RxSwift

final class WebViewController
{
    var currentState = Web()
    let rootRedirectionBlock:  (Request) -> Future<Response>
    
    init(rootRedirectionBlock: @escaping (Request) -> Future<Response>) {
        self.rootRedirectionBlock = rootRedirectionBlock
    }
    
    func index(_ req: Request) throws -> Future<View> {
        return try req.view().render("index", currentState)
    }
    
    func setActiveTabIndex(_ req: Request) throws -> Future<Response> {
        let i = try req.parameters.next(Int.self)
        self.currentState = Web(activeTabIndex: i)
        return self.rootRedirectionBlock(req)
    }
    
    struct Web: Content
    {
        private let title = "HIIIII"
        private var tabs: [Tab] = [Tab(index: 0, name: "log", activation: "active"), Tab(index: 1, name: "settings", activation: "")]
        init(activeTabIndex : Int = 0) {
            self.tabs = self.tabs.map({ tab -> Tab in
                return Tab(index: tab.index, name: tab.name, activation: tab.index == activeTabIndex ? "active" : "")
            })
        }
        
        struct Tab: Content
        {
            let index: Int
            let name: String
            let activation: String
        }
    }
    
}




