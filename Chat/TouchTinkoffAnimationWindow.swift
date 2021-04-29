//
//  TouchTinkoffAnimationWindow.swift
//  Chat
//
//  Created by VB on 29.04.2021.
//

import UIKit

let emitterAnimationLayerKey = "emitterAnimationLayerKey"

class TouchTinkoffAnimationWindow: UIWindow {
    private var touchLocation: CGPoint?
    private lazy var emitterCell: CAEmitterCell = {
        var cell = CAEmitterCell()
        cell.contents = UIImage(named: "tinkoff-logo")?.cgImage
        cell.scale = 0.5
        cell.scaleRange = 0.3
        cell.emissionRange = .pi
        cell.lifetime = 2.5
        cell.birthRate = 1
        cell.velocity = -30
        cell.velocityRange = -20
        cell.yAcceleration = -30
        cell.xAcceleration = 15
        cell.spin = -0.5
        cell.spinRange = 1.0
        return cell
    }()
}

extension TouchTinkoffAnimationWindow {
    private func removeEmitterLayer(layer: CAEmitterLayer) {
        layer.removeAllAnimations()
        layer.removeFromSuperlayer()
    }

    private func addEmitterLayer(continuous: Bool) {
        guard let touchLocation = touchLocation else { return }

        let emitterLayer = CAEmitterLayer()
        emitterLayer.emitterPosition = touchLocation
        emitterLayer.emitterShape = CAEmitterLayerEmitterShape.point
        emitterLayer.beginTime = CACurrentMediaTime()
        emitterLayer.timeOffset = CFTimeInterval(arc4random_uniform(10))
        emitterLayer.emitterCells = [emitterCell]
        layer.addSublayer(emitterLayer)

        let animation = CAKeyframeAnimation(keyPath: #keyPath(CAEmitterLayer.velocity))
        animation.duration = 0.3
        animation.values = [1, 2.5, 5]
        animation.keyTimes = [0, 0.5, 1]
        animation.fillMode = .forwards
        animation.isRemovedOnCompletion = false

        CATransaction.begin()
        CATransaction.setCompletionBlock {

            let transition = CATransition()
            transition.delegate = self
            transition.type = .fade
            transition.duration = 0.5
            transition.timingFunction = CAMediaTimingFunction(name: .easeOut)
            transition.setValue(emitterLayer, forKey: emitterAnimationLayerKey)
            transition.isRemovedOnCompletion = false
            emitterLayer.add(transition, forKey: nil)
            emitterLayer.opacity = 0
            if continuous {
                self.addEmitterLayer(continuous: continuous)
            }
        }
        emitterLayer.add(animation, forKey: UUID().uuidString)
        CATransaction.commit()
    }
}

extension TouchTinkoffAnimationWindow: CAAnimationDelegate {
    func animationDidStop(_ animation: CAAnimation, finished flag: Bool) {
        if let layer = animation.value(forKey: emitterAnimationLayerKey) as? CAEmitterLayer {
            removeEmitterLayer(layer: layer)
        }
    }
}

extension TouchTinkoffAnimationWindow {
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        guard let touch = touches.first else { return }

        touchLocation = touch.location(in: window)
        addEmitterLayer(continuous: true)
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesMoved(touches, with: event)
        guard let touch = touches.first else { return }

        touchLocation = touch.location(in: window)
        addEmitterLayer(continuous: false)
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        touchLocation = nil
    }

    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        touchLocation = nil
    }
}
