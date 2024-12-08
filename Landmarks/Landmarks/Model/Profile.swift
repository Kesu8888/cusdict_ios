//
//  Profile.swift
//  Landmarks
//
//  Created by Fu Kaiqi on 2024/11/15.
//

import Foundation

struct Profile {
    var username: String
    var prefersNotification = true
    var seasonalPhoto = Season.winter
    var goalDate = Date()
    
    // As default is a keyword in swift just like Enum, so we need to back quote it so we can use it as name of variable
    static let `default` = Profile(username: "g_kumar")
    
    enum Season: String, CaseIterable, Codable, Identifiable {
        case spring = "🌷"
        case summer = "🌞"
        case autumn = "🍂"
        case winter = "☃️"
        
        var id: String {rawValue}
    }
}
