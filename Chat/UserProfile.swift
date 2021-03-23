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

    init(id: String, name: String? = nil, bio: String? = nil, image: UIImage? = nil) {
        self.id = id
        self.name = name
        self.bio = bio
        self.image = image
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
}
