//
//  DataConnector.swift
//  Customized Dictionary
//
//  Created by Fu Kaiqi on 2024/11/21.
//

import Foundation
import SQLite
import SQLite3
import SwiftUI
import UIKit


// To convert date and string and back
extension Date {
    func toISO8601String() -> String {
        let formatter = ISO8601DateFormatter()
        return formatter.string(from: self)
    }
    
    static func fromISO8601String(_ string: String) -> Date {
        let formatter = ISO8601DateFormatter()
        guard let date = formatter.date(from: string) else {
            fatalError("Invalid date string: \(string)")
        }
        return date
    }
}


// To downgrade the image
extension UIImage {
    func resized(toWidth width: CGFloat) -> UIImage? {
        let canvasSize = CGSize(width: width, height: CGFloat(ceil(width/size.width * size.height)))
        UIGraphicsBeginImageContextWithOptions(canvasSize, false, scale)
        defer { UIGraphicsEndImageContext() }
        draw(in: CGRect(origin: .zero, size: canvasSize))
        return UIGraphicsGetImageFromCurrentImageContext()
    }
    
    func jpegDataWithQuality(_ compressionQuality: CGFloat) -> Data? {
        return self.jpegData(compressionQuality: compressionQuality)
    }
}


class DataConnector {
    private var db: Connection
    let dir: String

    
    init() {
        do {
            let appDir = NSSearchPathForDirectoriesInDomains(
                .documentDirectory,
                .userDomainMask,
                true).first!
            dir = appDir
            let fileManager = FileManager.default
            // Delete the database if it exist Test Only!!!
            if fileManager.fileExists(atPath: "\(dir)/db.sqlite3") {
                try fileManager.removeItem(atPath: "\(dir)/db.sqlite3")
            }
            // Delete the mainFolder directory if it exists Test Only!!!
            if fileManager.fileExists(atPath: "\(dir)/mainFolder") {
                try fileManager.removeItem(atPath: "\(dir)/mainFolder")
            }
            
            try db = Connection("\(dir)/db.sqlite3")
            let mainFolder = Table(Name_MainFolder())
            
            try db.run(mainFolder.create(ifNotExists: false) { t in
                t.column(FolderTable.name, primaryKey: true)
            })

            let mainFolderDir = "\(dir)/mainFolder"
            DataConnector.createDir(path: mainFolderDir, dirExist: true)
        } catch {
            fatalError("Create mainFolder unsuccessfully")
        }
    }
    
    
    /// Create an empty directory at path
    /// - Parameters
    ///     - path: The path to create a directory
    ///     - dirExist: True: The directory may exist, check if yes than return. False: assume the directory not exist
    /// - Returns
    ///     - True: The directory does not exist
    ///     - False: The directory exist
    static func createDir(path: String, dirExist: Bool) {
        if dirExist {
            if FileManager.default.fileExists(atPath: path) {
                return
            }
        }
        do {
            try FileManager.default.createDirectory(atPath: path, withIntermediateDirectories: false, attributes: nil)
        } catch {
            fatalError("Create Directory fail: \(error.localizedDescription)")
        }
    }
    
    /// Delete a directory at path
    /// - Parameters
    ///     - path: The path to create a directory
    /// - Returns
    ///     - True: The directory does not exist
    ///     - False: The directory exist
    static func deleteDir(path: String) {
        do {
            try FileManager.default.removeItem(atPath: path)
        } catch {
            fatalError("Failed to delete directory: \(error)")
        }
    }
    
    /// Rename a directory at path
    /// - Parameters
    ///     - path: The path of the directory to be renamed
    ///     - newPath: The newName of the path
    static func renameDir(path: String, newPath: String) {
        do {
            try FileManager.default.moveItem(atPath: path, toPath: newPath)
        } catch {
            fatalError("Rename Directory fail: \(error.localizedDescription)")
        }
    }
    
    /// clear all files in a directory at path
    /// - Parameters
    ///     - path: The path of the directory to be cleared
    /// - Returns
    ///     - True: The directory was cleared successfully
    ///     - False: The directory could not be cleared
    static func clearDir(path: String) {
        do {
            let fileManager = FileManager.default
            let fileURLs = try fileManager.contentsOfDirectory(atPath: path)
            for fileURL in fileURLs {
                try fileManager.removeItem(atPath: "\(path)/\(fileURL)")
            }
        } catch {
            fatalError("clearDir falil")
        }
    }
    
    private func Path_MainFolder() -> String {
        return "\(dir)/mainFolder"
    }
    private func Path_Folder(f: Folder) -> String {
        return "\(dir)/mainFolder/\(f.id)"
    }
    private func Path_WordList(f: Folder, W: WordList) -> String {
        return "\(dir)/mainFolder/\(f.id)/\(W.id)"
    }
    private func Path_WordList(f: Folder, WID: String) -> String {
        return "\(dir)/mainFolder/\(f.id)/\(WID)"
    }
    
    private func Name_MainFolder() -> String {
        return "_"
    }
    private func Name_Folder(f: Folder) -> String {
        return "_\(f.id)"
    }
    private func Name_WordList(f: Folder, W: WordList) -> String {
        return "_\(f.id)_\(W.id)"
    }
    
    
    /// get all Folders in the mainFolder table with their Wordlists and return the folder Array
    /// - Returns
    ///     - True: the record is added successfully
    ///     - False: the record may have duplicates in the database
    func MainFolder_GetFolders() -> [Folder] {
        let table = Table(Name_MainFolder())
        var folders = [Folder]()

        do {
            for f in try db.prepare(table) {
                let name = f[FolderTable.name]
//                let space = f[FolderTable.space]
//                let started = f[FolderTable.started]
                var folder = Folder(id: name)
                folder.lists = Folder_GetWordLists(f: folder)
                folders.append(folder)
            }
        } catch {
            fatalError("Get Folder failed \(error.localizedDescription)")
        }
        
        return folders
    }
    
    /// Insert a folder record to the mainFolder table
    /// - Steps
    ///     1. Insert the record to the mainFolder SQL table
    ///     2. Create a folder Table in the SQL database
    ///     3. Create a folder directory in the mainFolder directory
    /// - Parameters
    ///     - f: The new folder object
    /// - Returns
    ///     - True: the record is added successfully
    ///     - False: the record may have duplicates in the database
    func MainFolder_AddFolder(f: Folder) -> Bool {
        if P_MainFolder_Record_AddFolder(f: f) == false {
            return false
        }
        P_MainFolder_Table_AddFolder(f: f)
        DataConnector.createDir(path: Path_Folder(f: f), dirExist: false)
        return true
    }

    private func P_MainFolder_Record_AddFolder(f: Folder) -> Bool {
        let table = Table(Name_MainFolder())
        
        do {
            try db.run(
                table.insert(
                    FolderTable.name <- f.id
                )
            )
        } catch let Result.error( _, code, _) where code == SQLITE_CONSTRAINT {
            return false
        } catch {
            fatalError("P_MainFolder_Record_AddFolde fail")
        }
        return true
    }
    
    private func P_MainFolder_Table_AddFolder(f: Folder) {
        let table = Table(Name_Folder(f: f))
        do {
            try db.run(table.create { t in
                t.column(WordListTable.id, primaryKey: true)
                t.column(WordListTable.name)
                t.column(WordListTable.language)
                t.column(WordListTable.passCount)
                t.column(WordListTable.start)
                t.column(WordListTable.wordCount)
                t.column(WordListTable.date)
                t.column(WordListTable.ranges)
            })
        } catch {
            fatalError("P_MainFolder_Table_AddFolder fail: \(error.localizedDescription)")
        }
    }
    
    func MainFolder_DeleteFolder(f: Folder) {
        P_MainFolder_Record_DeleteFolder(f: f)
        P_MainFolder_Table_DeleteFolder(f: f)
        DataConnector.deleteDir(path: Path_Folder(f: f))
    }
    
    private func P_MainFolder_Record_DeleteFolder(f: Folder) {
        let table = Table(Name_MainFolder())
        
        do {
            let folderRecord = table.filter(FolderTable.name == f.id)
            try db.run(folderRecord.delete())
        } catch {
            fatalError("P_MainFolder_Record_DeleteFolder fail: \(error.localizedDescription)")
        }
    }
    
    private func P_MainFolder_Table_DeleteFolder(f: Folder) {
        let table = Table(Name_Folder(f: f))
        
        do {
            try db.run(table.delete())
        } catch {
            fatalError("P_MainFolder_Table_DeleteFolder: \(error.localizedDescription)")
        }
    }
    
    
    
    /// get all WordLists in a Folder table
    func Folder_GetWordLists(f: Folder) -> [WordList] {
        let table = Table(Name_Folder(f: f))
        var WordLists = [WordList]()

        do {
            for W in try db.prepare(table) {
                let id = W[WordListTable.id]
                let wordList = WordList(
                    id: id,
                    name: W[WordListTable.name],
                    language: Language(rawValue: W[WordListTable.language]) ?? .english,
                    logo: UIImage(contentsOfFile: "\(Path_WordList(f: f, WID: id))/logo.png") ?? UIImage(),
                    passCount: W[WordListTable.passCount],
                    start: W[WordListTable.start],
                    date: Date.fromISO8601String(W[WordListTable.date]),
                    wordCount: W[WordListTable.wordCount],
                    wordRange: W[WordListTable.ranges]
                )
                WordLists.append(wordList)
            }
            return WordLists
        } catch {
            fatalError("Get Folder failed: \(error.localizedDescription)")
        }
    }
    
    /// Insert a wordlist record to a Folder table and create a table corresponds in sqlite database
    /// The function will assign new id for the WordList if the WordList'ID is duplicated for a limit of 3 times
    /// - Returns
    ///     - True: the record is added successfully
    ///     - False: the record may have too many duplicates in the database
    func Folder_AddWordList(f: Folder, W: WordList) -> Bool {
        var errorlimit = 0
        while errorlimit < 3 {
            if P_Folder_Record_AddWordList(f: f, W: W) {
                break
            }
            W.id = WordList.randomID(name: W.name)
            if errorlimit == 2 {
                fatalError("newName Record EditWordList fail")
            }
            errorlimit += 1
        }
        P_Folder_Table_AddWordList(f: f, W: W)
        DataConnector.createDir(path: Path_WordList(f: f, W: W), dirExist: false)
        P_WordList_updateLogo(W: W, path: Path_WordList(f: f, W: W))
        return true
    }
    
    private func P_WordList_updateLogo(W: WordList, path: String) {
        // Convert String to URL
        let url = URL(fileURLWithPath: "\(path)/logo.png")
        
        // Convert Image to Data
        guard let logoData = W.logo.pngData() else {
            print("Failed to convert Image to Data")
            return
        }
        
        do {
            // Write Data to logo_Path, replacing the existing file if it exists
            try logoData.write(to: url, options: .atomic)
            print("Logo updated successfully")
        } catch {
            print("Failed to update logo: \(error)")
        }
    }
    private func P_Folder_Record_AddWordList(f: Folder, W: WordList) -> Bool {
        let table = Table(Name_Folder(f: f))
        
        let insertQ = table.insert(
            WordListTable.id <- W.id,
            WordListTable.name <- W.name,
            WordListTable.language <- W.language.rawValue,
            WordListTable.passCount <- W.passCount,
            WordListTable.start <- W.start,
            WordListTable.date <- W.date.toISO8601String(),
            WordListTable.wordCount <- W.wordCount,
            WordListTable.ranges <- W.wordRange.toPackString()
        )
        do {
            try db.run(
                insertQ
            )
            return true
        } catch let Result.error(_ , code, _) where code == SQLITE_CONSTRAINT {
            return false
        } catch {
            fatalError("P_FolderRecord_AddWordList fail: \(error.localizedDescription)")
        }
    }
    
    private func P_Folder_Table_AddWordList(f: Folder, W: WordList) {
        let table = Table(Name_WordList(f: f, W: W))
        
        do {
            switch W.language {
            case .english:
                try db.run(EnglishWord.Folder_AddWordList(table: table))
                //            case .chinese:
                //                try db.run(ChineseWord.Folder_AddWordList(table: table))
                //            }
            }
        } catch {
            fatalError("P_Folder_Table_AddWordList fail: \(error.localizedDescription)")
        }
    }
    
    /// Delete the wordlist record in Folder table and the table corresponds in sqlite database
    /// - Steps
    ///     1. delete the record from the folder SQL table
    ///     2. delete the Wordlist sql table
    ///     3. delete the corresponding directory
    /// - Parameters
    ///     - tableName: name of the Folder to add the record
    ///     - dataName: first column "name" of the record
    ///     - data: second column "data" object of the record
    /// - Returns
    ///     - True: the record is added successfully
    ///     - False: the record may have duplicates in the database, the caller should change the id of the wordlist
    func Folder_DeleteWordList(f: Folder, W: WordList) {
        P_Folder_Record_DeleteWordList(f: f, W: W)
        P_Folder_Table_DeleteWordList(f: f, W: W)
        DataConnector.deleteDir(path: Path_WordList(f: f, W: W))
    }
    
    private func P_Folder_Record_DeleteWordList(f: Folder, W: WordList) {
        let table = Table(Name_Folder(f: f))
        
        do {
            let wordlistRecord = table.filter(WordListTable.id == W.id)
            try db.run(wordlistRecord.delete())
        } catch {
            fatalError("P_Folder_Record_DeleteWordList fail: \(error.localizedDescription)")
        }
    }
    
    private func P_Folder_Table_DeleteWordList(f: Folder, W: WordList) {
        let table = Table(Name_WordList(f: f, W: W))
        
        do {
            try db.run(table.drop(ifExists: true))
        } catch {
            fatalError("P_Folder_Record_DeleteWordList fail: \(error.localizedDescription)")
        }
    }
    
    func Folder_EditWordList(f: Folder, oldW: WordList, newW: WordList) {
        P_Folder_Record_EditWordList(f: f, W: newW)
        P_Folder_EditWordList_EditOldWordList(oldW: oldW, newW: newW)
        P_WordList_updateLogo(W: oldW, path: Path_WordList(f: f, W: oldW))
    }
    
    private func P_Folder_Record_EditWordList(f: Folder, W: WordList) {
        let table = Table(Name_Folder(f: f))
        
        do {
            let wordlistRecord = table.filter(WordListTable.id == W.id)
            try db.run(wordlistRecord.update(
                WordListTable.name <- W.name,
                WordListTable.language <- W.language.rawValue,
                WordListTable.passCount <- W.passCount,
                WordListTable.start <- W.start,
                WordListTable.date <- W.date.toISO8601String(),
                WordListTable.wordCount <- W.wordCount,
                WordListTable.ranges <- W.wordRange.toPackString()
            ))
        } catch {
            fatalError("P_Folder_Record_EditWordList: \(error.localizedDescription)")
        }
    }
    
    private func P_Folder_EditWordList_EditOldWordList(oldW: WordList, newW: WordList) {
        oldW.id = newW.id
        oldW.name = newW.name
        oldW.logo = newW.logo
        oldW.passCount = newW.passCount
        oldW.start = newW.start
        oldW.date = newW.date
        oldW.wordCount = newW.wordCount
        oldW.wordRange = newW.wordRange
    }
    
    /// The wordlist change involves name change. Edit the wordlist record in Folder table and the table corresponds in sqlite database, responsible for changing the WordList.id and name
    /// - Steps
    ///     check Whether the name of the WordList has been changed
    ///     true {
    ///         1. record the oldID and oldName, change the W.ID and W.Name to new value
    ///         2. edit the record
    ///         3. edit the table Name
    ///     }
    ///     false {
    ///         1. edit the record
    ///     }
    func Folder_EditWordList_changeName(f: Folder, oldW: WordList, newW: WordList) -> Bool {
        var error = 0
        while error < 4 {
            if P_Folder_Record_EditWordList_NameChange(f: f, oldW: oldW, newW: newW) {
                break
            }
            if error == 3 {
                return false
            }
            newW.id = WordList.randomID(name: newW.name)
            error += 1
        }
        
        P_Folder_Table_RenameWordList(f: f, oldW: oldW, newW: newW)
        DataConnector.renameDir(path: Path_WordList(f: f, W: oldW), newPath: Path_WordList(f: f, W: newW))
        P_Folder_EditWordList_EditOldWordList(oldW: oldW, newW: newW)
        return true
    }
    
    private func P_Folder_Record_EditWordList_NameChange(f: Folder, oldW: WordList, newW: WordList) -> Bool {
         let table = Table(Name_Folder(f: f))
        
        do {
            // Insert the new record
            try db.run(table.insert(
                WordListTable.id <- newW.id,
                WordListTable.name <- newW.name,
                WordListTable.language <- newW.language.rawValue,
                WordListTable.passCount <- newW.passCount,
                WordListTable.start <- newW.start,
                WordListTable.date <- newW.date.toISO8601String(),
                WordListTable.wordCount <- newW.wordCount,
                WordListTable.ranges <- newW.wordRange.toPackString()
            ))
            
            // Delete the old record
            let oldRecord = table.filter(WordListTable.id == oldW.id)
            try db.run(oldRecord.delete())
            return true
        } catch let Result.error( _, code, _) where code == SQLITE_CONSTRAINT {
            return false
        } catch {
            fatalError("P_Folder_Record_EditWordList_NameChange: \(error.localizedDescription)")
        }
    }
    
    private func P_Folder_Table_RenameWordList(f: Folder, oldW: WordList, newW: WordList) {
        do {
            try db.run("ALTER TABLE \(Name_WordList(f: f, W: oldW)) RENAME TO \(Name_WordList(f: f, W: newW))")
        } catch {
            fatalError("P_Folder_Table_RenameWordList: \(error.localizedDescription)")
        }
    }
    
    /// get all WordLists in a Folder table
    func WordList_GetWords(f: Folder, W: WordList) -> [String: [any Word]] {
        switch W.language {
        case .english:
            return P_WordList_GetWords(f: f, W: W, wordType: EnglishWord.self)
//        case .chinese:
//            return P_WordList_GetWords(f: f, W: W, wordType: ChineseWord.self)
        }
    }
    
    private func P_WordList_GetWords<T: Word>(f: Folder, W: WordList, wordType: T.Type) -> [String: [any Word]] {
        let table = Table(Name_WordList(f: f, W: W))
        let words = T.WordList_GetWords(db: db, table: table, WordListDir: Path_WordList(f: f, W: W), wordRange: W.wordRange)
        return words
    }
    
    func WordList_LoadWord(f: Folder, W: WordList, w: any Word) -> any Word {
        let table = Table(Name_WordList(f: f, W: W))
        switch W.language {
        case .english:
            return EnglishWord.WordList_LoadWord(db: db, table: table, WordListDir: Path_WordList(f: f, W: W), W: w as! EnglishWord)
        }
    }
    
    /// Insert a word to a wordlist
    /// - Parameters 
    ///     - f: Folder object that contains the wordlist
    ///     - w: Wordlist object that contains the word
    ///     - W: Word object
    ///     - images: Images to be added to the word folder
    ///     - audioFileURL: audio source to be added to the word folder
    /// - Returns
    ///     - True: the record is added successfully
    ///     - False: the record may have duplicates in the database
    func WordList_AddWord(f: Folder, W: WordList, w: any Word) -> any Word {
        let table = Table(Name_WordList(f: f, W: W))
        return w.WordList_AddWord(db: db, table: table, WordListDir: Path_WordList(f: f, W: W))
        
    }
    
    static func P_Word_Data_Addfiles(wordDirPath: String, images: [UIImage], audioFileURL: URL?) {
        if audioFileURL != nil {
            do {
                // Copy audio
                let audioDestinationURL = URL(fileURLWithPath: "\(wordDirPath)/pron.mp3")
                try FileManager.default.copyItem(at: audioFileURL!, to: audioDestinationURL)
            } catch {
                fatalError("Cannot copy audio to word folder: \(error.localizedDescription)")
            }
        }
        
        do {
            // Resize and copy images
            for (index, image) in images.enumerated() {
                if let resizedImage = image.resized(toWidth: 300), // Resize to desired width
                   let imageData = resizedImage.pngData() { // Convert to JPEG with compression quality
                    let imageDestinationURL = URL(fileURLWithPath: "\(wordDirPath)/image\(index).png")
                    try imageData.write(to: imageDestinationURL)
                }
            }
        } catch {
            fatalError("Cannot copy images to word folder: \(error.localizedDescription)")
        }
    }
    
    /// Delete a word in the wordlist
    /// - Parameters
    ///     - f: Folder object that contains the wordlist
    ///     - w: Wordlist object that contains the word
    ///     - W: Word object
    func WordList_DeleteWord(f: Folder, W: WordList, w: any Word) {
        let table = Table(Name_WordList(f: f, W: W))
        w.WordList_DeleteWord(db: db, table: table, WordListDir: Path_WordList(f: f, W: W))
    }
    
    /// Edit a word in the wordlist
    /// - Parameters
    ///     - f: Folder object that contains the wordlist
    ///     - w: Wordlist object that contains the word
    ///     - W: Word object
    ///     - images: Images to be added to the word folder
    ///     - audioFileURL: audio source to be added to the word folder
    /// - Returns
    ///     - True: the record is added successfully
    ///     - False: the record may have duplicates in the database
    func WordList_EditWord(f: Folder, W: WordList, w: any Word) {
        let table = Table(Name_WordList(f: f, W: W))
        w.WordList_EditWord(db: db, table: table, WordListDir: Path_WordList(f: f, W: W))
    }
}
