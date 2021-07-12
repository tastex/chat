//
//  Images.swift
//  Chat
//
//  Created by VB on 22.04.2021.
//

import Foundation

class Images {

    private var images = [NetworkImage]()

    func imagesCount() -> Int {
        images.count
    }

    func image(at index: Int) -> NetworkImage {
        images[index]
    }

    var networkService: NetworkServiceProtocol

    init(networkService: NetworkServiceProtocol) {
        self.networkService = networkService
    }

    func getImages(completion: @escaping ([NetworkImage]) -> Void) {

        networkService.sendRequest(config: RequestsFactory.PixabayRequests.spaceImagesConfig()) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let imagesData):
                imagesData.forEach { (imageData) in
                    self.images.append(NetworkImage(previewURL: imageData.previewURL, imageURL: imageData.imageURL))
                }
                completion(self.images)
            case .failure(let error):
                print(error.localizedDescription)
                completion(self.images)
            }
        }
    }
}
