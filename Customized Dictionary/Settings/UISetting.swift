//
//  UILanguage.swift
//  Customized Dictionary
//
//  Created by Fu Kaiqi on 2024/12/30.
//

import Foundation

//protocol UILanguage {
//    var folderPage: [String: String] { get }
//    var wordlistPage: [String: String] { get }
//    var pickerData: [PickerKey: [String]] { get }
//    
//    func localizedString(forKey key: String, page: Page) -> String
//    func getPickerData(key: PickerKey) -> [String]
//}
import SwiftUI

struct UISetting {
    private var language: LanguageCode {
        didSet {
            UserDefaults.standard.set(language.rawValue, forKey: "US.language")
        }
    }
    var languagePackage: UILanguage {
        switch language {
        case .English:
            return EnglishLanguage()
        case .Chinese:
            return ChineseLanguage()
        }
    }
    init() {
        let savedLanguage = UserDefaults.standard.string(forKey: "US.language") ?? "English"
        language = LanguageCode(rawValue: savedLanguage)!
    }
}

enum LanguageCode: String {
    case Chinese = "Chinese"
    case English = "English"
}

struct LanguageStrings {
    let strings: [String]
    let font: Font
}

struct LanguageString {
    let string: String
    let font: Font
}
protocol UILanguage {
    var folderPage_Add: LanguageString { get }
    var folderPage_statusOn: LanguageString { get }
    var folderPage_statusOff: LanguageString { get }
    
    var wordlistPage_searchbar: LanguageString { get }
    var wordlistPage_sort1: LanguageStrings { get }
    var wordlistPage_wordCount: LanguageString { get }
    
    var addWordlistPage_listName: LanguageString { get }
    var addWordlistPage_lan: LanguageStrings { get }
    var addWordlistPage_status: LanguageString { get }
    var addWordlistPage_passCount: LanguageString { get }
    var addWordlistPage_cancel: LanguageString { get }
    var addWordlistPage_confirm: LanguageString { get }
}
