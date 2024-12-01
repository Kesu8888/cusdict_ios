//
//  DataConnector.swift
//  Customized Dictionary
//
//  Created by Fu Kaiqi on 2024/11/21.
//

import Foundation
import SQLite

extension Date {
    func toISO8601String() -> String {
        let formatter = ISO8601DateFormatter()
        return formatter.string(from: self)
    }
    
    static func fromISO8601String(_ string: String) -> Date? {
        let formatter = ISO8601DateFormatter()
        return formatter.date(from: string)
    }
}

class DataConnector {
    private var db: Connection
    private var jsonEncoder = JSONEncoder()
    private var jsonDecoder = JSONDecoder()
    private let dir = NSSearchPathForDirectoriesInDomains(
        .documentDirectory,
        .userDomainMask,
        true
    ).first!
    private let mainFolderDir: String
    
    init() {
        do {
            try FileManager.default.removeItem(atPath: "\(dir)/db.sqlite3")
            
            try db = Connection("\(dir)/db.sqlite3")
            let mainFolder = Table("mainFolder")
            
            try db.run(mainFolder.create(ifNotExists: true) { t in
                t.column(FolderTable.name, primaryKey: true)
            })
        } catch {
            fatalError("Create mainFolder unsuccessfully")
        }
        
        mainFolderDir = "\(dir)/mainFolder"
        createDir(path: mainFolderDir, checkExist: true)
    }
    
    func createDir(path: String, checkExist: Bool) {
        if !FileManager.default.fileExists(atPath: path) {
            do {
                try FileManager.default.createDirectory(atPath: path, withIntermediateDirectories: true, attributes: nil)
            } catch {
                fatalError("Create mainFolder failed, error: \(error)")
            }
        } else {
            if checkExist == false {
                fatalError("create folder already exist")
            }
        }
    }
    
    /// Create a new Folder Table in the database
    /// - Parameters
    ///         - tableName
    /// - Throws: fatalError if the creation fails
    func createFolderTableInSQL(tableName: String) {
        let table = Table("Folder" + tableName)
        do {
            try db.run(table.create { t in
                t.column(WordListTable.name, primaryKey: true)
                t.column(WordListTable.language)
                t.column(WordListTable.start)
                t.column(WordListTable.date)
            })
        } catch {
            fatalError("Create Folder table failed")
        }
    }
    
    /// Create a new Wordlist Table in the database
    /// - Parameters
    ///         - tableName
    /// - Returns
    ///         - True: If the table is created successfully
    ///         - False: if the table name has duplicate in the sql
    func createWordlistTableInSQL(tableName: String) {
        let table = Table("Wordlist" + tableName)
        do {
            try db.run(table.create { t in
                t.column(WordTable.spell, primaryKey: true)
                t.column(WordTable.passCount)
                t.column(WordTable.imageNumber)
                t.column(WordTable.type)
                t.column(WordTable.typeNumber)
            })
        } catch {
            fatalError("Create Wordlist table failed")
        }
    }
    
    /// Insert a folder record  to the mainFolder table
    /// - Parameters
    ///     - dataName: first column "name" of the record
    ///     - data: second column "data" object of the record
    /// - Returns
    ///     - True: the record is added successfully
    ///     - False: the record may have duplicates in the database
    func insertMainFolder(dataName: String, data: Codable) -> Bool {
//        if insertRow(tableName: "mainFolder", dataName: dataName, data: data) == false {
//            return false
//        }
        createFolderTableInSQL(tableName: dataName)
        createDir(path: "\(mainFolderDir)/\(dataName)", checkExist: false)
        return true
    }
    
    /// Insert a wordlist record to a Folder table and create a table corresponds in sqlite database
    /// - Parameters
    ///     - tableName: name of the Folder to add the record
    ///     - dataName: first column "name" of the record
    ///     - data: second column "data" object of the record
    /// - Returns
    ///     - True: the record is added successfully
    ///     - False: the record may have duplicates in the database
    func insertFolder(tableName: String, wordlist: WordList) -> Bool {
//        if insertRow(tableName: "Folder" + wordlist.name) == false {
//            return false
//        }
//        createWordlistTableInSQL(tableName: dataName)
//        createDir(path: "\(mainFolderDir)/\(tableName)/\(dataName)", checkExist: false)
//        return true
    }
    
    private func insertRecordInMainfolder(f: Folder) -> Bool {
        let table = Table("mainFolder")
        
        do {
            try db.run(
                table.insert(
                    FolderTable.name <- f.folderName
                )
            )
        } catch {
            return false
        }
        return true
    }
    

    
    private func insertRecordInFolder(f: Folder, w: WordList) -> Bool {
        let table = Table("folder\(f.folderName)")
        
        do {
            try db.run(
                table.insert(
                    WordListTable.name <- w.name,
                    WordListTable.language <- w.language,
                    WordListTable.start <- w.start,
                    WordListTable.date <- w.date.toISO8601String()
                )
            )
        } catch {
            return false
        }
        return true
    }
    
    private func insertRecordInWordlist(w: WordList, W: Word) -> Bool {
        let table = Table("wordlist\(w.name)")
        
        do {
            try db.run(
                table.insert(
                    WordTable.spell <- W.spell,
                    WordTable.imageNumber <- W.imageNumber,
                    WordTable.passCount <- W.passCount,
                    WordTable.type <- W.type.rawValue,
                    WordTable.typeNumber <- W.typeNumber
                )
            )
        } catch {
            return false
        }
        return true
    }
    
    /// Insert a word record to a wordlist
    /// - Parameters
    ///     - tableName: name of the wordlist table to add the record
    ///     - word: word object
    /// - Returns
    ///     - True: the record is added successfully
    ///     - False: the record may have duplicates in the database
    func insertWordlist(f: Folder, w: WordList, W: Word) -> Bool {
        insertRecordInWordlist(w: w, W: W)
    }
    
    /// Delete a folder from the main Folder table, remove the entire directory related to the folder
    /// - Parameters
    ///     - folderName: name of the folder to be deleted from the mainFolder table
    func deleteFolder(folderName: String) {
        
    }
    
    /// Delete a wordlist from a folder, remove the entire directory related to the wordlist
    /// - Parameters
    ///     - folderName: the folder to delete the wordlist from
    ///     - wordlistName: the wordlist Name directory to delete
    func deleteWordlist(folderName: String, wordlistName: String) {
        
    }
    
    /// Delete a word from a wordlist, remove the image and audio files in the related wordlist directory
    /// - Parameters
    ///     - folderName: the folder which contains the wordlist
    ///     - wordlistName: the wordlist Name directory to delete
    ///     - word:
    func deleteWord(folderName: String, wordlistName: String, word: Word) {
        
    }
    
    deinit {
        let mainFolder = Table("mainFolder")
        
        do {
            try db.run(mainFolder.delete())
        } catch {
            fatalError("\nDelete Table unsuccessfully \(error)")
        }
    }
}
