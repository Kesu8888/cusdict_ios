//
//  WordList.swift
//  Customized Dictionary
//
//  Created by Fu Kaiqi on 2024/11/19.
//

import Foundation
import SwiftUI
import SQLite

class WordList: Identifiable {
    var id: String
    var name: String
    let language: Language
    var dir: String
    
    var logo: Image {
        if dir == "none" {
            return Image("Words")
        } else {
            let logoPath = "\(dir)/logo.jpg"
            return Image(logoPath)
        }
    }
    
    var passCount: Int64
    var start: Bool
    var date: Date
    var wordCount: Int64
    
    /// Init from Database, require full parameters
    init(id: String, name: String, language: Language, dir: String, passCount: Int64, start: Bool, date: Date, wordCount: Int64) {
        self.id = id
        self.name = name
        self.language = language
        self.dir = dir
        self.passCount = passCount
        self.start = start
        self.date = date
        self.wordCount = wordCount
    }

    /// Init from Wordlist Creation, require partial parameters
    init(name: String, language: Language, passCount: Int64, start: Bool) {
        self.id = WordList.randomID(name: name)
        self.name = name
        self.language = language
        self.dir = "none"
        self.passCount = passCount
        self.start = start
        self.date = Date()
        self.wordCount = 0
    }
    
    static func randomID(name: String) -> String {
        let randomInt = Int32.random(in: Int32.min...Int32.max)
        let hexString = String(format: "%08X", randomInt)
        return "\(name)\(hexString)"
    }
}

extension WordList {
    func createTable(in db: Connection, folderName: String) {
        let table = Table("\(folderName)+\(self.id)")
        do {
            try db.run(table.create { t in
                t.column(WordTable.spell)
                t.column(WordTable.type)
                t.column(WordTable.meaning)
                t.column(WordTable.meanID)
                t.column(WordTable.passCount)
                t.column(WordTable.imageNumber)
                t.column(WordTable.tags)
                t.primaryKey(WordTable.meanID, WordTable.type, WordTable.meaning)
            })
        } catch {
            fatalError("createTable failed")
        }
    }
}

enum Language: String {
    case english = "English"
    case chinese = "Chinese"
}

struct WordListTable {
    static let id = SQLite.Expression<String>("ID") // Primary Key, Folder Name, Computed as name + randomHashcode
    static let name = SQLite.Expression<String>("Name")
    static let language = SQLite.Expression<String>("Language")
    static let passCount = SQLite.Expression<Int64>("PassCount")
    static let start = SQLite.Expression<Bool>("Start")
    static let date = SQLite.Expression<String>("Date")
    static let wordCount = SQLite.Expression<Int64>("WordCount")
}
