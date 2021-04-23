//
//  NetworkService.swift
//  Chat
//
//  Created by VB on 23.04.2021.
//

import Foundation

protocol NetworkServiceProtocol {
    func sendRequest<Parser>(config: RequestConfig<Parser>, completionHandler: @escaping (Result<Parser.Model, Error>) -> Void)
}

class NetworkService: NetworkServiceProtocol {

    private let requestSender = RequestSender()

    func sendRequest<Parser>(config: RequestConfig<Parser>, completionHandler: @escaping (Result<Parser.Model, Error>) -> Void) where Parser: ParserProtocol {
        requestSender.send(config: config) { result in
            switch result {
            case .success(let model):
                completionHandler(.success(model))
            case .failure(let error):
                print(error)
                completionHandler(.failure(error))
            }
        }
    }

}
