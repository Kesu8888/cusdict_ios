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
    
    static func fromISO8601String(_ string: String) -> Date? {
        let formatter = ISO8601DateFormatter()
        return formatter.date(from: string)
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
    ///     - dataName: first column "name" of the record
    ///     - data: second column "data" object of the record
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
    
    /// Insert a wordlist record to a Folder table and create a table corresponds in sqlite database
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
       createWordlistTableInSQL(tableName: w.name)
       createDir(path: "\(mainFolderDir)/\(f.folderName)/\(w.name)", checkExist: false)
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
    
    /// Insert a word to a wordlist
    /// - Parameters
    ///     - tableName: name of the wordlist table to add the record
    ///     - word: word object
    /// - Returns
    ///     - True: the record is added successfully
    ///     - False: the record may have duplicates in the database
    func insertWordlist(f: Folder, w: WordList, W: Word, images: [UIImage], audioFileURL: URL) -> Bool {
        if !insertRecordInWordlist(w: w, W: W) {
            return false
        }

        copyImagesAndAudio(wordlistDirPath: "\(dir)/mainFolder/\(f.folderName)/\(w.name)", images: images, audioFileURL: audioFileURL)
        return true
    }
    
    private func insertRecordInWordlist(w: WordList, W: Word) -> Bool {
        let table = Table("wordlist\(w.name)")
        
        do {
            let jsonData = try jsonEncoder.encode(W.tags)
            let jsonString = String(data: jsonData, encoding: .utf8)
            try db.run(
                table.insert(
                    WordTable.spell <- W.spell,
                    WordTable.imageNumber <- W.imageNumber,
                    WordTable.passCount <- W.passCount,
                    WordTable.type <- W.type.rawValue,
                    WordTable.typeNumber <- W.typeNumber,
                    // It means if jsonString is nil, use "" instead
                    WordTable.tag <- jsonString ?? ""
                )
            )
        } catch {
            return false
        }
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
    }

    func getWordlist(folderName: String) -> [WordList] {
        let table = Table("folder\(folderName)")
        var wordlists = [WordList]()

        do {
            for wordlist in try db.prepare(table) {
                let name = wordlist[WordListTable.name]
                let language = wordlist[WordListTable.language]
                let start = wordlist[WordListTable.start]
                let date = Date.fromISO8601String(wordlist[WordListTable.date])
                wordlists.append(WordList(name: name, language: language, start: start, date: date, words: words))
            }
        } catch {
            fatalError("Get Wordlist failed")
        }
    }

    func getWords(folderName: String, wordlistName: String) -> [Word] {
        let table = Table("wordlist\(wordlistName)")
        var words = [Word]()

        do {
            for word in try db.prepare(table) {
                let spell = word[WordTable.spell]
                let imageNumber = word[WordTable.imageNumber]
                let passCount = word[WordTable.passCount]
                let type = WordType(rawValue: word[WordTable.type])!
                let typeNumber = word[WordTable.typeNumber]
                let tag = word[WordTable.tag]
                let jsonData = tag.data(using: .utf8)
                let tags = try jsonDecoder.decode([String].self, from: jsonData)
                words.append(Word(spell: spell, imageNumber: imageNumber, passCount: passCount, type: type, typeNumber: typeNumber, tags: tags))
            }
        } catch {
            fatalError("Get Word failed")
        }
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
