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
            _ = client?.get(url).do({ response in
                let response: T? = try? response.content.syncDecode(T.self)
                if let response = response {
                    observer.onNext(response)
                }
            })
            return Disposables.create {}
        }
    }
}
