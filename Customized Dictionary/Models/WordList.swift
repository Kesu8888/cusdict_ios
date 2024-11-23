//
//  WordList.swift
//  Customized Dictionary
//
//  Created by Fu Kaiqi on 2024/11/19.
//

import Foundation
import SwiftUI

struct WordList:Codable, Identifiable {
    var name: String
    var language: String
    var id: Int32
    
    private var logoName: String
    var logo: Image {
        Image(logoName)
    }
    
    var start: Bool
    var date: Date
}
