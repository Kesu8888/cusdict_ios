//
//  ListPageSetting.swift
//  Customized Dictionary
//
//  Created by Fu Kaiqi on 2025/2/11.
//

import Foundation

struct ListPageSetting {
    var WordList_Sort1: Int {
        didSet {
            UserDefaults.standard.set(WordList_Sort1, forKey: "LPS_WordList_Sort1")
        }
    }
    
    var WordList_SortDirection: Bool {
        didSet {
            UserDefaults.standard.set(WordList_SortDirection, forKey: "LPS_WordList_SortDirection")
        }
    }
    
    init() {
        let sort1 = UserDefaults.standard.integer(forKey: "LPS_WordList_Sort1")
        self.WordList_Sort1 = sort1
        let sortDirection = UserDefaults.standard.bool(forKey: "LPS_WordList_SortDirection")
        self.WordList_SortDirection = sortDirection
    }
}
