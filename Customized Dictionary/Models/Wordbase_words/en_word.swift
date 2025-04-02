//
//  en_word.swift
//  Customized Dictionary
//
//  Created by Fu Kaiqi on 2025/1/28.
//

import Foundation
import SQLite
import SQLite3

enum Translation_Language {
    case Chinese
//    case English
    
    var table: Table {
        switch self {
        case .Chinese:
            return Table("en_cn_Meaning")
            //        case .English:
            //            return Table("en_en_remove")
            //        }
        }
    }
}

struct en_wordTable {
    static let rowID = SQLite.Expression<Int64>("rowID")
    static let frequency = SQLite.Expression<Int64>("frequency")
}

struct en_word {
    // Used by the searchBar
    static func searchWords(db: Connection, lan: Translation_Language, pref: String) -> [EnglishWordTrans] {
        let query = lan.table
            .filter(EnglishWordTable.word.like("\(pref)%"))
            .order(en_wordTable.frequency.desc)
            .limit(10)
        
        var words: [EnglishWordTrans] = []
        do {
            for row in try db.prepare(query) {
                words.append(EnglishWordTrans(row: row))
            }
        } catch {
            fatalError("en_word getWords fail, \(error)")
        }
        return words
    }
    
    static func searchLemma(db: Connection, lan: Translation_Language, word: EnglishWordTrans) -> EnglishWord {
        if word.lemma.isEmpty {
            return EnglishWord(lemma: word.word + "+", lemmaVar: word.lemmaVar, range: word.range, transforms: [word], targetTrans: word)
        }
        
        do {
            let query = lan.table.filter(EnglishWordTable.lemma == word.lemma)
            let rows = try db.prepare(query)
            var words: [EnglishWordTrans] = []
            for row in rows {
                words.append(EnglishWordTrans(row: row))
            }
            return EnglishWord(lemma: word.lemma, lemmaVar: word.lemmaVar, range: word.range, transforms: words, targetTrans: word)
        } catch {
            fatalError("Failed to search lemma: \(error)")
        }
    }
    
    static func test_1000Words(db: Connection) -> [EnglishWord] {
        let query = Translation_Language.Chinese.table
            .filter(en_wordTable.rowID < 200)
            .order(EnglishWordTable.lemma)
        
        let wordRange = EnglishAlphabetRange()
        
        do {
            var englishWords: [EnglishWord] = []
            let englishWordReset = EnglishWord(lemma: "", lemmaVar: 0, range: "", transforms: [])
            var englishWord = EnglishWord(lemma: "", lemmaVar: 0, range: "", transforms: [])
            for row in try db.prepare(query) {
                var wordBaseWord = EnglishWordTrans(row: row)
                wordBaseWord.range = wordRange.getRange(word: wordBaseWord.word)
                
                if wordBaseWord.lemma.isEmpty {
                    if englishWord.transforms.count > 0 {
                        englishWords.append(englishWord)
                    }
                    englishWords.append(
                        EnglishWord(
                            lemma: wordBaseWord.word + "+",
                            lemmaVar: 0,
                            range: "",
                            transforms: [wordBaseWord]
                        )
                    )
                    englishWord = englishWordReset
                    continue
                }
                
                if wordBaseWord.lemma != englishWord.lemma {
                    if englishWord.transforms.count > 0 {
                        englishWords.append(englishWord)
                    }
                    englishWord = EnglishWord(
                        lemma: wordBaseWord.lemma,
                        lemmaVar: 0,
                        range: "",
                        transforms: [wordBaseWord]
                    )
                } else {
                    englishWord.transforms.append(wordBaseWord)
                }
            }
            if englishWord.transforms.count > 0 {
                englishWords.append(englishWord)
            }
            return englishWords
        } catch {
            fatalError("en_word getWords fail, \(error)")
        }
    }
}
