//
//  WordlistBlock.swift
//  Customized Dictionary
//
//  Created by Fu Kaiqi on 2025/1/23.
//

import SwiftUI

struct WordlistBlock: View {
    var w: WordList
    let ellipseSize = 45.0
    let statusString: LanguageString
    let wordString: LanguageString
    
    var body: some View {
        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
    }
}

#Preview {
    WordlistBlock(w: WordList(
        name: "My WordList",
        language: .english,
        passCount: 3,
        start: true
    ),
    statusString: LanguageString(string: "学习中", font: CustomFont.defaultFont()) ,
    wordString: LanguageString(string: "words", font: CustomFont.defaultFont()))
}
