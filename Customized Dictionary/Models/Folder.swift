//
//  Folder.swift
//  Customized Dictionary
//
//  Created by Fu Kaiqi on 2024/11/19.
//

import Foundation

struct Folder: Codable {
    var folderName: String
    var lists: [WordList]?
}

