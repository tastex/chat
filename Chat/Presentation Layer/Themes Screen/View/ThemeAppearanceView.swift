//
//  ThemeAppearanceView.swift
//  Chat
//
//  Created by VB on 10.03.2021.
//

import UIKit

class ThemeAppearanceView: UIView, SelectableView {

    @IBOutlet weak var backgroundView: UIView!
    @IBOutlet weak var incomingBubble: UIView!
    @IBOutlet weak var outgoingBubble: UIView!
    @IBOutlet weak var themeTitleLabel: UILabel!

    required init?(coder: NSCoder) {
        super .init(coder: coder)
    }

    func configure(theme: Theme, frame: CGRect) {

        self.frame = frame

        themeTitleLabel.text = theme.title
        themeTitleLabel.textColor = Theme.current.textColor
        backgroundView.layer.borderWidth = 2
        backgroundView.layer.borderColor = .borderColor

        backgroundView.backgroundColor = theme.backgroundColor
        incomingBubble.backgroundColor = theme.incomingMessageColor
        outgoingBubble.backgroundColor = theme.outgoingMessageColor

        backgroundView.layer.cornerRadius = 14
        incomingBubble.layer.cornerRadius = 7
        outgoingBubble.layer.cornerRadius = 7
        if #available(iOS 13.0, *) {
            backgroundView.layer.cornerCurve = .continuous
            incomingBubble.layer.cornerCurve = .continuous
            outgoingBubble.layer.cornerCurve = .continuous
        }
    }

    func select() {
        backgroundView.layer.borderColor = .borderColorSelected
    }

    func unselect() {
        backgroundView.layer.borderColor = .borderColor
    }

}

fileprivate extension CGColor {
    static var borderColor = UIColor(red: 0.592, green: 0.592, blue: 0.592, alpha: 1).cgColor
    static var borderColorSelected = UIColor(red: 0, green: 0.478, blue: 1, alpha: 1).cgColor
}

protocol SelectableView: UIView {
    func select()
    func unselect()
}
