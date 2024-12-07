//
//  Word.swift
//  Customized Dictionary
//
//  Created by Fu Kaiqi on 2024/11/19.
//

import Foundation
import SwiftUI
import SQLite
import SQLite3

class EnglishWord: Word {
    var spell: String
    var passCount: Int64
    var imageNumber: Int64
    var type: WordType
    var typeNumber: Int64
    var tags: [Tag]
    
    enum WordType: String {
        case verb = "verb"
        case noun = "noun"
        case adjective = "adj"
        case adverb = "adv"
        
        init?(rawValue: String) {
            switch rawValue {
            case "verb": self = .verb
            case "noun": self = .noun
            case "adj": self = .adjective
            case "adv": self = .adverb
            default: fatalError("Undefined Wordtype")
            }
        }
    }
    
    init(spell: String, passCount: Int64, imageNumber: Int64, type: String, typeNumber: Int64, tags: [Tag]) {
        self.spell = spell
        self.passCount = passCount
        self.imageNumber = imageNumber
        self.type = WordType(rawValue: type) ?? .noun // Default to .noun if the type is invalid
        self.typeNumber = typeNumber
        self.tags = tags
    }
    
    static func createTable(in db: Connection, folderName: String, wordlistName: String) {
        let table = Table("\(folderName)+\(wordlistName)")
        do {
            try db.run(table.create { t in
                t.column(EnglishWordTable.spell)
                t.column(EnglishWordTable.passCount)
                t.column(EnglishWordTable.imageNumber)
                t.column(EnglishWordTable.type)
                t.column(EnglishWordTable.typeNumber)
                t.column(EnglishWordTable.tag)
                t.primaryKey(EnglishWordTable.spell, EnglishWordTable.type, EnglishWordTable.typeNumber)
            })
        } catch {
            fatalError("createTable failed")
        }
    }
    
    static func getWord(from db: Connection, folderName: String, wordlistName: String) -> [EnglishWord] {
        let table = Table("\(folderName)+\(wordlistName)")
        var words = [EnglishWord]()
        
        do {
            for word in try db.prepare(table) {
                let spell = word[EnglishWordTable.spell]
                let imageNumber = word[EnglishWordTable.imageNumber]
                let passCount = word[EnglishWordTable.passCount]
                let type = word[EnglishWordTable.type]
                let typeNumber = word[EnglishWordTable.typeNumber]
                let tag = word[EnglishWordTable.tag]
                let tags = try JSONDecoder().decode([Tag].self, from: tag.data(using: .utf8)!)
                words.append(EnglishWord(spell: spell, passCount: passCount, imageNumber: imageNumber, type: type, typeNumber: typeNumber, tags: tags))
            }
        } catch {
            fatalError("Get Word Failed")
        }
        return words
    }
    
    func insertWord(to db: Connection, folderName: String, wordlistName: String) {
        let table = Table("\(folderName)+\(wordlistName)")
        
        do {
            let jsonData = try JSONEncoder().encode(self.tags)
            let jsonString = String(data: jsonData, encoding: .utf8)
            // Insert new record
            try db.run(table.insert(
                EnglishWordTable.spell <- self.spell,
                EnglishWordTable.passCount <- self.passCount,
                EnglishWordTable.imageNumber <- self.imageNumber,
                EnglishWordTable.type <- self.type.rawValue,
                EnglishWordTable.typeNumber <- self.typeNumber,
                EnglishWordTable.tag <- jsonString ?? ""
            ))
        } catch {
            fatalError("insert word failed: \(error)")
        }
    }
    
    func editWord(in db: Connection, folderName: String, wordlistName: String) {
        let table = Table("\(folderName)+\(wordlistName)")
                
        do {
            let jsonData = try JSONEncoder().encode(self.tags)
            let jsonString = String(data: jsonData, encoding: .utf8)
            
            let record = table.filter(EnglishWordTable.spell == self.spell && EnglishWordTable.type == self.type.rawValue && EnglishWordTable.typeNumber == self.typeNumber)
            
            try db.run(record.update(
                EnglishWordTable.passCount <- self.passCount,
                EnglishWordTable.imageNumber <- self.imageNumber,
                EnglishWordTable.tag <- jsonString ?? ""
            ))
        } catch {
            fatalError("edit word failed: \(error)")
        }
    }
    
    func deleteWord(in db: Connection, folderName: String, wordlistName: String) {
        let table = Table("\(folderName)+\(wordlistName)")
        
        do {
            let record = table.filter(EnglishWordTable.spell == self.spell && EnglishWordTable.type == self.type.rawValue && EnglishWordTable.typeNumber == self.typeNumber)
            try db.run(record.delete())
            print("Word deleted successfully")
        } catch {
            fatalError("delete word failed: \(error)")
        }
    }
}

struct Tag: Codable{
    var Description: String
    var answer: String
}

// corresponding struct for WordList Table
struct EnglishWordTable {
    static let spell = SQLite.Expression<String>("Spell")
    static let passCount = SQLite.Expression<Int64>("PassCount")
    static let imageNumber = SQLite.Expression<Int64>("ImageNumber")
    static let type = SQLite.Expression<String>("WordType")
    static let typeNumber = SQLite.Expression<Int64>("TypeNumber")
    static let tag = SQLite.Expression<String>("Tag")
}
