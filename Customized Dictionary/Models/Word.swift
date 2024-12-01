//
//  Word.swift
//  Customized Dictionary
//
//  Created by Fu Kaiqi on 2024/11/19.
//

import Foundation
import SwiftUI

struct Word {
    var spell: String
    var passCount: Int64
    
    var imageNumber: Int64
    var audioName: String
    
    var type: WordType
    enum WordType: String {
        case verb = "v"
        case noun = "n"
        case adjective = "adj"
        case adverb = "adv"
        var id: String {rawValue}
    }
    var typeNumber: Int64
}


