//
//  TimeFormat.swift
//  Customized Dictionary
//
//  Created by Fu Kaiqi on 2024/12/30.
//

import Foundation

struct TimeFormat {
    static func formatData(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm"
        return formatter.string(from: date)
    }
}
