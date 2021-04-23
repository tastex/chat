//
//  ProfileLogoView.swift
//  Chat
//
//  Created by VB on 19.03.2021.
//

import UIKit

class ProfileLogoView: UIView {
    
    var font = UIFont.systemFont(ofSize: 20)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    func configure(profileData: UserProfileProtocol? = UserProfile.defaultProfile) {

        guard let profileData = profileData else { return }

        self.subviews.forEach { (subview) in
            subview.removeFromSuperview()
        }
        
        let profileLabelView = UILabel(frame: CGRect(origin: .zero, size: frame.size))
        profileLabelView.backgroundColor = profileData.nameInitialsBackgroundColor
        profileLabelView.text = profileData.nameInitials
        profileLabelView.textAlignment = .center
        profileLabelView.font = font
        self.addSubview(profileLabelView)
        
        let profileImageView = UIImageView(frame: CGRect(origin: .zero, size: frame.size))
        profileImageView.image = profileData.image?.copy(newSize: frame.size)
        profileImageView.contentMode = .center
        self.addSubview(profileImageView)
        if profileData.image != nil {
            profileImageView.isHidden = false
            profileLabelView.isHidden = true
        } else {
            profileImageView.isHidden = true
            profileLabelView.isHidden = false
        }
        
        self.layer.cornerRadius = frame.size.width / 2
        self.layer.masksToBounds = true
    }
    
}
