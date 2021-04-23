//
//  UIKitExtensions.swift
//  Chat
//
//  Created by VB on 08.04.2021.
//

import UIKit

extension UIImage {
    func copy(newSize targetSize: CGSize) -> UIImage? {

        let widthRatio  = targetSize.width / size.width
        let heightRatio = targetSize.height / size.height

        var newSize: CGSize
        if widthRatio > heightRatio {
            newSize = CGSize(width: targetSize.width, height: targetSize.height * size.height / size.width)
        } else {
            newSize = CGSize(width: targetSize.width * size.width / size.height, height: targetSize.height)
        }

        UIGraphicsBeginImageContextWithOptions(newSize, false, 0)
        self.draw(in: CGRect(origin: .zero, size: newSize))
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
}

extension UIAlertController {
    func pruneNegativeWidthConstraints() {
        for subView in self.view.subviews {
            for constraint in subView.constraints where constraint.debugDescription.contains("width == - 16") {
                subView.removeConstraint(constraint)
            }
        }
    }
}
