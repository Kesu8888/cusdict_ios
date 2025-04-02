//
//  ChineseLanguage.swift
//  Customized Dictionary
//
//  Created by Fu Kaiqi on 2024/12/30.
//

 import SwiftUI

struct ChineseLanguage: UILanguage {

    
    var folderPage_Add: LanguageString = LanguageString(string: "添加", font: CustomFont.Songti(.regular, size: 16))
    var folderPage_statusOn: LanguageString = LanguageString(string: "学习中", font: CustomFont.Songti(.regular, size: 16))
    var folderPage_statusOff: LanguageString = LanguageString(string: "未学习", font: CustomFont.Songti(.regular, size: 16))
    
    var wordlistPage_searchbar: LanguageString = LanguageString(string: "搜索单词表", font: CustomFont.Songti(.regular, size: 16))
    var wordlistPage_sort1: LanguageStrings = LanguageStrings(strings: ["日期", "首字母", "单词数"], font: CustomFont.Songti(.regular, size: 16))
    var wordlistPage_wordCount: LanguageString = LanguageString(string: "单词", font: CustomFont.Songti(.regular, size: 16))
    
    var addWordlistPage_listName: LanguageString = LanguageString(string: "列表名", font: CustomFont.Songti(.regular, size: 16))
    var addWordlistPage_lan: LanguageStrings = LanguageStrings(strings: ["英语", "中文"], font: CustomFont.Songti(.regular, size: 16))
    var addWordlistPage_status: LanguageString = LanguageString(string: "状态", font: CustomFont.Songti(.regular, size: 16))
    var addWordlistPage_passCount: LanguageString = LanguageString(string: "达标次数", font: CustomFont.Songti(.regular, size: 16))
    var addWordlistPage_cancel: LanguageString = LanguageString(string: "取消", font: CustomFont.Songti(.regular, size: 16))
    var addWordlistPage_confirm: LanguageString = LanguageString(string: "确认", font: CustomFont.Songti(.regular, size: 16))
}
