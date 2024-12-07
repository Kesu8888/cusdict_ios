//
//  WordList.swift
//  Customized Dictionary
//
//  Created by Fu Kaiqi on 2024/11/19.
//

import Foundation
import SwiftUI
import SQLite

class WordList {
    var name: String
    let language: Language
    let dir: String
    
    var logo: Image {
        let logoPath = "\(dir)/logo.jpg"
        if let uiImage = UIImage(contentsOfFile: logoPath) {
            return Image(uiImage: uiImage)
        } else {
            return Image(systemName: "photo")
        }
    }
    
    var passCount: Int64
    var start: Bool
    var date: Date
    
    init(name: String, language: Language, dir: String, passCount: Int64, start: Bool, date: Date) {
        self.name = name
        self.language = language
        self.dir = dir
        self.passCount = passCount
        self.start = start
        self.date = date
    }
    
    static let wordTypeMapping: [Language: any Word.Type] = [
        .english: EnglishWord.self,
        //        .chinese: ChineseWord.self // to be implemented
    ]
    
    /// Create a table in SQL database, the database columns are differed by the language variable
    /// - Parameters
    ///     - db: database connection object
    ///     - folderName: name of the folder which contains the current wordlist
    func createTableInSQL(db: Connection, folderName: String) {
        guard let wordType = WordList.wordTypeMapping[language] else {
            fatalError("Unsupported language: \(language)")
        }
        
        wordType.createTable(in: db, folderName: folderName, wordlistName: name)
    }

    func dropTableInSQL(db: Connection, folderName: String) {
        let tableName = "\(folderName)+\(name)"
        let table = Table(tableName)
        
        do {
            try db.run(table.drop(ifExists: true))
            print("Table \(tableName) deleted successfully")
        } catch {
            fatalError("Cannot delete table \(tableName): \(error)")
        }
    }
    
    func getWords(db: Connection, folderName: String) -> [Any] {
        guard let wordType = WordList.wordTypeMapping[language] else {
            fatalError("Unsupported language: \(language)")
        }
        
        return wordType.getWord(from: db, folderName: folderName, wordlistName: name)
    }
}

enum Language: String {
    case english = "English"
    case chinese = "Chinese"
}

struct WordListTable {
    static let name = SQLite.Expression<String>("Name")
    static let language = SQLite.Expression<String>("Language")
    static let start = SQLite.Expression<Bool>("Start")
    static let date = SQLite.Expression<String>("Date")
    static let passCount = SQLite.Expression<Int64>("PassCount")
}
