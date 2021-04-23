//
//  RequestsFactory.swift
//  Chat
//
//  Created by VB on 23.04.2021.
//

import Foundation

struct RequestsFactory {

    struct PixabayRequests {

        fileprivate static let apiKey = "21264826-97c008bff011c0c810e3e7da3"

        static func spaceImagesConfig() -> RequestConfig<PixabayParser> {
            let request = PixabayRequest(apiKey: apiKey, query: "space")
            return RequestConfig<PixabayParser>(request: request, parser: PixabayParser())
        }
    }
}

class PixabayRequest: RequestProtocol {
    var urlRequest: URLRequest? {
        guard let url = URL(string: urlString) else {
            return nil
        }
        return URLRequest(url: url)
    }

    private let apiKey: String
    private let query: String
    private lazy var urlString: String = {
        "https://pixabay.com/api/?key=\(apiKey)&q=\(query)&image_type=photo&per_page=200"
    }()

    init(apiKey: String, query: String) {
        self.apiKey = apiKey
        self.query = query
    }
}
