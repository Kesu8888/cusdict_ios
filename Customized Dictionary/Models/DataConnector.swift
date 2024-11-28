//
//  DataConnector.swift
//  Customized Dictionary
//
//  Created by Fu Kaiqi on 2024/11/21.
//

import Foundation
import SQLite

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
            try db = Connection("\(dir)/db.sqlite3")
            let mainFolder = Table("mainFolder")
            
            try db.run(mainFolder.create(ifNotExists: true) { t in
                t.column(SQLTable.name, primaryKey: true)
                t.column(SQLTable.data)
            })
        } catch {
            fatalError("Create mainFOlder unsuccessfully")
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
    
    /// get full table Data from sql database and convert to array of required struct of class type
    ///  - Parameters
    ///         - tableName: data tableName in the database
    ///  - Returns: Array of required struct or class type
    func getTable<T: Codable>(tableName: String) -> [T] {
        var returnTable: [T] = [T]()
        let table = Table(tableName)
        
        do {
            for row in try db.prepare(table) {
                let jsonString = row[SQLTable.data]
                let data = jsonString.data(using: .utf8)!
                let object: T = try jsonDecoder.decode(T.self, from: data)
                returnTable.append(object)
            }
        } catch {
            fatalError(
                "getTable failed, tableName = \(tableName), error = \(error)"
            )
        }
        return returnTable
    }
    
    /// Create a new Folder Table in the database
    /// - Parameters
    ///         - tableName
    /// - Throws: fatalError if the creation fails
    func createTableFolder(tableName: String) {
        var table = Table("Folder" + tableName)
        do {
            try db.run(table.create { t in
                t.column(SQLTable.name, primaryKey: true)
                t.column(SQLTable.data)
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
    func createTableWordlist(tableName: String) {
        let table = Table("Wordlist" + tableName)
        do {
            try db.run(table.create { t in
                t.column(WordTable.spell, primaryKey: true)
                t.column(WordTable.passCount)
                t.column(WordTable.images)
                t.column(WordTable.audio)
                t.column(WordTable.type)
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
        if insertRow(tableName: "mainFolder", dataName: dataName, data: data) == false {
            return false
        }
        createTableFolder(tableName: dataName)
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
    func insertFolder(tableName: String, dataName: String, data: Codable) -> Bool {
        if insertRow(tableName: "Folder" + tableName, dataName: dataName, data: data) == false {
            return false
        }
        createTableWordlist(tableName: dataName)
        createDir(path: "\(mainFolderDir)/\(tableName)/\(dataName)", checkExist: false)
        return true
    }
    
    private func insertRow(tableName: String, dataName: String, data: Codable) -> Bool {
        let table = Table(tableName)
        
        do {
            let jsonData = try jsonEncoder.encode(data)
            let jsonString = String(data: jsonData, encoding: .utf8)!
            
            try db.run(
                table.insert(
                    SQLTable.name <- dataName,
                    SQLTable.data <- jsonString
                )
            )
        } catch {
            return false
        }
        return true
    }
    
    /// Insert a word record to a wordlist table
    /// - Parameters
    ///     - tableName: name of the wordlist table to add the record
    ///     - word: word object
    /// - Returns
    ///     - True: the record is added successfully
    ///     - False: the record may have duplicates in the database
    func insertWordlist(folderName: String, tableName: String, word: Word) -> Bool {
        let table = Table("Wordlist" + tableName)
        
        // use images.split(separator: ",") to decode
        let images = word.imageNames.joined(separator: ",")
        
        do {
            try db.run(
                table.insert(
                    WordTable.spell <- word.spell,
                    WordTable.images <- images,
                    WordTable.audio <- word.audioName,
                    WordTable.passCount <- word.passCount,
                    WordTable.type <- word.type.rawValue
                )
            )
        } catch {
            return false
        }
        
        let wordlistDir = "\(mainFolderDir)/\(folderName)/\(tableName)"
        /* Copy image files and audio file to the wordlistDir
        Add Code here
        */
        return true
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
