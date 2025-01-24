//
//  ContentView.swift
//  Customized Dictionary
//
//  Created by Fu Kaiqi on 2024/11/19.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var modelData = ModelData()
    @State private var mode: Mode = .list
    @State private var showTabBar: Bool = true
        
    var body: some View {
        ZStack(alignment: .bottom) {
            FolderPage(modelData: modelData, showTabBar: $showTabBar)
            
            if showTabBar {
                CustomTabBar(selectedMode: $mode)
    //                .background(Color.white)
            }
            Text("debug: \(showTabBar)")
        }
        .background(mode != Mode.play ? Color(red: 241/255, green: 241/255, blue: 241/255) : Color.black)
        .edgesIgnoringSafeArea(.bottom)
    }
}

#Preview {
    ContentView()
}
