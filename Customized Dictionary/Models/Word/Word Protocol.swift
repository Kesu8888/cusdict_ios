//
//  Protocol.swift
//  Customized Dictionary
//
//  Created by Fu Kaiqi on 2024/12/4.
//

import Foundation
import SwiftUI
import SQLite

protocol Word {
    static func WordList_GetWords(rows: any Sequence<Row>, WordListDir: String) -> [Self]
    func WordList_AddWord(db: Connection, table: SQLite.Table, WordListDir: String) -> Bool
    func WordList_DeleteWord(db: Connection, table: SQLite.Table)
    func WordList_EditWord(db: Connection, table: SQLite.Table)
    static func Folder_AddWordList(table: SQLite.Table) -> String
//    static func WordList_DeleteWord(db: Connection, )
}
struct Tag {
    var description: String
    var answer: String
    
    private static let varSeparator: Character = "\u{1F}" // Unit Separator (ASCII code 31)
    private static let concatenateSeparator: Character = "\u{1E}" // Record Separator (ASCII code 30)
    
    func toString() -> String {
        return "\(description)\(Tag.varSeparator)\(answer)"
    }
    
    static func fromString(_ string: String) -> Tag {
        let components = string.split(separator: Tag.varSeparator)
        return Tag(description: String(components[0]), answer: String(components[1]))
    }
    
    static func concatenate(tags: [Tag]) -> String {
        return tags.map { $0.toString() }.joined(separator: String(Tag.concatenateSeparator))
    }
    
    static func restore(str: String) -> [Tag] {
        return str.split(separator: Tag.concatenateSeparator).map { Tag.fromString(String($0)) }
    }
}

struct WordTable {
    static let spell = SQLite.Expression<String>("Spell") // Primary Key
    static let type = SQLite.Expression<Int64>("TypeNumber") // Primary Key
    static let meaning = SQLite.Expression<String>("meaning")
    static let meanID = SQLite.Expression<Int64>("meanID") // Primary Key
    
    static let passCount = SQLite.Expression<Int64>("PassCount")
    static let imageNumber = SQLite.Expression<Int64>("ImageNumber")
    static let tags = SQLite.Expression<String>("Tag")
}
