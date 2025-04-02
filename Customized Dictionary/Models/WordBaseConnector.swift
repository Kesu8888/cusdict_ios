//
//  EnglishWordBase.swift
//  Customized Dictionary
//
//  Created by Fu Kaiqi on 2025/1/19.
//

import Foundation
import SQLite
import SQLite3

enum SearchLan {
    case English
//    case Chinese
}
class WordBaseConnector {
    let db: Connection
    let dir: String
        
    init() {
        do {
            let appDir = NSSearchPathForDirectoriesInDomains(
                .documentDirectory,
                .userDomainMask,
                true).first!
            dir = appDir
            let fileManager = FileManager.default
            
            // Path to the dictionary.db file in the project directory
            guard let projectDbPath = Bundle.main.path(forResource: "words", ofType: "db") else {
                fatalError("Unable to find dictionary.db in the project directory")
            }
            
            // Path to the dictionary.db file in the app's document directory
            let appDbPath = "\(dir)/dictionary.db"
            
            // This step is only for test
            if fileManager.fileExists(atPath: appDbPath) {
                try fileManager.removeItem(atPath: appDbPath)
            }
            
            // Copy the database file from the project directory to the app's document directory if it doesn't exist
            if !fileManager.fileExists(atPath: appDbPath) {
                try fileManager.copyItem(atPath: projectDbPath, toPath: appDbPath)
            }
            
            db = try Connection(appDbPath)
        } catch {
            fatalError("Copy dictionary.db from project directory to app directory fail")
        }
    }
    
    func searchWords(searchLan: SearchLan, translateLan: Translation_Language, pref: String) -> [Any]{
        switch searchLan {
        case .English:
            return en_word.searchWords(db: self.db, lan: translateLan, pref: pref)
        }
    }
    
    func en_SearchLemma(lan: Translation_Language, targetTrans: EnglishWordTrans) -> EnglishWord {
        return en_word.searchLemma(db: self.db, lan: lan, word: targetTrans)
    }
    
    func en_test_1000Words() -> [EnglishWord] {
        return en_word.test_1000Words(db: self.db)
    }
}
