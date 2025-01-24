//
//  Word.swift
//  Customized Dictionary
//
//  Created by Fu Kaiqi on 2024/11/19.
//

import Foundation
import SwiftUI
import SQLite
import SQLite3

struct EnglishWord: Word {
    let baseSpell: String
    let dir: String
    var transforms: [EnglishWordTrans]
    var targetTrans: EnglishWordTrans?
    
    static func WordList_GetWords(rows: any Sequence<SQLite.Row>, WordListDir: String) -> [EnglishWord] {
        var words = [EnglishWord]()
        var word = EnglishWord(baseSpell: "", dir: "", transforms: [])
        
        for w in rows {
            let baseSpell = w[EnglishWordTable.baseSpell]
            if baseSpell != word.baseSpell {
                if word.transforms.count > 0 {
                    words.append(word)
                }
                word = EnglishWord(baseSpell: baseSpell, dir: "\(WordListDir)/_\(baseSpell)", transforms: [])
            }
            
            let wordTrans = EnglishWordTrans(
                transform: w[EnglishWordTable.transform],
                wordtype: w[EnglishWordTable.wordtype],
                passCount: w[EnglishWordTable.passCount],
                imageNumber: w[EnglishWordTable.imageNumber],
                tags: Tag.restore(str: w[EnglishWordTable.tags])
            )
        }
        if word.transforms.count > 0 {
            words.append(word)
        }
        return words
    }
    func WordList_AddWord(db: SQLite.Connection, table: SQLite.Table, WordListDir: String) -> Bool {
        // Create word directory
        DataConnector.createDir(path: dir, dirExist: true)
        
        var addedTransforms = [EnglishWordTrans]()
        // Add Record to wordlistTable
        for w in self.transforms {
            do {
                try db.run(table.insert(
                    EnglishWordTable.baseSpell <- self.baseSpell,
                    EnglishWordTable.wordtype <- w.wordtype,
                    EnglishWordTable.transform <- w.transform,
                    EnglishWordTable.passCount <- w.passCount,
                    EnglishWordTable.imageNumber <- w.imageNumber,
                    EnglishWordTable.tags <- Tag.concatenate(tags: w.tags)
                ))
                DataConnector.P_Word_Data_Addfiles(wordDirPath: Path_Transform(trans: w), images: w.images, audioFileURL: w.audio)
                addedTransforms.append(w)
            } catch let Result.error( _, code, _) where code == SQLITE_CONSTRAINT {
                continue
            } catch {
                fatalError("WordList_AddEnglishWord fail")
            }
        }
        if addedTransforms.count == 0 {
            return false
        }
        return true
    }
    func WordList_DeleteWord(db: Connection, table: SQLite.Table) {
        // If targetTrans == nil, we should delete the entire word, else delete targetTrans
        if targetTrans == nil {
            let wordRecord = table.filter(EnglishWordTable.baseSpell == self.baseSpell)
            do {
                try db.run(wordRecord.delete())
                DataConnector.deleteDir(path: dir)
            } catch {
                fatalError("WordList_DeleteWord: \(error.localizedDescription)")
            }
        } else {
            let wordRecord = table.filter(EnglishWordTable.baseSpell == self.baseSpell && EnglishWordTable.transform == targetTrans!.transform && EnglishWordTable.wordtype == targetTrans!.wordtype)
            do {
                try db.run(wordRecord.delete())
                DataConnector.deleteDir(path: Path_Transform(trans: targetTrans!))
            } catch {
                fatalError("WordList_DeleteWord: \(error.localizedDescription)")
            }
        }
    }
    func WordList_EditWord(db: Connection, table: SQLite.Table) {
        guard targetTrans != nil else {
            fatalError("WordList_EditWord targetTrans is nil")
        }
        
        do {
            let wordRecord = table.filter(EnglishWordTable.baseSpell == self.baseSpell && EnglishWordTable.transform == targetTrans!.transform && EnglishWordTable.wordtype == targetTrans!.wordtype)
            try db.run(wordRecord.update(
                EnglishWordTable.passCount <- targetTrans!.passCount,
                EnglishWordTable.imageNumber <- targetTrans!.imageNumber,
                EnglishWordTable.tags <- Tag.concatenate(tags: targetTrans!.tags)
            ))
        } catch {
            fatalError("P_WordList_Record_EditEnglishWord: \(error.localizedDescription)")
        }
        // delete directory
        DataConnector.clearDir(path: Path_Transform(trans: targetTrans!))
        // readd all data
        DataConnector.P_Word_Data_Addfiles(wordDirPath: Path_Transform(trans: targetTrans!), images: targetTrans!.images, audioFileURL: targetTrans!.audio)
    }
    static func Folder_AddWordList(table: SQLite.Table) -> String {
        return table.create { t in
            t.column(EnglishWordTable.baseSpell)
            t.column(EnglishWordTable.transform)
            t.column(EnglishWordTable.wordtype)
            t.column(EnglishWordTable.passCount)
            t.column(EnglishWordTable.imageNumber)
            t.column(EnglishWordTable.tags)
            t.primaryKey(EnglishWordTable.baseSpell, EnglishWordTable.transform, EnglishWordTable.wordtype)
        }
    }
    private func Path_Transform(trans: EnglishWordTrans) -> String {
        return "\(dir)/_\(trans.wordtype)"
    }
}

struct EnglishWordTrans {
    var transform: String
    var wordtype: String
    var wordTypeString: String {
        return EnglishWordTrans.wordTypeStrings[wordtype] ?? "" 
    }
    var passCount: Int64
    var imageNumber: Int64
    var tags: [Tag]

    var images: [UIImage] = []
    var audio: URL? = nil
    static var wordTypeStrings = [
        "v":"verb",
        "n":"noun"
    ]
}

struct EnglishWordTable {
    static let baseSpell = SQLite.Expression<String>("baseSpell") // Primary Key
    static let wordtype = SQLite.Expression<String>("wordtype") // Primary Key
    static let transform = SQLite.Expression<String>("transform")
    
    static let passCount = SQLite.Expression<Int64>("PassCount")
    static let imageNumber = SQLite.Expression<Int64>("ImageNumber")
    static let tags = SQLite.Expression<String>("Tag") // The first tag's answer is the meaning of each word
}
