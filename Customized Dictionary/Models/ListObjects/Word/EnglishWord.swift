//
//  Word.swift
//  Customized Dictionary
//
//  Created by Fu Kaiqi on 2024/11/19.
//

import Foundation
import SwiftUI
import SQLite

enum EnglishWordEditFunction {
    case editMeaning
    case editQuestion
    case none
}

struct EnglishWord: Word, Identifiable {
    var id: String {"\(lemma)|\(lemmaVar)"}
    let lemma: String //If the word is a lemma, lemma will be any of the transforms'lemma; if the word is not a lemma, this englishWord will only contains one transform and thus the lemma will be (transforms[0].word + "+"). "+" symbol is to distinguish between lemma and non-lemma
    var lemmaVar: Int64
    var range: String
    var transforms: [EnglishWordTrans]
    var targetTrans: [EnglishWordTrans] = [] // used by editWord and by search En_word(When searching a word, the wordBase will automatically search for all the lemma words related to that word, and the targetTrans[0] will be the word that is searched by the user)
    var editFunction: EnglishWordEditFunction = .none
    
    private static func trans_path(WordListDir: String, trans: EnglishWordTrans, dbLemma: String) -> String {
        return "\(WordListDir)/\(dbLemma)_\(trans.word)\(trans.lemmaVar)"
    }
    
    static func WordList_GetWords(db: Connection, table: SQLite.Table, WordListDir: String, wordRange: WordRange) -> [String: [EnglishWord]] {
        var wordsDict = [String: [EnglishWord]]()
        
        let ranges = wordRange.ranges()
        // Initialize wordsDict with all ranges as keys and empty arrays as values
        for range in ranges {
            wordsDict[range] = []
        }

        // Get rows lemma, word, range from the table
        var words: [EnglishWord] = []
        var word = EnglishWord(lemma: "", lemmaVar: 0, range: "", transforms: [], targetTrans: [])

        do {
            let query = table.select(EnglishWordTable.lemma, EnglishWordTable.lemmaVar, EnglishWordTable.word, EnglishWordTable.range).order(EnglishWordTable.lemma, EnglishWordTable.lemmaVar)

            for w in try db.prepare(query) {

                let wordTrans = EnglishWordTrans(
                    lemma: w[EnglishWordTable.lemma],
                    lemmaVar: w[EnglishWordTable.lemmaVar],
                    word: w[EnglishWordTable.word],
                    range: w[EnglishWordTable.range]
                )
                
                if wordTrans.lemma.isEmpty {
                    // Check if last word is valid, if yes add it to wordsDict
                    if word.transforms.count > 0 {
                        words.append(word)
                    }
                    words.append(EnglishWord(lemma: wordTrans.word + "+", lemmaVar: wordTrans.lemmaVar, range: wordTrans.range, transforms: [wordTrans], targetTrans: []))
                    word.transforms.removeAll()
                    continue
                }
                
                if wordTrans.lemma != word.lemma || wordTrans.lemmaVar != word.lemmaVar {
                    if word.transforms.count > 0 {
                        word.range = word.transforms[0].range
                        word.lemmaVar = word.transforms[0].lemmaVar
                        words.append(word)
                    }
                    word = EnglishWord(lemma: wordTrans.lemma, lemmaVar: wordTrans.lemmaVar, range: wordTrans.range, transforms: [wordTrans], targetTrans: [])
                    continue
                }
                
                word.transforms.append(wordTrans)
            }
        } catch {
            fatalError("Failed to query the database: \(error)")
        }
        
        // Add the last word to the dictionary
        if word.transforms.count > 0 {
            word.range = word.transforms[0].range
            word.lemmaVar = word.transforms[0].lemmaVar
            words.append(word)
        }

        for w in words {
            let rangeKey = w.range
            if wordsDict[rangeKey] == nil {
                fatalError("ranges do not contain the range of word \(word.transforms[0].word)")
            }
            wordsDict[rangeKey]?.append(w)
        }
        
        return wordsDict
    }

    // fill the wordTrans' all parameters
    static func WordList_LoadWord(db: Connection, table: SQLite.Table, WordListDir: String, W: EnglishWord) -> EnglishWord {
        var word = W
        let isLemma = word.lemma.last != "+"
        let dbLemma = isLemma ? word.lemma : ""
        let lemmaVar = word.transforms[0].lemmaVar
        
        // Define the query based on whether it is a lemma or not
        let query: SQLite.Table
        if isLemma {
            // Case 1: If it is a lemma, get all records with lemma = dbLemma and lemmaVar = lemmaVar
            query = table.filter(EnglishWordTable.lemma == dbLemma && EnglishWordTable.lemmaVar == lemmaVar)
        } else {
            // Case 2: If it is not a lemma, get all records with lemma = dbLemma, lemmaVar = lemmaVar, and word = W.transforms[0].word
            guard let wordValue = W.transforms.first?.word else {
                fatalError("WordList_LoadWord: transforms[0].word is nil")
            }
            query = table.filter(EnglishWordTable.lemma == dbLemma && EnglishWordTable.lemmaVar == lemmaVar && EnglishWordTable.word == wordValue)
        }
        
        // Query the database and process each row
        do {
            for row in try db.prepare(query) {
                // Initialize fields from the row
                let wordValue = row[EnglishWordTable.word]
                let phonetic = row[EnglishWordTable.phonetic]
                let exchange = row[EnglishWordTable.exchange]
                let passCount = row[EnglishWordTable.passCount]
                let meaningPackString = row[EnglishWordTable.meaning]
                let files = row[EnglishWordTable.files]
                let questionPackString = row[EnglishWordTable.question]

                // Find the index of the transform in W.transforms where the word matches
                if let index = word.transforms.firstIndex(where: { $0.word == wordValue }) {
                    // Load the transform with the data from the row
                    word.transforms[index].loadTrans(
                        phonetic: phonetic,
                        exchange: exchange,
                        passCount: passCount,
                        meaningPackString: meaningPackString,
                        files: files,
                        questionPackString: questionPackString,
                        fileDir: EnglishWord.trans_path(WordListDir: WordListDir, trans: word.transforms[index], dbLemma: dbLemma)
                    )
                }
            }
        } catch {
            fatalError("Failed to query the database: \(error)")
        }
        return word
    }
    
    // First test whether the same (lemma and lemmaVar)/(lemma and lemmaVar and word) exist for EnglishWordTrans or targetTrans, if exist, increase the lemmaVar until not exist
    func WordList_AddWord(db: SQLite.Connection, table: SQLite.Table, WordListDir: String) -> Self {
        let isLemma = self.lemma.last != "+"
        let dbLemma = isLemma ? self.lemma : ""
    
        var minimumLemmaVar: Int64 = 0
        // get the minimum unique lemmaVar
        do {
            let lemmaVarQuery: SQLite.Table = isLemma ? table.filter(EnglishWordTable.lemma == dbLemma) : table.filter(EnglishWordTable.lemma == dbLemma && EnglishWordTable.word == self.transforms[0].word)
            for row in try db.prepare(lemmaVarQuery.select(EnglishWordTable.lemmaVar).order(EnglishWordTable.lemmaVar.asc)) {
                if minimumLemmaVar != row[EnglishWordTable.lemmaVar] {break}
                minimumLemmaVar += 1
            }
        } catch {
            fatalError("Failed to execute lemmaVarQuery: \(error)")
        }
        
        // Add Record to wordlistTable
        for w in transforms {
            let trans_path = EnglishWord.trans_path(WordListDir: WordListDir, trans: w, dbLemma: dbLemma)
            // Create word directory if it is not exist
            DataConnector.createDir(path: trans_path, dirExist: false)
            w.addFiles(fileDir: trans_path)
            
            do {
                try db.run(table.insert(
                    EnglishWordTable.lemma <- dbLemma,
                    EnglishWordTable.lemmaVar <- minimumLemmaVar,
                    EnglishWordTable.word <- w.word,
                    EnglishWordTable.phonetic <- w.phonetic,
                    EnglishWordTable.exchange <- w.exchange.joined(separator: "/"),
                    EnglishWordTable.passCount <- w.passCount,
                    EnglishWordTable.range <- w.range,
                    EnglishWordTable.meaning <- Meaning.packMeanings(meanings: w.meaning),
                    EnglishWordTable.files <- w.filesPack(),
                    EnglishWordTable.question <- Question.toDatabaseRaw(questions: w.question) // Edited line
                ))
            } catch {
                fatalError("WordList_AddEnglishWord fail")
            }
        }
        var returnWord = self
        returnWord.lemmaVar = minimumLemmaVar
        return returnWord
    }
    
    func WordList_DeleteWord(db: Connection, table: SQLite.Table, WordListDir: String) {
        let isLemma = self.lemma.last != "+"
        let dbLemma = isLemma ? self.lemma : ""
        
        let deleteQuery = isLemma ? table.filter(EnglishWordTable.lemma == dbLemma && EnglishWordTable.lemmaVar == self.lemmaVar) : table.filter(EnglishWordTable.lemma == dbLemma && EnglishWordTable.lemmaVar == self.lemmaVar && EnglishWordTable.word == transforms[0].word)
        do {
            for trans in transforms {
                DataConnector.deleteDir(path: EnglishWord.trans_path(WordListDir: WordListDir, trans: trans, dbLemma: dbLemma))
            }
            try db.run(deleteQuery.delete())
        } catch {
            fatalError("WordList_DeleteWord: \(error.localizedDescription)")
        }
    }
    
    // EditWord will update all the trans in self.transforms, words that has no changed should not be in the transforms
    func WordList_EditWord(db: Connection, table: SQLite.Table, WordListDir: String) {
        let dbLemma = transforms[0].lemma
        do {
            // Fetch all existing records for the current lemma and lemmaVar
            let existingRecords = try db.prepare(
                table.filter(EnglishWordTable.lemma == dbLemma && EnglishWordTable.lemmaVar == self.lemmaVar)
            ).map { row in
                (word: row[EnglishWordTable.word], row: row)
            }
            let existingWords = Set(existingRecords.map { $0.word })
            
            // Iterate over all transforms
            for transform in self.transforms {
                // Generate the file directory path for the transform
                let fileDir = EnglishWord.trans_path(WordListDir: WordListDir, trans: transform, dbLemma: dbLemma)

                // Add files to the directory
                transform.addFiles(fileDir: fileDir)

                if existingWords.contains(transform.word) {
                    // Update the existing record
                    let wordRecord = table.filter(
                        EnglishWordTable.lemma == dbLemma &&
                        EnglishWordTable.lemmaVar == self.lemmaVar &&
                        EnglishWordTable.word == transform.word
                    )
                    try db.run(wordRecord.update(
                        EnglishWordTable.phonetic <- transform.phonetic,
                        EnglishWordTable.exchange <- transform.exchange.joined(separator: "/"),
                        EnglishWordTable.passCount <- transform.passCount,
                        EnglishWordTable.meaning <- Meaning.packMeanings(meanings: transform.meaning),
                        EnglishWordTable.files <- transform.filesPack(),
                        EnglishWordTable.question <- transform.packQuestion()
                    ))
                } else {
                    // Insert the new record
                    try db.run(table.insert(
                        EnglishWordTable.lemma <- dbLemma,
                        EnglishWordTable.lemmaVar <- transform.lemmaVar,
                        EnglishWordTable.word <- transform.word,
                        EnglishWordTable.phonetic <- transform.phonetic,
                        EnglishWordTable.exchange <- transform.exchange.joined(separator: "/"),
                        EnglishWordTable.passCount <- transform.passCount,
                        EnglishWordTable.range <- transform.range,
                        EnglishWordTable.meaning <- Meaning.packMeanings(meanings: transform.meaning),
                        EnglishWordTable.files <- transform.filesPack(),
                        EnglishWordTable.question <- transform.packQuestion()
                    ))
                }
            }
        } catch {
            fatalError("WordList_EditWord: Failed to edit word: \(error.localizedDescription)")
        }
    }
    
    static func Folder_AddWordList(table: SQLite.Table) -> String {
        return table.create { t in
            t.column(EnglishWordTable.lemma)
            t.column(EnglishWordTable.lemmaVar)
            t.column(EnglishWordTable.word)
            t.column(EnglishWordTable.phonetic)
            t.column(EnglishWordTable.exchange)
            t.column(EnglishWordTable.passCount)
            t.column(EnglishWordTable.range)
            t.column(EnglishWordTable.meaning)
            t.column(EnglishWordTable.files)
            t.column(EnglishWordTable.question) // Edited line
            t.primaryKey(EnglishWordTable.lemma, EnglishWordTable.lemmaVar, EnglishWordTable.word) // Updated line
         }
    }
}

struct EnglishWordTrans {
    // Each of the properties are stored as a column in the database
    var lemma: String
    var lemmaVar: Int64 // Indicate the variant of lemma
    var word: String
    var range: String
    var phonetic: String = ""
    var exchange: [String] = [] // exchanges are separated by "/"
    var passCount: Int64 = 0
    var meaning: [Meaning] = []
    var question: [Question] = []
    
    var files: Set<FileObject> = []
    
    // quick init, only load four parameters for displaying in EnglishWordPage
    init(lemma: String, lemmaVar: Int64, word: String, range: String) {
        self.lemma = lemma
        self.lemmaVar = lemmaVar
        self.word = word
        self.range = range
    }
    
    /// Used by en_cn wordBase
    init(row: Row) {
        self.lemma = row[EnglishWordTable.lemma]
        self.lemmaVar = 0
        self.word = row[EnglishWordTable.word]
        self.range = ""
        self.phonetic = row[EnglishWordTable.phonetic]
        self.exchange = row[EnglishWordTable.exchange].split(separator: "/").map { String($0) }
        self.meaning = Meaning.wordBaseUnpackMeanings(meaningPackString: row[EnglishWordTable.meaning])
        self.question = []
    }
    
    // Only when the user edit or view the englishWordTrans, the func is executed
    mutating func loadTrans(phonetic: String, exchange: String, passCount: Int64, meaningPackString: String, files: String, questionPackString: String, fileDir: String) {
        self.phonetic = phonetic
        self.exchange = exchange.split(separator: "/").map { String($0) }
        self.passCount = passCount
        self.meaning = Meaning.unpackMeanings(meaningPackString: meaningPackString)
        let allFiles = filesUnpack(files: files, fileDir: fileDir)
        self.files = allFiles
        self.question = Question.fromDatabaseRaw(databaseRaw: questionPackString, files: allFiles) // Edited line
    }
    
    func filesPack() -> String {
        return files.map { $0.toPackString() }.joined(separator: "/")
    }
    
    func filesUnpack(files: String, fileDir: String) -> Set<FileObject> {
        let fileObjects = files.split(separator: "/").map { FileObject(packString: String($0), fileDirectory: fileDir) }
        return Set(fileObjects)
    }
    
    // Since files won't contain many files, we can just clear the fileDir and add all the files again.
    func addFiles(fileDir: String) {
        DataConnector.clearDir(path: fileDir)
        for f in files {
            f.putFile(fileDirectory: fileDir)
        }
    }
    
    func packQuestion() -> String {
        return question.map { $0.packString() }.joined(separator: "#")
    }
}

struct Meaning: Hashable, Identifiable {
    var id: String {"\(wordtype)|\(phonetic)|\(translation)"}
    var wordtype: EnglishWordtype
    var phonetic: String
    var translation: String
    
    init(wordtype: EnglishWordtype, translation: String, phonetic: String) {
        self.wordtype = wordtype
        self.translation = translation
        self.phonetic = phonetic
    }
    
    init(packString: String) {
        let components = packString.components(separatedBy: "||")
        self.wordtype = EnglishWordtype(rawValue: components[0]) ?? .error
        self.phonetic = components[1]
        self.translation = components[2]
    }
    
    init(wordBasePackString: String) {
        let components = wordBasePackString.components(separatedBy: "||")
        self.wordtype = EnglishWordtype(rawValue: components[0]) ?? .error
        self.phonetic = components[1]
        self.translation = components[2]
    }
    
    // using || as the separator of the fields
    private func toPackString() -> String {
        return "\(wordtype.rawValue)||\(phonetic)||\(translation)"
    }
    
    static func packMeanings(meanings: [Meaning]) -> String {
        return meanings.map { $0.toPackString() }.joined(separator: "§§")
    }
    
    static func unpackMeanings(meaningPackString: String) -> [Meaning] {
        return meaningPackString.split(separator: "§§").map { Meaning(packString: String($0)) }
    }
    
    static func wordBaseUnpackMeanings(meaningPackString: String) -> [Meaning] {
        return meaningPackString.split(separator: "§§").map { Meaning(wordBasePackString: String($0)) }
    }
    
    static func == (lhs: Meaning, rhs: Meaning) -> Bool {
        return lhs.wordtype == rhs.wordtype &&
               lhs.phonetic == rhs.phonetic &&
               lhs.translation == rhs.translation
    }
    
    // Implementing the hash function
    func hash(into hasher: inout Hasher) {
        hasher.combine(wordtype)
        hasher.combine(phonetic)
        hasher.combine(translation)
    }
}

enum EnglishWordtype: String, CaseIterable, Identifiable {
    case noun = "n"
    case verb = "v"
    case intransVerb = "vi"
    case transVerb = "vt"
    case adjective = "adj"
    case adverb = "adv"
    case pronoun = "pron"
    case preposition = "prep"
    case article = "art"
    case auxilary = "aux"
    case abbreviation = "abbr"
    case conjunction = "conj"
    case goodInterj = "int"
    case rudeInterj = "intj"
    case nounComb = "na"
    case numeral = "num"
    case v_pl = "pl"
    case prefix = "pref"
    case suffix = "suf"
    case error = "error"
    
    var id: String { self.rawValue }
}

struct EnglishWordTable {
    static let lemma = SQLite.Expression<String>("lemma") // Primary Key, baseSpell of the word verb or noun form
    static let lemmaVar = SQLite.Expression<Int64>("lemmaVar")
    static let word = SQLite.Expression<String>("word") // Spell of the verb
    static let phonetic = SQLite.Expression<String>("phonetic") // major phonetic of the word
    static let exchange = SQLite.Expression<String>("exchange")
    static let passCount = SQLite.Expression<Int64>("PassCount")
    static let range = SQLite.Expression<String>("range") //Indicate the range that the word belongs to
    static let meaning = SQLite.Expression<String>("meaning")
    static let files = SQLite.Expression<String>("files")
    static let question = SQLite.Expression<String>("question") // New column
}
