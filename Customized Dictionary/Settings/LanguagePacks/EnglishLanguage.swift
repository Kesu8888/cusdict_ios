//
//  EnglishLanguage.swift
//  Customized Dictionary
//
//  Created by Fu Kaiqi on 2024/12/30.
//

import Foundation

struct EnglishLanguage: UILanguage {
    var folderPage_Add: LanguageString = LanguageString(string: "add", font: CustomFont.SFPro_Rounded(.regular, size: 16))
    var folderPage_statusOn: LanguageString = LanguageString(string: "On", font: CustomFont.SFPro_Rounded(.regular, size: 16))
    var folderPage_statusOff: LanguageString = LanguageString(string: "Off", font: CustomFont.SFPro_Rounded(.regular, size: 16))
    
    var wordlistPage_searchbar: LanguageString = LanguageString(string: "Search in Wordlist", font: CustomFont.SFPro_Rounded(.regular, size: 16))
    var wordlistPage_sort1: LanguageStrings = LanguageStrings(strings: ["Date", "alpa", "words"], font: CustomFont.SFPro_Rounded(.regular, size: 16))
    var wordlistPage_wordCount: LanguageString = LanguageString(string: "words", font: CustomFont.SFPro_Rounded(.regular, size: 16))
    
    var addWordlistPage_listName: LanguageString = LanguageString(string: "ListName", font: CustomFont.SFPro_Rounded(.regular, size: 16))
    var addWordlistPage_lan: LanguageStrings = LanguageStrings(strings: ["English", "Chinese"], font: CustomFont.Songti(.regular, size: 16))
    var addWordlistPage_status: LanguageString = LanguageString(string: "status", font: CustomFont.SFPro_Rounded(.regular, size: 16))
    var addWordlistPage_passCount: LanguageString = LanguageString(string: "passCount", font: CustomFont.SFPro_Rounded(.regular, size: 16))
    var addWordlistPage_cancel: LanguageString = LanguageString(string: "Cancel", font: CustomFont.SFPro_Rounded(.regular, size: 16))
    var addWordlistPage_confirm: LanguageString = LanguageString(string: "Confirm", font: CustomFont.SFPro_Rounded(.regular, size: 16))
}
