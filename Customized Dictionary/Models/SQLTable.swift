//
//  File.swift
//  sqlite_ios
//
//  Created by Fu Kaiqi on 2024/11/21.
//

import Foundation
@preconcurrency import SQLite

struct FolderTable {
    static let name = SQLite.Expression<String>("Name")
}

struct WordListTable {
    static let name = SQLite.Expression<String>("Name")
    static let language = SQLite.Expression<String>("Language")
    static let start = SQLite.Expression<Bool>("Start")
    static let date = SQLite.Expression<String>("Date")
}

// corresponding struct for WordList Table
struct WordTable {
    static let spell = SQLite.Expression<String>("Spell")
    static let passCount = SQLite.Expression<Int64>("PassCount")
    static let imageNumber = SQLite.Expression<Int64>("ImageNumber")
    static let type = SQLite.Expression<String>("WordType")
    static let typeNumber = SQLite.Expression<Int64>("TypeNumber")
    static let tag = SQLite.Expression<String>("Tag")
}
