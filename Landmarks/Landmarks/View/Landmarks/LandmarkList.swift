//
//  LandmarkList.swift
//  Landmarks
//
//  Created by Fu Kaiqi on 2024/11/11.
//

import SwiftUI

struct LandmarkList: View {
    @State private var showFavouriteOnly = false
    @Environment(ModelData.self) var modelData
    
    var filteredLandmarks: [Landmark] {
        modelData.landmarks.filter { mark in
            (!showFavouriteOnly || mark.isFavorite)
        }
    }
    
    var body: some View {
        NavigationSplitView{
            List {
                Toggle(isOn: $showFavouriteOnly) {
                    Text("FavouriteOnly")
                }
                
                ForEach(filteredLandmarks) { mark in
                    NavigationLink {
                        LandmarkDetail(landmark: mark)
                    } label: {
                        LandmarkRow(landmark: mark)
                    }
                }
            }
            .navigationTitle("Landmarks")
            .animation(.default, value: filteredLandmarks)
        } detail: {
            Text("Select a Landmark")
        }
    }
}

#Preview {
    LandmarkList()
        .environment(ModelData())
}
