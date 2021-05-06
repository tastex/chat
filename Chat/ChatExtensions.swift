//
//  ChatExtensions.swift
//  Chat
//
//  Created by VB on 08.04.2021.
//

import UIKit

public extension UIImage {
    func copy(newSize: CGSize) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(newSize, false, 0)
        self.draw(in: CGRect(origin: .zero, size: newSize))
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
}
