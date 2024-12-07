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
    
    func jpegDataWithQuality(_ compressionQuality: CGFloat) -> Data? {
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

            mainFolderDir = "\(dir)/mainFolder"
            createDir(path: mainFolderDir, checkExist: true)

            let defaultFolder = Folder(folderName: "Default")
            insertFolderInMainFolder(f: defaultFolder)
        } catch {
            fatalError("Create mainFolder unsuccessfully")
        }
    }
    
    
    /// Create an empty directory at path
    /// - Parameters
    ///     - path: The path to create a directory
    ///     - checkExist: True: check whether the directory already exist, False: assume the directory not exist
    /// - Returns
    ///     - True: The directory does not exist
    ///     - False: The directory exist
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
    ///     - f: Folder object that contains the wordlist
    ///     - w: Wordlist object that contains the word
    ///     - W: Word object
    ///     - images: Images to be added to the word folder
    ///     - audioFileURL: audio source to be added to the word folder
    /// - Returns
    ///     - True: the record is added successfully
    ///     - False: the record may have duplicates in the database
    func insertWordInWordlist(f: Folder, w: WordList, W: any Word, images: [UIImage], audioFileURL: URL) -> Bool {
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
                    let imageDestinationURL = URL(fileURLWithPath: "\(wordDir)/image\(index).jpg")
                    try imageData.write(to: imageDestinationURL)
                }
            }
        } catch {
            fatalError("Cannot copy images to word folder")
        }
    }
    
    
    /// Add Images to a word, add it to the word folder and update it in the sql record
    /// - Parameters
    ///     - f: Folder object that contains the wordlist
    ///     - w: Wordlist object that contains the word
    ///     - W: Word object
    ///     - addImages: the image objects to be added
    func addImagesToWord(f: Folder, w: WordList, W: any Word, addImages: [UIImage]) {
        var mutableW = W
        let wordDir = "\(dir)/mainFolder/\(f.folderName)/\(w.name)"
        var isDirectory: ObjCBool = false
        
        if FileManager.default.fileExists(atPath: wordDir, isDirectory: &isDirectory), isDirectory.boolValue {
            // Directory exists, proceed to add images
            do {
                // Resize and copy images
                for (index, image) in addImages.enumerated() {
                    if let resizedImage = image.resized(toWidth: 300), // Resize to desired width
                       let imageData = resizedImage.jpegDataWithQuality(0.8) { // Convert to JPEG with compression quality
                        let imageDestinationURL = URL(fileURLWithPath: "\(wordDir)/image\(W.imageNumber + Int64(index)).jpg")
                        try imageData.write(to: imageDestinationURL)
                    }
                }
                // Update imageNumber
                mutableW.imageNumber += Int64(addImages.count)
            } catch {
                fatalError("Cannot add images to word folder: \(error)")
            }
        } else {
            fatalError("Word directory does not exist")
        }
        
        mutableW.editWord(in: db, folderName: f.folderName, wordlistName: w.name)
    }
    
    
    /// Delete Images from a word, delete images with names  from the word folder and update in the sql record
    /// - Parameters
    ///     - f: Folder object that contains the wordlist
    ///     - w: Wordlist object that contains the word
    ///     - W: Word object
    ///     - removeImagesIndex: A set object that contains the index of the images to be removed
    func deleteImagesInWord(f: Folder, w: WordList, W: any Word, removeImagesIndex: Set<Int64>) {
        var mutableW = W
        let wordDir = "\(dir)/mainFolder/\(f.folderName)/\(w.name)"
        var isDirectory: ObjCBool = false
        
        if FileManager.default.fileExists(atPath: wordDir, isDirectory: &isDirectory), isDirectory.boolValue {
            // Directory exists, proceed to delete images
            do {
                var nextIndex = 0
                let fileManager = FileManager.default
                for i in 0..<W.imageNumber {
                    let imageFilePath = "\(wordDir)/image\(i).jpg"
                    if FileManager.default.fileExists(atPath: imageFilePath) {
                        if removeImagesIndex.contains(i) {
                            try fileManager.removeItem(atPath: imageFilePath)
                        } else {
                            let newImageFilePath = "\(wordDir)/image\(nextIndex).jpg"
                            try fileManager.moveItem(atPath: imageFilePath, toPath: newImageFilePath)
                            nextIndex += 1
                        }
                    }
                }
                mutableW.imageNumber = Int64(nextIndex)
            } catch {
                fatalError("Cannot delete images from word folder: \(error)")
            }
        } else {
            fatalError("Word directory does not exist")
        }
        
        W.editWord(in: db, folderName: f.folderName, wordlistName: w.name)
    }
    
    
    /// change the Audio of a word, replace the audio file in the word folder, noneed to update in the sql record
    /// - Parameters
    ///     - f: Folder object that contains the wordlist
    ///     - w: Wordlist object that contains the word
    ///     - W: Word object
    ///     - audioFileURL: audioFileURL of the new audio source
    func changeAudioInWord(f: Folder, w: WordList, W: any Word, audioFileURL: URL) {
        let wordDir = "\(dir)/mainFolder/\(f.folderName)/\(w.name)"
        var isDirectory: ObjCBool = false
        
        if FileManager.default.fileExists(atPath: wordDir, isDirectory: &isDirectory), isDirectory.boolValue {
            // Directory exists, proceed to change audio
            do {
                let audioDestinationURL = URL(fileURLWithPath: "\(wordDir)/pron.mp3")
                if FileManager.default.fileExists(atPath: audioDestinationURL.path) {
                    try FileManager.default.removeItem(at: audioDestinationURL)
                }
                try FileManager.default.copyItem(at: audioFileURL, to: audioDestinationURL)
            } catch {
                fatalError("Cannot change audio in word folder: \(error)")
            }
        } else {
            fatalError("Word directory does not exist")
        }
    }
    
    
    /// Editing other attributes of a word that does not include images and audio
    /// - Parameters
    ///     - f: Folder object that contains the wordlist
    ///     - w: Wordlist object that contains the word
    ///     - W: Word object
    func editWord(f: Folder, w: WordList, W: any Word) {
        W.editWord(in: db, folderName: f.folderName, wordlistName: w.name)
    }
    
    
    /// Delete a folder from the mainFolder
    /// - Warning: This method does not check for the number of existing wordlist in the folder, by right the user can only remove a folder when all of its wordlists have been removed
    func deleteFolder(f: Folder) {
        let folderDir = "\(dir)/mainFolder/\(f.folderName)"
        var isDirectory: ObjCBool = false
        
        if FileManager.default.fileExists(atPath: folderDir, isDirectory: &isDirectory), isDirectory.boolValue {
            // Directory exists, proceed to delete folder
            do {
                // Delete the folder and its contents from the file system
                try FileManager.default.removeItem(atPath: folderDir)
                
                // Delete the folder record from the database
                let table = Table("mainFolder")
                let folderRecord = table.filter(FolderTable.name == f.folderName)
                try db.run(folderRecord.delete())
                
                print("Folder deleted successfully")
            } catch {
                fatalError("Cannot delete folder: \(error)")
            }
        } else {
            fatalError("Folder directory does not exist")
        }
    }

    
    func deleteWordlist(f: Folder, w: WordList) {
        let wordlistDir = "\(dir)/mainFolder/\(f.folderName)/\(w.name)"
        var isDirectory: ObjCBool = false
        
        if FileManager.default.fileExists(atPath: wordlistDir, isDirectory: &isDirectory), isDirectory.boolValue {
            // Directory exists, proceed to delete wordlist
            do {
                // Delete the wordlist directory and its contents from the file system
                try FileManager.default.removeItem(atPath: wordlistDir)
                
                // Delete the wordlist record from the folder table in the database
                let table = Table("folder\(f.folderName)")
                let wordlistRecord = table.filter(WordListTable.name == w.name)
                try db.run(wordlistRecord.delete())
                
                // Drop the wordlist table
                w.dropTableInSQL(db: db, folderName: f.folderName)
                
                print("Wordlist deleted successfully")
            } catch {
                fatalError("Cannot delete wordlist: \(error)")
            }
        } else {
            fatalError("Wordlist directory does not exist")
        }
    }
    
    
    func deleteWord(f: Folder, w: WordList, W: any Word) {
        let wordDir = "\(dir)/mainFolder/\(f.folderName)/\(w.name)/\(W.spell)"
        var isDirectory: ObjCBool = false
        
        if FileManager.default.fileExists(atPath: wordDir, isDirectory: &isDirectory), isDirectory.boolValue {
            // Directory exists, proceed to delete word
            do {
                // Delete the word directory and its contents from the file system
                try FileManager.default.removeItem(atPath: wordDir)
                
                // Remove the word record from the wordlist table
                W.deleteWord(in: db, folderName: f.folderName, wordlistName: w.name)
                
                print("Word deleted successfully")
            } catch {
                fatalError("Cannot delete word: \(error)")
            }
        } else {
            fatalError("Word directory does not exist")
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
    
    deinit {
        let mainFolder = Table("mainFolder")
        
        do {
            try db.run(mainFolder.delete())
        } catch {
            fatalError("\nDelete Table unsuccessfully \(error)")
        }
    }
}
