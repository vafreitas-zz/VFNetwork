//
//  RequestService.swift
//  IamChuck
//
//  Created by Victor Freitas on 17/11/19.
//  Copyright © 2019 Victor Freitas. All rights reserved.
//

import Foundation

open class RequestService<T: APIBuilder> {
    
    // MARK: Properties
    
    open var provider = RequestProvider<T>()
    
    // MARK: Initializer
    
    public init() {}
    
    /**
     Method for execute request.
     
     - Parameters:
     - route: ApiBuilder
     - responseType: Element.Type
     - Returns:
     Result<Element?, Error>, _ response: URLResponse?
     
     */
    open func execute<Element>(_ route: T,
                               responseType: Element.Type, completion: @escaping (Result<RequestStates<Element>, Error>) -> Void) where Element: Decodable & Cacheable {
        provider.request(route) { [weak self] data, response, error in
            guard let self = self else { return }
            
            do {
                try self.provider.verifyData(response, error)
                
                guard let data = data else {
                    debugPrint("Response Body is nil")
                    return
                }
                
                let model = try JSONDecoder().decode(responseType, from: data)
//                if route.cacheable {
//                    try _ = Cache<Element>().create(model)
//                }
                
                completion(.success(.load(model)))   
            } catch let error {
                completion(.failure(error))
            }
        }
        
//        do {
//            if route.cacheable {
//                if let cacheResponse = try Cache<Element>().get() {
//                    completion(.success(.cache(cacheResponse)))
//                } else {}
//            }
//        } catch {
//            debugPrint("Error in VFNetwork Cache.")
//        }
    }
    
    /**
     Method for execute a plain request without response body.
     
     - Parameters:
     - route: ApiBuilder
     - responseType: Element.Type
     - Returns:
     (_ response: URLResponse?, _ error: Error?)
     
     */
    func execute(_ route: T, completion: @escaping (Result<URLResponse?, Error>) -> Void) {
        provider.request(route) { [weak self] (data, response, error) in
            guard let self = self else { return }
            
            do {
                try self.provider.verifyData(response, error)
                completion(.success(response))
            } catch let error {
                completion(.failure(error))
            }
        }
    }
}
