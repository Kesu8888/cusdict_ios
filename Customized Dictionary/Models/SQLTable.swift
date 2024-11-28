//
//  File.swift
//  sqlite_ios
//
//  Created by Fu Kaiqi on 2024/11/21.
//

import Foundation
@preconcurrency import SQLite

struct SQLTable {
    static let name = SQLite.Expression<String>("Name")
    static let data = SQLite.Expression<String>("Data")
}

// corresponding struct for WordList Table
struct WordTable {
    static let spell = SQLite.Expression<String>("Spell")
    static let passCount = SQLite.Expression<Int64>("passCount")
    static let images = SQLite.Expression<String>("Images")
    static let audio = SQLite.Expression<String>("Audios")
    static let type = SQLite.Expression<String>("WordType")
}
