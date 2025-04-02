//
//  WordRange.swift
//  Customized Dictionary
//
//  Created by Fu Kaiqi on 2025/3/31.
//

import Foundation

protocol WordRange {
    func toPackString() -> String
    func ranges() -> [String]
    func getRange(word: String) -> String
    func getCurRange() -> String
    mutating func setCurRange(range: String) -> Void
}

struct WordRangeInit {
    static func RangeVerifier(packString: String) -> Bool {
        switch packString {
        case "5F3A9C7E1B4D6A8F2C0D":
            return true
        default:
            return false
        }
    }
    
    static func initRange(packString: String) -> WordRange {
        // Extract the first 20 characters of the packString
        let prefixString = String(packString.prefix("5F3A9C7E1B4D6A8F2C0D".count))
        
        switch prefixString {
        case "5F3A9C7E1B4D6A8F2C0D":
            return EnglishAlphabetRange()
        default:
            return CustomizedRange(packString: packString)
        }
    }
}

struct EnglishAlphabetRange: WordRange {
    let range = ["abc", "def", "ghi", "jkl", "mno", "pqrs", "tuv", "wxyz", "*"]
    var current_Range: String
    
    init(packString: String = "5F3A9C7E1B4D6A8F2C0D|") {
        // Extract the current_Range from the packString
        let components = packString.split(separator: "|").map { String($0) }
        if components.count > 1 {
            self.current_Range = components[1]
        } else {
            self.current_Range = "abc" // Default value if current_Range is missing
        }
    }
    
    // To be recognified by the WordRangeInit
    func toPackString() -> String {
        return "5F3A9C7E1B4D6A8F2C0D|\(current_Range)"
    }
    
    func ranges() -> [String] {
        return range
    }
    
    func getRange(word: String) -> String {
        guard let firstChar = word.lowercased().first else {
            return "*"
        }
        
        for rangeGroup in range {
            if rangeGroup.contains(firstChar) {
                return rangeGroup
            }
        }
        return "*"
    }
    
    func getCurRange() -> String {
        return current_Range
    }
    
    mutating func setCurRange(range: String) {
        current_Range = range
    }
}

struct CustomizedRange: WordRange {
    var range: [String]
    var current_Range: String = "abc"
    
    init(range: [String]) {
        self.range = range
    }
    
    init(packString: String) {
        self.range = packString.split(separator: "|").map { String($0) }
    }
    
    func toPackString() -> String {
        return range.joined(separator: "|")
    }
    
    func ranges() -> [String] {
        return range
    }
    
    func getRange(word: String) -> String {
        return range[0]
    }
    
    func getCurRange() -> String {
        return current_Range
    }
    
    mutating func setCurRange(range: String) {
        current_Range = range
    }
}
