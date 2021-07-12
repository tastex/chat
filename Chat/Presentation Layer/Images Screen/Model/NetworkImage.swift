//
//  NetworkImage.swift
//  Chat
//
//  Created by VB on 22.04.2021.
//

import UIKit

class NetworkImage {

    var previewURL: String
    var imageURL: String
    var previewImage: UIImage?
    var image: UIImage?

    init(previewURL: String, imageURL: String) {
        self.previewURL = previewURL
        self.imageURL = imageURL
    }

    func getPreview(completion: @escaping (UIImage?) -> Void ) {

        guard let url = URL(string: previewURL) else {
            fatalError("can't construct previewURL from string")
        }
        downloadImage(with: url) { image in
            self.previewImage = image
            completion(image)
        }
    }

    func getImage(completion: @escaping (UIImage?) -> Void ) {

        guard let url = URL(string: imageURL) else {
            fatalError("can't construct imageURL from string")
        }

        downloadImage(with: url) { image in
            self.image = image
            completion(image)
        }
    }

    private func downloadImage(with url: URL, completion: @escaping (UIImage?) -> Void ) {
        DispatchQueue.global().async {
            guard let data = try? Data(contentsOf: url) else { return }
            let image = UIImage(data: data)
            completion(image)
        }
    }
}
