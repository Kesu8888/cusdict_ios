//
//  Folder.swift
//  Customized Dictionary
//
//  Created by Fu Kaiqi on 2024/11/19.
//

import Foundation
import SQLite

struct Folder: Identifiable, Equatable {
    var id: String //folderName
    var lists: [WordList] = []
    
    /// Init from sqlTable
    init(id: String) {
        self.id = id
    }
    
    static func ==(lhs: Folder, rhs: Folder) -> Bool {
        return lhs.id == rhs.id
    }
}

struct FolderTable {
    static let name = SQLite.Expression<String>("Name")
}
