//
//  ProfileViewController+ButtonAnimation.swift
//  Chat
//
//  Created by VB on 29.04.2021.
//

import UIKit

extension ProfileViewController {
    func animationIsActive(from layer: CALayer) -> Bool {
        layer.animationKeys()?.count ?? 0 > 0
    }

    func stopAnimations(from layer: CALayer) {
        let move = CABasicAnimation(keyPath: #keyPath(CALayer.position))
        move.fromValue = layer.presentation()?.position
        move.toValue = layer.position

        let rotation = CABasicAnimation(keyPath: "transform.rotation")
        rotation.fromValue = layer.presentation()?.value(forKeyPath: "transform.rotation")
        rotation.toValue = NSNumber(value: 0)

        let group = CAAnimationGroup()
        group.duration = 0.3
        group.fillMode = .forwards
        group.animations = [move, rotation]
        group.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        CATransaction.begin()
        CATransaction.setCompletionBlock {
            layer.removeAllAnimations()
        }
        layer.add(group, forKey: "jiggleOff")
        CATransaction.commit()
    }

    func animateLayer(_ layer: CALayer) {
        let position = layer.position
        let offset: CGFloat = 5
        let angle: Double = 18

        let move = CAKeyframeAnimation(keyPath: #keyPath(CALayer.position))
        move.values = [position,
                       CGPoint(x: position.x - offset, y: position.y - offset),
                       CGPoint(x: position.x + offset, y: position.y + offset), position
        ]

        move.keyTimes = [0, 0.1, 0.9, 1]

        let rotation = CAKeyframeAnimation(keyPath: "transform.rotation")
        rotation.values = [NSNumber(value: 0),
                           NSNumber(value: -(angle * Double.pi / 180)),
                           NSNumber(value: angle * Double.pi / 180),
                           NSNumber(value: 0)
        ]
        rotation.keyTimes = [0, 0.1, 0.9, 1]

        let group = CAAnimationGroup()
        group.duration = 0.3
        group.repeatCount = .infinity
        group.fillMode = .forwards
        group.animations = [move, rotation]
        group.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)

        layer.add(group, forKey: "jiggle")
    }
}
