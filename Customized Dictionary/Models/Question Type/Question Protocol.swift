//
//  Question Protocol.swift
//  Customized Dictionary
//
//  Created by Fu Kaiqi on 2025/2/27.
//

import Foundation

enum QuestionType: String, Identifiable, CaseIterable {
    case mcq = "mcq"
    case answer = "ans"
    case fill = "fill"
    
    var id: String { self.rawValue }
}

// show Question separator below
// Field Separator for Question: ^
// Field Separator for mcq, answer, fill: |
// List Separator for mcq, answer, fill: ~
// Database Separator: #
// Field Separator for ans_exp: §

class Question: ObservableObject, Equatable {
    var id: Int { // Unique identifier as an Int hash value
        var hasher = Hasher()
        hasher.combine(bindedMeaning)
        hasher.combine(questionType.rawValue)
        hasher.combine(questionData)
        hasher.combine(questionString)
        return hasher.finalize()
    }
    var bindedMeaning: Int // This is the hashcode of the binded meaning
    var questionString: String // New variable
    @Published var questionType: QuestionType
    @Published var questionData: String
    var file: FileObject?

    static let blankQuestion = "||||||||||"

    // fileDir will be the directory that contains files of all question
    init(packString: String, files: Set<FileObject>) {
        let components = packString.split(separator: "^").map { String($0) }
        self.bindedMeaning = Int(components[0])!
        self.questionType = QuestionType(rawValue: components[1]) ?? .mcq
        self.questionData = components[2]
        self.questionString = components[3] // Initialize questionString from the packString
        if let fileHash = Int(components[4]), fileHash != 0 {
            self.file = files.first(where: { $0.hashValue == fileHash })
        }
    }

    init(bindedMeaning: Int, questionType: QuestionType, questionData: String, questionString: String, file: FileObject? = nil) {
        self.bindedMeaning = bindedMeaning
        self.questionType = questionType
        self.questionData = questionData
        self.questionString = questionString // Initialize questionString
        self.file = file
    }

    init() {
        self.bindedMeaning = 0
        self.questionType = .answer
        self.questionData = Question.blankQuestion
        self.questionString = "" // Default value for questionString
    }

    static func id(bindedMeaning: Int, questionType: QuestionType, questionData: String, questionString: String) -> Int {
        var hasher = Hasher()
        hasher.combine(bindedMeaning)
        hasher.combine(questionType.rawValue)
        hasher.combine(questionData)
        hasher.combine(questionString)
        return hasher.finalize()
    }

    func packString() -> String {
        return "\(bindedMeaning)^\(questionType.rawValue)^\(questionData)^\(questionString)^\(file?.hashValue ?? 0)"
    }

    static func toDatabaseRaw(questions: [Question]) -> String {
        return questions.map { $0.packString() }.joined(separator: "#")
    }

    static func fromDatabaseRaw(databaseRaw: String, files: Set<FileObject>) -> [Question] {
        return databaseRaw.split(separator: "#").map { Question(packString: String($0), files: files) }
    }

    static func fileType(type: QuestionType) -> FileType {
        switch type {
        case .mcq:
            return .image
        case .answer:
            return .image
        case .fill:
            return .image
        }
    }

    static func == (lhs: Question, rhs: Question) -> Bool {
        return lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(bindedMeaning)
        hasher.combine(questionType.rawValue)
        hasher.combine(questionData)
        hasher.combine(questionString)
    }
}

struct ans_exp: Hashable, Identifiable {
    var id: String //id is used to conform to Identifiable and is also used as the answer
    var explaination: String
    
    init(answer: String, explaination: String) {
        self.id = answer
        self.explaination = explaination
    }
    
    init(packString: String) {
        let components = packString.split(separator: "§", omittingEmptySubsequences: false).map { String($0) }
        self.id = components[0]
        self.explaination = components.count > 1 ? components[1] : ""
    }
    
    func pack() -> String {
        return "\(id)§\(explaination)"
    }
}

// show all the separator used
// Field Separator: |
// List Separator: ~
struct mcq_question {
    var answer: ans_exp
    var choices: [ans_exp]
    static let fileType = FileType.image

    init(answer: ans_exp, choices: [ans_exp] = []) {
        self.answer = answer
        self.choices = choices
    }

    init(questionData: String) {
        let components = questionData.split(separator: "|", omittingEmptySubsequences: false).map { String($0) }
        self.answer = ans_exp(packString: components[0])
        self.choices = components[1].split(separator: "~").map { ans_exp(packString: String($0)) }
    }

    func toQuestionData() -> String {
        let choicesString = choices.map { $0.pack() }.joined(separator: "~")
        return "\(answer.pack())|\(choicesString)"
    }
}

struct answer_question {
    var answers: [ans_exp]
    static let fileType = FileType.image

    init(answers: [ans_exp]) {
        self.answers = answers
    }

    init(questionData: String) {
        let components = questionData.split(separator: "|", omittingEmptySubsequences: false).map { String($0) }
        self.answers = components[0].split(separator: "~").map { ans_exp(packString: String($0)) }
    }

    func toQuestionData() -> String {
        let answersString = answers.map { $0.pack() }.joined(separator: "~")
        return "\(answersString)"
    }
}

enum fillCoverArea: String, CaseIterable {
    case leading = "leading"
    case middle = "middle"
    case trailing = "trailing"
    case side = "side"
    case random = "random"
}

struct fill_question {
    var answer: ans_exp
    var coverage: Int
    var coverArea: fillCoverArea

    init(answer: ans_exp, coverage: Int = 2, coverArea: fillCoverArea = .middle) {
        self.answer = answer
        self.coverage = coverage
        self.coverArea = coverArea
    }

    init(questionData: String) {
        let components = questionData.split(separator: "|", omittingEmptySubsequences: false).map { String($0) }
        self.answer = ans_exp(packString: components[0])
        self.coverage = Int(components[1]) ?? 0
        self.coverArea = fillCoverArea(rawValue: components[2]) ?? .leading
    }

    func toQuestionData() -> String {
        return "\(answer.pack())|\(coverage)|\(coverArea.rawValue)"
    }

    static func coverChar(question: fill_question) -> [Int] {
        let answerCharCount = Array(question.answer.id).count
        let shadingCharacters: Int = answerCharCount * question.coverage / 5
        var shadingArray: [Int] = []
        switch question.coverArea {
        case .leading:
            shadingArray = [Int](0..<shadingCharacters)
        case .middle:
            let middle = answerCharCount / 2
            let halfShading = shadingCharacters / 2
            if shadingCharacters % 2 == 0 {
                shadingArray = [Int]((middle - halfShading)..<(middle + halfShading))
            } else {
                shadingArray = [Int]((middle - halfShading)...(middle + halfShading))
            }
        case .trailing:
            shadingArray = [Int]((answerCharCount - shadingCharacters)..<answerCharCount)
        case .side:
            let halfShading = shadingCharacters / 2
            shadingArray = Array(0..<(halfShading + shadingCharacters % 2)) + Array((answerCharCount - halfShading)..<answerCharCount)
        case .random:
            var uniqueRandomNumbers = Set<Int>()
            while uniqueRandomNumbers.count < shadingCharacters {
                uniqueRandomNumbers.insert(Int.random(in: 0..<answerCharCount))
            }
            shadingArray = Array(uniqueRandomNumbers)
        }
        return shadingArray
    }
}
