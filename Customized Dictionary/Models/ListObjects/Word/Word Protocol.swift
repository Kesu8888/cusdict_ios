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
    // Load the words as in a dictionary, fill the words to the lowest requirement
    static func WordList_GetWords(db: Connection, table: SQLite.Table, WordListDir: String, wordRange: WordRange) -> [String: [Self]]
    
    // Load the specific word to display, fill the word to the highest requirement
    static func WordList_LoadWord(db: Connection, table: SQLite.Table, WordListDir: String, W: Self) -> Self
    
    // Add a word both in the database and in the file system
    func WordList_AddWord(db: Connection, table: SQLite.Table, WordListDir: String) -> Self
    
    // Delete a word both in the database and in the file system
    func WordList_DeleteWord(db: Connection, table: SQLite.Table, WordListDir: String)
    
    // When the user edit a word in the UI Interface, sync the word in the database using this function
    func WordList_EditWord(db: Connection, table: SQLite.Table, WordListDir: String)
    
    // Add the WordList to the database, the columns are defined by each Word
    static func Folder_AddWordList(table: SQLite.Table) -> String
}
