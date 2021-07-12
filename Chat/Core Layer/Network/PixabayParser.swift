//
//  PixabayParser.swift
//  Chat
//
//  Created by VB on 23.04.2021.
//

import Foundation

struct PixabayResponseData: Codable {
    var imagesData: [PixabayImagesData]

    private enum CodingKeys: String, CodingKey {
        case imagesData = "hits"
    }
}

struct PixabayImagesData: Codable {
    var previewURL: String
    var imageURL: String

    private enum CodingKeys: String, CodingKey {
        case previewURL
        case imageURL = "webformatURL"
    }
}

struct PixabayParser: ParserProtocol {
        typealias Model = [PixabayImagesData]
        func parse(data: Data) -> Model? {
            do {
                let response = try JSONDecoder().decode(PixabayResponseData.self, from: data)
                return response.imagesData
            } catch {
                return nil
            }
        }
    }
