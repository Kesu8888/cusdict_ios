//
//  DataConnector.swift
//  Customized Dictionary
//
//  Created by Fu Kaiqi on 2024/11/21.
//

import Foundation
import SQLite
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
    
    func jpegData(compressionQuality: CGFloat) -> Data? {
        return self.jpegData(compressionQuality: compressionQuality)
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
    func insertFolderInMainFolder(f: Folder) -> Bool {
        if insertRecordInMainfolder(f: f) == false {
            return false
        }
        createFolderTableInSQL(tableName: f.folderName)
        createDir(path: "\(mainFolderDir)/\(f.folderName)", checkExist: false)
        return true
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

    func createFolderTableInSQL(tableName: String) {
        let table = Table("folder" + tableName)
        do {
            try db.run(table.create { t in
                t.column(WordListTable.name, primaryKey: true)
                t.column(WordListTable.language)
                t.column(WordListTable.start)
                t.column(WordListTable.date)
                t.column(WordListTable.passCount)
            })
        } catch {
            fatalError("Create Folder table failed")
        }
    }
    
    /// Insert a wordlist record to a Folder table and create a table corresponds in sqlite database
    /// - Steps
    ///     1. Insert the record to the folder SQL table
    ///     2. Create a Wordlist sql table
    ///     3. create a corresponding directory
    /// - Parameters
    ///     - tableName: name of the Folder to add the record
    ///     - dataName: first column "name" of the record
    ///     - data: second column "data" object of the record
    /// - Returns
    ///     - True: the record is added successfully
    ///     - False: the record may have duplicates in the database
    func insertWordlistInFolder(f: Folder, w: WordList) -> Bool {
       if insertRecordInFolder(f: f, w: w) == false {
           return false
       }
       w.createTableInSQL(db: db, folderName: f.folderName)
       createDir(path: "\(mainFolderDir)/\(f.folderName)/\(w.name)", checkExist: false)
       return true
    }
    
    private func insertRecordInFolder(f: Folder, w: WordList) -> Bool {
        let table = Table("folder\(f.folderName)")
        
        do {
            try db.run(
                table.insert(
                    WordListTable.name <- w.name,
                    WordListTable.language <- w.language.rawValue,
                    WordListTable.passCount <- w.passCount,
                    WordListTable.start <- w.start,
                    WordListTable.date <- w.date.toISO8601String()
                )
            )
        } catch {
            return false
        }
        return true
    }
    
    /// Insert a word to a wordlist
    /// - Parameters 
    ///     - tableName: name of the wordlist table to add the record
    ///     - word: word object
    /// - Returns
    ///     - True: the record is added successfully
    ///     - False: the record may have duplicates in the database
    func insertWordInWordlist(f: Folder, w: WordList, W: Word, images: [UIImage], audioFileURL: URL) -> Bool {
        W.insertWord(to: db, folderName: f.folderName, wordlistName: w.name)

        copyImagesAndAudio(wordlistDirPath: "\(dir)/mainFolder/\(f.folderName)/\(w.name)", images: images, audioFileURL: audioFileURL)
        return true
    }
    
    private func copyImagesAndAudio(wordlistDirPath: String, images: [UIImage], audioFileURL: URL) {
        let wordDir = "\(wordlistDirPath)"
        createDir(path: wordDir, checkExist: true)
        
        do {
            // Copy audio
            let audioDestinationURL = URL(fileURLWithPath: "\(wordDir)/pron.mp3")
            try FileManager.default.copyItem(at: audioFileURL, to: audioDestinationURL)
        } catch {
            fatalError("Cannot copy audio to word folder")
        }
        
        do {
            // Resize and copy images
            for (index, image) in images.enumerated() {
                if let resizedImage = image.resized(toWidth: 300), // Resize to desired width
                   let imageData = resizedImage.jpegData(compressionQuality: 0.8) { // Convert to JPEG with compression quality
                    let imageDestinationURL = URL(fileURLWithPath: "\(wordDir)/image\(index + 1).jpg")
                    try imageData.write(to: imageDestinationURL)
                }
            }
        } catch {
            fatalError("Cannot copy images to word folder")
        }
    }

    /// get all Folders in the mainFolder table with their Wordlists and return the folder Array
    /// - Returns
    ///     - True: the record is added successfully
    ///     - False: the record may have duplicates in the database
    func getFolder() -> [Folder] {
        let table = Table("mainFolder")
        var folders = [Folder]()

        do {
            for folder in try db.prepare(table) {
                let folderName = folder[FolderTable.name]
                let wordlists = getWordlist(folderName: folderName)
                folders.append(Folder(folderName: folderName, lists: wordlists))
            }
        } catch {
            fatalError("Get Folder failed")
        }
        
        return folders
    }

    
    /// get all Wordlists in a folder with their Words and return the Wordlist Array
    /// - Parameters
    ///    - folderName: the folder to get the wordlists from
    /// - Throws
    ///    - fatalError: if the get operation failed
    func getWordlist(folderName: String) -> [WordList] {
        let table = Table("folder\(folderName)")
        var wordlists = [WordList]()

        do {
            for wordlist in try db.prepare(table) {
                let name = wordlist[WordListTable.name]
                let languageString = wordlist[WordListTable.language]
                guard let language = Language(rawValue: languageString) else {
                    fatalError("Invalid language value: \(languageString)")
                }
                let start = wordlist[WordListTable.start]
                let date = Date.fromISO8601String(wordlist[WordListTable.date])
                let passCount = wordlist[WordListTable.passCount]
                wordlists.append(WordList(name: name, language: language, dir: "\(dir)/mainFolder/\(folderName)/\(name)", passCount: passCount, start: start, date: date))
            }
        } catch {
            fatalError("Get Wordlist failed")
        }
        return wordlists
    }

    
    /// get all Words in a wordlist and return an array of Words
    /// - Parameters
    ///    - w: the wordlist to get the words from
    /// - Throws
    ///    - fatalError: if the get operation failed
    /// - Returns
    ///   - an array of Words
    func getWords(folderName: String, W: WordList) -> [Any] {
        return W.getWords(db: db, folderName: folderName)
    }
    
    
    /// Edit the name of a folder in the mainFolder table
    /// - Steps
    /// 1. Update the record in the mainFolder table in database
    /// 2. Rename the folder directory
    /// - Parameters
    ///    - oldname: the name of the folder to be changed
    ///    - newName: the new name of the folder
    /// - Returns
    ///    - True: the name is changed successfully
    ///    - False: the name may have duplicates in the database
    /// - Throws
    ///   - fatalError: if the rename directory failed
    func editFolderName(oldname: String, newName: String) -> Bool {
        let table = Table("mainFolder")
        
        do {
            let folder = table.filter(FolderTable.name == oldname)
            try db.run(folder.update(FolderTable.name <- newName))
        } catch {
            return false
        }
        
        do {
            try FileManager.default.moveItem(atPath: "\(mainFolderDir)/\(oldname)", toPath: "\(mainFolderDir)/\(newName)")
        } catch {
            fatalError("Cannot rename folder directory")
        }
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
