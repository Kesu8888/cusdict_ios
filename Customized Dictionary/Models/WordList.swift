//
//  WordList.swift
//  Customized Dictionary
//
//  Created by Fu Kaiqi on 2024/11/19.
//

import Foundation
import SwiftUI

struct WordList {
    var name: String
    let language: String
    let parentDir: String
    var logo: Image {
        let logoPath = "\(parentDir)/logo.jpg"
        if let uiImage = UIImage(contentsOfFile: logoPath) {
            return Image(uiImage: uiImage)
        } else {
            return Image(systemName: "photo")
        }
    }
    
    var start: Bool
    var date: Date
    var words: [Word]?
}
