//
//  MessageModel.swift
//  Chat
//
//  Created by VB on 16.04.2021.
//

import Foundation

struct Message {
    let identifier: String
    let content: String
    let created: Date
    let senderId: String
    let senderName: String
}
