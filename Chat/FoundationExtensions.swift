//
//  FoundationExtensions.swift
//  Chat
//
//  Created by VB on 16.04.2021.
//

import Foundation

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
