//
//  MessageCell.swift
//  Chat
//
//  Created by VB on 03.03.2021.
//

import UIKit

class MessageCell: UITableViewCell {

    struct Model {
        let text: String?
        let senderName: String?
    }

    @IBOutlet weak var bubbleView: UIView?
    @IBOutlet weak var messageLabel: UILabel?
    @IBOutlet weak var senderNameLabel: UILabel?

    func configure(with model: Model) {

        if let text = model.text {
            messageLabel?.text = text
        } else {
            messageLabel?.text = ""
        }

        senderNameLabel?.text = model.senderName

        bubbleView?.layer.cornerRadius = 14
        if #available(iOS 13.0, *) {
            bubbleView?.layer.cornerCurve = .continuous
        }
    }

}
