//
//  Protocol.swift
//  Customized Dictionary
//
//  Created by Fu Kaiqi on 2024/12/4.
//

import Foundation
import SQLite

protocol Word {
    associatedtype WordLanguage: Word
    
    var spell: String { get set }
    var passCount: Int64 { get set }
    var imageNumber: Int64 { get set }
    
    static func createTable(in db: Connection, folderName: String, wordlistName: String)
    static func getWord(from db: Connection, folderName: String, wordlistName: String) -> [WordLanguage]
    func insertWord(to db: Connection, folderName: String, wordlistName: String)
    func editWord(in db: Connection, folderName: String, wordlistName: String)
    func deleteWord(in db: Connection, folderName: String, wordlistName: String)
}
