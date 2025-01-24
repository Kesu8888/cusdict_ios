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
            guard let projectDbPath = Bundle.main.path(forResource: "dictionary", ofType: "db") else {
                fatalError("Unable to find dictionary.db in the project directory")
            }
            
            // Path to the dictionary.db file in the app's document directory
            let appDbPath = "\(dir)/dictionary.db"
            
            // Copy the database file from the project directory to the app's document directory if it doesn't exist
            if !fileManager.fileExists(atPath: appDbPath) {
                try fileManager.copyItem(atPath: projectDbPath, toPath: appDbPath)
            }
            
            db = try Connection(appDbPath)
        } catch {
            fatalError("Copy dictionary.db from project directory to app directory fail")
        }
    }
    
//    func searchWords(lan: SearchLan, prefix: String) -> [AnyObject] {
//        switch lan {
//        case .English: {
//            
//        }
//        }
//    }
}

fileprivate struct EnglishWordBaseTable {
    static let table = SQLite.Table("EnglishWordBase")
    static let baseSpell = SQLite.Expression<String>("baseSpell")
    static let transform = SQLite.Expression<String>("transform")
    static let wordtype = SQLite.Expression<String>("wordtype")
    static let definition = SQLite.Expression<String>("definition")
    static let likes = SQLite.Expression<Int64>("likes")
}
