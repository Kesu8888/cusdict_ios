//
//  Folder.swift
//  Customized Dictionary
//
//  Created by Fu Kaiqi on 2024/11/19.
//

import Foundation
import SQLite

struct Folder {
    var folderName: String
    var lists: [WordList]?
}

struct FolderTable {
    static let name = SQLite.Expression<String>("Name")
}
