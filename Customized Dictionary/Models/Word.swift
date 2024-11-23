//
//  Word.swift
//  Customized Dictionary
//
//  Created by Fu Kaiqi on 2024/11/19.
//

import Foundation
import SwiftUI

struct Word: Codable {
    var spell: String
    var passCount: Int
    
    private var imageNames: [String]
    var images: [Image] {
        imageNames.map {
            Image($0)
        }
    }
    
    private var audioName: String
    
    var type: WordType
    enum WordType: String, Codable {
        case verb = "v"
        case noun = "n"
        case adjective = "adj"
        case adverb = "adv"
        var id: String {rawValue}
    }
}
