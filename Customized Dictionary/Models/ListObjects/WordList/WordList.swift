//
//  WordList.swift
//  Customized Dictionary
//
//  Created by Fu Kaiqi on 2024/11/19.
//

import Foundation
import SwiftUI
import SQLite

class WordList: Identifiable, Equatable, ObservableObject {
    var id: String
    var name: String
    let language: Language
    var logo: UIImage
    var passCount: Int64
    var start: Bool
    var date: Date
    var wordCount: Int64
    var wordRange: WordRange
    
    /// Init from Database, require full parameters
    init(id: String, name: String, language: Language, logo: UIImage, passCount: Int64, start: Bool, date: Date, wordCount: Int64, wordRange: String) {
        self.id = id
        self.name = name
        self.language = language
        self.logo = logo
        self.passCount = passCount
        self.start = start
        self.date = date
        self.wordCount = wordCount
        self.wordRange = WordRangeInit.initRange(packString: wordRange)
    }

    /// Init from Wordlist Creation, require partial parameters
    init(name: String, language: Language, passCount: Int64, start: Bool) {
        self.id = WordList.randomID(name: name)
        self.name = name
        self.language = language
        self.logo = UIImage(named: "Words") ?? UIImage()
        self.passCount = passCount
        self.start = start
        self.date = Date()
        self.wordCount = 0
        self.wordRange = EnglishAlphabetRange()
    }
    
    static func randomID(name: String) -> String {
        let randomInt = Int32.random(in: Int32.min...Int32.max)
        let hexString = String(format: "%08X", randomInt)
        return "\(name)\(hexString)"
    }
    
    static func == (lhs: WordList, rhs: WordList) -> Bool {
        return lhs.id == rhs.id
    }
}

enum Language: String {
    case english = "English"
//    case chinese = "Chinese"
}

struct WordListTable {
    static let id = SQLite.Expression<String>("ID") // Primary Key, Folder Name, Computed as name + randomHashcode
    static let name = SQLite.Expression<String>("Name")
    static let language = SQLite.Expression<String>("Language")
    static let passCount = SQLite.Expression<Int64>("PassCount")
    static let start = SQLite.Expression<Bool>("Start")
    static let date = SQLite.Expression<String>("Date")
    static let wordCount = SQLite.Expression<Int64>("WordCount")
    static let ranges = SQLite.Expression<String>("ranges")
}
