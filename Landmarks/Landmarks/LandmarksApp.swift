//
//  LandmarksApp.swift
//  Landmarks
//
//  Created by Fu Kaiqi on 2024/11/10.
//

import SwiftUI

@main
struct LandmarksApp: App {
    @State private var modelData = ModelData()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(modelData)
        }
    }
}
