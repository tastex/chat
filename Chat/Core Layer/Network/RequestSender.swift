//
//  RequestSender.swift
//  Chat
//
//  Created by VB on 23.04.2021.
//

import Foundation

enum ParsingError: Error {
    case error
}

enum NetworkError: Error {
    case badURL
}

protocol RequestProtocol {
    var urlRequest: URLRequest? { get }

}

protocol ParserProtocol {
    associatedtype Model
    func parse(data: Data) -> Model?
}

struct RequestConfig<Parser> where Parser: ParserProtocol {
    let request: RequestProtocol
    let parser: Parser
}

protocol RequestSenderProtocol {
    func send<Parser>(config: RequestConfig<Parser>, completionHandler: @escaping (Result<Parser.Model, Error>) -> Void)
}

class RequestSender: RequestSenderProtocol {
    let session = URLSession.shared
    func send<Parser>(config: RequestConfig<Parser>, completionHandler: @escaping (Result<Parser.Model, Error>) -> Void) where Parser: ParserProtocol {
        guard let urlRequest = config.request.urlRequest else {
            completionHandler(.failure(NetworkError.badURL))
            return
        }

        let task = session.dataTask(with: urlRequest) { (data: Data?, _: URLResponse?, error: Error?) in
            if let error = error {
                completionHandler(.failure(error))
                return
            }

            guard let data = data,
                  let parsedModel: Parser.Model = config.parser.parse(data: data) else {
                completionHandler(.failure(ParsingError.error))
                return
            }
            completionHandler(.success(parsedModel))
        }
        task.resume()
    }
}
