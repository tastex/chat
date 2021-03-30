//
//  ObjectExtensions.swift
//  Chat
//
//  Created by VB on 29.03.2021.
//

import Foundation
import CoreData

extension ChannelDb {
    convenience init(channel: Channel, in context: NSManagedObjectContext) {
        self.init(context: context)
        self.name = channel.name
        self.identifier = channel.identifier
        self.lastMessage = channel.lastMessage
        self.lastActivity = channel.lastActivity
    }

    var about: String {
        let channel =
            """
            Channel: \(identifier ?? ""), name: \(name ?? "'channel name not set'")
            last message: \(String(describing: lastActivity)), \(lastMessage ?? "'no message yet'")\n
            """
        let messages = self.messages?.allObjects
            .compactMap { $0 as? MessageDb }
            .map { "\($0.about)" }
            .joined(separator: "\n")

        var description = channel
        if let messages = messages {
            description += "Messages:\n" + messages
        }
        return description
    }
}

extension MessageDb {
    convenience init(message: Message, in context: NSManagedObjectContext) {
        self.init(context: context)
        self.content = message.content
        self.created = message.created
        self.senderId = message.senderId
        self.senderName = message.senderName
    }

    var about: String {
        return
            """
                ---
                \(String(describing: created)), Sender: \(senderName ?? "'unknown sender name'"), id: \(senderId ?? "'sender id not set'")
                \"\(content ?? "'empty message'")\"
                ---\n
            """
    }
}
