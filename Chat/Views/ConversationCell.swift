//
//  ConversationCell.swift
//  Chat
//
//  Created by VB on 03.03.2021.
//

import UIKit

class ConversationCell: UITableViewCell {
    
    struct Model {
        let name: String?
        let message: String?
        let date: Date?
    }
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    
    func configure(with model: Model) {

        nameLabel.text = model.name ?? "Unknown chat"
        dateLabel.text = DateFormatter.stringDescribing(date: model.date)
        
        var messageLabelFont: UIFont = UIFont.systemFont(ofSize: 13)
        if let message = model.message {
            messageLabel.text = message
        } else {
            messageLabel.text = "No messages yet"
            messageLabelFont = UIFont.italicSystemFont(ofSize: 13)
        }
        messageLabel.font = messageLabelFont
    }
}

extension DateFormatter {
    static func stringDescribing(date: Date?) -> String {
        guard let date = date else { return "Sometime" }
        let formatter = DateFormatter()
        formatter.dateFormat = "dd MMM HH:mm"
        if Calendar.current.isDateInToday(date) {
            formatter.dateFormat = "HH:mm"
        }
        return formatter.string(from: date)
    }
}

extension UIColor {
    static func conversationsCellBackground(online: Bool = false) -> UIColor? {
        if online {
            return UIColor(red: 1.0, green: 1.0, blue: 0.0, alpha: 0.1)
        }
        return nil
    }
}
