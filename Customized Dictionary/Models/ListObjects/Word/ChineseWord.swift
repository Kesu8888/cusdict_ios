//
//  ChineseWord.swift
//  Customized Dictionary
//
//  Created by Fu Kaiqi on 2025/1/7.
//

//import Foundation
//import SwiftUI
//import SQLite
//import SQLite3
//
//struct ChineseWord: Word {
//    var spell: String
//    var type: Int
//    var wordTypeString: String {
//        return ChineseWord.wordType[type]
//    }
//
//    var passCount: Int64
//    var imageNumber: Int64
//    var tags: [Tag]
//    var dir: String = ""
//
//    var images: [UIImage] = []
//    var audio: URL? = nil
//    static var wordType: [String] = ["名词", "动词", "形容词", "副词", "代词", "介词", "连词", "数词", "量词", "助词", "感叹词", "拟声词"]
//    
//    static func WordList_GetWords(rows: any Sequence<SQLite.Row>, WordListDir: String) -> [ChineseWord] {
//        var words = [ChineseWord]()
//        for w in rows {
//            let word = ChineseWord(
//                spell: w[ChineseWordTable.spell],
//                type: Int(w[ChineseWordTable.type]),
//                passCount: w[ChineseWordTable.passCount],
//                imageNumber: w[ChineseWordTable.imageNumber],
//                tags: Tag.restore(str: w[ChineseWordTable.tags]),
//                dir: "\(WordListDir)/_\(w[ChineseWordTable.spell])"
//            )
//            words.append(word)
//        }
//        return words
//    }
//    func WordList_AddWord(db: SQLite.Connection, table: SQLite.Table, WordListDir: String) -> Bool {
//        // Add record to wordlisttable
//        do {
//            try db.run(table.insert(
//                ChineseWordTable.spell <- self.spell,
//                ChineseWordTable.type <- Int64(self.type),
//                ChineseWordTable.passCount <- self.passCount,
//                ChineseWordTable.imageNumber <- self.imageNumber,
//                ChineseWordTable.tags <- Tag.concatenate(tags: self.tags)
//            ))
//        } catch let Result.error( _, code, _) where code == SQLITE_CONSTRAINT {
//            return false
//        } catch {
//            fatalError("WordList_AddEnglishWord fail : \(error.localizedDescription)")
//        }
//        
//        // Add word directory
//        DataConnector.createDir(path: dir, dirExist: false)
//        // Add Data
//        DataConnector.P_Word_Data_Addfiles(wordDirPath: dir, images: images, audioFileURL: audio)
//        return true
//    }
//    func WordList_DeleteWord(db: SQLite.Connection, table: SQLite.Table) {
//        do {
//            let wordRecord = table.filter(ChineseWordTable.spell == self.spell && ChineseWordTable.type == Int64(self.type))
//            try db.run(wordRecord.delete())
//            DataConnector.deleteDir(path: dir)
//        } catch {
//            fatalError("WordList_DeleteWord: \(error.localizedDescription)")
//        }
//    }
//    func WordList_EditWord(db: Connection, table: SQLite.Table) {
//        do {
//            let wordRecord = table.filter(ChineseWordTable.spell == spell && ChineseWordTable.type == Int64(type))
//            try db.run(wordRecord.update(
//                ChineseWordTable.passCount <- passCount,
//                ChineseWordTable.imageNumber <- imageNumber,
//                ChineseWordTable.tags <- Tag.concatenate(tags: tags)
//            ))
//        } catch {
//            fatalError("P_WordList_Record_EditChineseWord: \(error.localizedDescription)")
//        }
//        // delete directory
//        DataConnector.clearDir(path: dir)
//        // readd all data
//        DataConnector.P_Word_Data_Addfiles(wordDirPath: dir, images: images, audioFileURL: audio)
//    }
//    static func Folder_AddWordList(table: SQLite.Table) -> String {
//        return table.create { t in
//            t.column(ChineseWordTable.spell)
//            t.column(ChineseWordTable.type)
//            t.column(ChineseWordTable.passCount)
//            t.column(ChineseWordTable.imageNumber)
//            t.column(ChineseWordTable.tags)
//            t.primaryKey(ChineseWordTable.spell, ChineseWordTable.type)
//        }
//    }
//}
//
//struct ChineseWordTable {
//    static let spell = SQLite.Expression<String>("Spell") // Primary Key
//    static let type = SQLite.Expression<Int64>("TypeNumber") // Primary Key
//    
//    static let passCount = SQLite.Expression<Int64>("PassCount")
//    static let imageNumber = SQLite.Expression<Int64>("ImageNumber")
//    static let tags = SQLite.Expression<String>("Tag")
//}
