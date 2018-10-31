//
//  Service.swift
//  VaporApp
//
//  Created by Eric on 27/12/2016.
//
//

import RxSwift

protocol HttpClientable
{
    init()
    func send<T: Decodable>(url: String, responseType: T.Type) -> Observable<T>
}

