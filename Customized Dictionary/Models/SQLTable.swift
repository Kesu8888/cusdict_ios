//
//  File.swift
//  sqlite_ios
//
//  Created by Fu Kaiqi on 2024/11/21.
//

import Foundation
@preconcurrency import SQLite

struct SQLTable {
    let table: SQLite.Table
    static let name = SQLite.Expression<String>("Name")
    static let data = SQLite.Expression<String>("Data")
}
