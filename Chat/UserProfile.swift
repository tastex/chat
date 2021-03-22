//
//  UserProfile.swift
//  Chat
//
//  Created by VB on 28.02.2021.
//

import Foundation
import UIKit

protocol UserProfileProtocol {
    var image: UIImage? { get set }
    var name: String? { get set }
    var bio: String? { get set }
    var nameInitials: String { get }
    var nameInitialsBackgroundColor: UIColor { get }
}

class UserProfile: UserProfileProtocol {
    let id: String
    var image: UIImage?
    var name: String?
    var bio: String?
    
    var nameInitials: String {
        if let name = name {
            let formatter = PersonNameComponentsFormatter()
            if let components = formatter.personNameComponents(from: name) {
                formatter.style = .abbreviated
                return formatter.string(from: components)
            }
        }
        return "🐶"
    }
    
    var nameInitialsBackgroundColor: UIColor {
        UIColor(red: 0.894, green: 0.908, blue: 0.17, alpha: 1)
    }
    
    var conversations: [Conversation]
    
    var onlineConversations: [Conversation] { conversations.filter { $0.online } }
    var offlineConversations: [Conversation] { conversations.filter { !$0.online } }

    init(id: String, name: String? = nil, bio: String? = nil, image: UIImage? = nil, conversations: [Conversation] = []) {
        self.id = id
        self.name = name
        self.bio = bio
        self.image = image
        self.conversations = conversations
    }
    
    static var defaultProfile: UserProfile {
        let name = "Vladimir Bolotov"
        let bio = "Tinkoff fintech student"
        let idKey = "UserID"
        if let userId = UserDefaults().string(forKey: idKey) {
            return UserProfile(id: userId, name: name, bio: bio)
        } else {
            let userId = UUID().uuidString
            UserDefaults().set(userId, forKey: idKey)
            return UserProfile(id: userId, name: name, bio: bio)
        }
    }
    
    class Conversation {
        var name: String?
        var online: Bool
        var messages: [Message]
        var hasUnreadMessages: Bool { messages.contains { $0.status == .unread } }
        
        init(name: String?, online: Bool, messages: [Message] = []) {
            self.name = name
            self.online = online
            self.messages = messages
        }
    }
    
    class Message {
        let text: String?
        let kind: MessageKind
        let status: MessageStatus
        let date: Date?
        
        init(_ text: String?, kind: MessageKind = .incoming, status: MessageStatus = .unread, date: Date?) {
            self.text = text
            self.kind = kind
            self.status = status
            self.date = date
        }
        enum MessageKind {
            case incoming
            case outgoing
        }
        
        enum MessageStatus {
            case unread
            case read
        }
    }
}
