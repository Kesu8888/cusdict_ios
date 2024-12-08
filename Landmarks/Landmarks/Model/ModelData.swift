//
//  ModelData.swift
//  Landmarks
//
//  Created by Fu Kaiqi on 2024/11/10.
//

import Foundation

@Observable
class ModelData {
    var landmarks: [Landmark] = load("landmarkData.json")
    var hikes: [Hike] = load("hikeData.json")
    
    // [String: [Landmarks]] is the way to define a dictionary. It means create a dictionary with String type as key and [landmarks] array to be values
    var categories: [String: [Landmark]] {
        // grouping feature is used to separate landmarks into different string groups based on their Category
        Dictionary(
            grouping: landmarks,
            // raw value can be used for enum. The rawvalue can only be strings, characters, or any integer or floating-point type
            by: { $0.category.rawValue }
        )
    }
    
    var features: [Landmark] {
        landmarks.filter {$0.isFeatured}
    }
    
    var profile = Profile.default
}

func load<T: Decodable>(_ filename: String) -> T {
    let data: Data


    guard let file = Bundle.main.url(forResource: filename, withExtension: nil)
    else {
        fatalError("Couldn't find \(filename) in main bundle.")
    }


    do {
        data = try Data(contentsOf: file)
    } catch {
        fatalError("Couldn't load \(filename) from main bundle:\n\(error)")
    }


    do {
        let decoder = JSONDecoder()
        return try decoder.decode(T.self, from: data)
    } catch {
        fatalError("Couldn't parse \(filename) as \(T.self):\n\(error)")
    }
}
