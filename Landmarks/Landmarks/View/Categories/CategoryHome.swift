//
//  CategoryHome.swift
//  Landmarks
//
//  Created by Fu Kaiqi on 2024/11/14.
//

import SwiftUI

struct CategoryHome: View {
    @Environment(ModelData.self) var modelData
    
    @State private var showProfile = false
    
    var body: some View {
        NavigationSplitView {
            List {
                PageView(pages: modelData.features.map {
                    FeatureCard(landmark: $0)
                })
                .listRowInsets(EdgeInsets())

                // We use the item itself as the key to identify each item when we are creating views. If the array contains duplicates, we should instead use                ForEach(items.indices, id: \.self)
                ForEach(modelData.categories.keys.sorted(), id: \.self){ key in
                    // '!' at the end of a value means this value definitely exist
                    CategoryRow(categoryName: key, items: modelData.categories[key]!)
                }
            }
            // the listStyle.inset can be used to switch to a style that better display the views
            .listStyle(.inset)
            .navigationTitle("Featured")
            .toolbar {
                Button {
                    showProfile.toggle()
                } label: {
                    Label("UserProfile", systemImage: "person.crop.circle")
                }
            }
            // sheet is used like a navigation. if the isPresented value is true, the view inside sheet will be presented
            .sheet(isPresented: $showProfile) {
                ProfileHost()
                    .environment(ModelData())
            }
        } detail: {
            Text("Select a Landmark")
        }
    }
}

#Preview {
    CategoryHome()
        // property wrapper values should be added outside the view
        .environment(ModelData())
}
