//
//  NetworkServiceMock.swift
//  ChatTests
//
//  Created by VB on 06.05.2021.
//

@testable import Chat

import Foundation

 class NetworkServiceMock: NetworkServiceProtocol {

    var callsCount = 0
    var requestURLs: [URL] = []

    func sendRequest<Parser>(config: RequestConfig<Parser>, completionHandler: @escaping (Result<Parser.Model, Error>) -> Void) where Parser: ParserProtocol {
        callsCount += 1
        if let url = config.request.urlRequest?.url {
            requestURLs.append(url)
        }
    }
}