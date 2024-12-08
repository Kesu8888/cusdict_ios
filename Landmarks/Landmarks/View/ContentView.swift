//
//  ContentView.swift
//  Landmarks
//
//  Created by Fu Kaiqi on 2024/11/10.
//

import SwiftUI

struct ContentView: View {
    @State private var selection: mode = .list
    
    enum mode {
        case featured
        case list
    }
    
    var body: some View {
        // $ sign is used for binding a property wrapper
        TabView(selection: $selection) {
            LandmarkList()
                .tabItem {
                    // Give tab items a text and an icon
                    Label("List", systemImage: "list.bullet")
                }
                .tag(mode.list)
            
            CategoryHome()
                .tabItem {
                    // Give tab items a text and an icon
                    Label("Featured", systemImage: "star")
                }
                .tag(mode.featured)
        }
    }
}

#Preview {
    ContentView()
        .environment(ModelData())
}
