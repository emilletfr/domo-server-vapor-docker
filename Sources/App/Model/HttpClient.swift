//
//  Service.swift
//  VaporApp
//
//  Created by Eric on 27/12/2016.
//
//

import HTTP
import Vapor
import RxSwift

class HttpClient : HttpClientable
{
    required init() {}
    
    func send<T: Decodable>(url: String, responseType: T.Type) -> Observable<T> {
        return Observable<T>.create { observer in
            let client = try? app.make(Client.self)
            _ = client?.get(url).do({ r in
                // TODO: TO REMOVE
                print("-----WS-LOG----")
                print(url)
                print(r.debugDescription)
                print("-----WS-LOG----")
                // TODO: TO REMOVE
                let response: T? = try? r.content.syncDecode(T.self)
                if let response = response {
                    observer.onNext(response)
                }
            })
            return Disposables.create {}
        }
    }
}
