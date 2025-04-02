//
//  FileObject.swift
//  Customized Dictionary
//
//  Created by Fu Kaiqi on 2025/3/10.
//

import Foundation
import SwiftUI

enum FileType: String {
    case image = ".png"
}

enum FileContent {
    case image(UIImage)
}

struct FileObject: Hashable {
    let fileType: FileType
    let fileName: String
    var file: FileContent?
    
    init(fileType: FileType, file: FileContent? = nil) {
        self.fileType = fileType
        self.fileName = String(format: "%04X", Int.random(in: 0..<65536)) + fileType.rawValue
        self.file = file
    }
    
    init(packString: String, fileDirectory: String) {
        let components = packString.components(separatedBy: "||")
        guard components.count == 2 else {
            fatalError("Invalid packString format")
        }
        
        self.fileType = FileType(rawValue: components[0]) ?? .image
        self.fileName = components[1]
        
        let filePath = (fileDirectory as NSString).appendingPathComponent(fileName)
        switch fileType {
        case .image:
            if let image = UIImage(contentsOfFile: filePath) {
                self.file = .image(image)
            } else {
                fatalError("Failed to load image from file path")
            }
        }
    }
    
    func toPackString() -> String {
        return "\(fileType.rawValue)||\(fileName)"
    }
    
    func putFile(fileDirectory: String) {
        guard let file = file else {
            fatalError("File is nil")
        }
        
        let filePath = (fileDirectory as NSString).appendingPathComponent(fileName)
        switch file {
        case .image(let image):
            guard let data = image.pngData() else {
                fatalError("Failed to convert image to PNG data")
            }
            do {
                try data.write(to: URL(fileURLWithPath: filePath))
            } catch {
                fatalError("Failed to write image to file: \(error)")
            }
        }
    }
    
    // Conform to Hashable
    static func == (lhs: FileObject, rhs: FileObject) -> Bool {
        return lhs.fileName == rhs.fileName
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(fileName)
    }
}
