//
//  Theme.swift
//  Chat
//
//  Created by VB on 11.03.2021.
//

import UIKit

protocol ThemesPickerDelegate: AnyObject {
    func didSelectTheme(_ theme: Theme)
    func updateAppearance(viewController: UIViewController)
}

class ThemeController: ThemesPickerDelegate {

    var theme = Theme.current

    func didSelectTheme(_ theme: Theme) {
        self.theme = theme
    }

    func updateAppearance(viewController: UIViewController) {
        if let viewController = viewController as? ThemesViewController {
            viewController.view.layer.backgroundColor = self.theme.settingsBackgroundColor.cgColor
        } else {
            viewController.view.layer.backgroundColor = theme.backgroundColor.cgColor
        }
        updateSubviews(viewController.view.subviews)
    }

    func updateSubviews(_ subviews: [UIView]) {
        for view in subviews {
            if let view = view as? UILabel {
                view.textColor = theme.textColor
            }
            updateSubviews(view.subviews)
        }
    }
}

enum Theme: Int, CaseIterable {
    case classic, day, night

    static var current = Theme.classic

    var title: String {
        switch self {
        case .classic:
            return "Classic"
        case .day:
            return "Day"
        case .night:
            return "Night"
        }
    }

    var settingsBackgroundColor: UIColor {
        switch self {
        case .classic:
            return UIColor(red: 0.848, green: 0.933, blue: 0.892, alpha: 1)
        case .day:
            return UIColor(red: 0.743, green: 0.837, blue: 0.979, alpha: 1)
        case .night:
            return .black
        }
    }

    var textColor: UIColor {
        switch self {
        case .classic, .day:
            return .black
        case .night:
            return .white
        }
    }

    var backgroundColor: UIColor {
        switch self {
        case .classic, .day:
            return .white
        case .night:
            return UIColor(red: 0.024, green: 0.024, blue: 0.024, alpha: 1)
        }
    }

    var incomingMessageColor: UIColor {
        switch self {
        case .classic:
            return UIColor(red: 0.875, green: 0.875, blue: 0.875, alpha: 1)
        case .day:
            return UIColor(red: 0.918, green: 0.922, blue: 0.929, alpha: 1)
        case .night:
            return UIColor(red: 0.18, green: 0.18, blue: 0.18, alpha: 1)
        }
    }

    var outgoingMessageColor: UIColor {
        switch self {
        case .classic:
            return UIColor(red: 0.863, green: 0.969, blue: 0.773, alpha: 1)
        case .day:
            return UIColor(red: 0.263, green: 0.537, blue: 0.976, alpha: 1)
        case .night:
            return UIColor(red: 0.361, green: 0.361, blue: 0.361, alpha: 1)
        }
    }
}
