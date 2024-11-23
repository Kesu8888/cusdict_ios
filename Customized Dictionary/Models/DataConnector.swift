//
//  DataConnector.swift
//  Customized Dictionary
//
//  Created by Fu Kaiqi on 2024/11/21.
//

import Foundation
import SQLite

class DataConnector {
    var db: Connection
    var mainFolder: SQLTable
    var jsonEncoder = JSONEncoder()
    var jsonDecoder = JSONDecoder()
    
    init() {
        let dir = NSSearchPathForDirectoriesInDomains(
            .documentDirectory,
            .userDomainMask,
            true
        ).first!
        
        do {
            try db = Connection("\(dir)/db.sqlite3")
            mainFolder = SQLTable(table: Table("mainFolder"))
            
            try db.run(mainFolder.table.create(ifNotExists: true) { t in
                t.column(SQLTable.name, primaryKey: true)
                t.column(SQLTable.data)
            })
        } catch {
            fatalError("Create mainFOlder unsuccessfully")
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
    
    /// Create a new Table in the database
    /// - Parameters
    ///         - tableName
    /// - Throws: fatalError if the creation fails
    func createTable(tableName: String) {
        var table = Table(tableName)
        do {
            try db.run(table.create { t in
                t.column(SQLTable.name, primaryKey: true)
                t.column(SQLTable.data)
            })
        } catch {
            fatalError("createTable failed error is \(error)")
        }
    }
    
    func insertRow(tableName: String, name: String, t: Codable) {
        
    }
    deinit {
        do {
            try db.run(mainFolder.table.delete())
        } catch {
            fatalError("\nDelete Table unsuccessfully \(error)")
        }
    }
}
