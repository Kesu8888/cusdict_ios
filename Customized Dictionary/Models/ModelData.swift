//
//  ModelData.swift
//  Customized Dictionary
//
//  Created by Fu Kaiqi on 2024/11/19.
//

import Foundation

@Observable
class ModelData {
    var mainFolder: Folder
    var curFolder: Folder?
    var curWordlist: WordList?
    var curWord: Word?
    var dataConnector: DataConnector

    init() {
        dataConnector = DataConnector()
        curFolder = dataConnector.getMainFolder()
    }
}
