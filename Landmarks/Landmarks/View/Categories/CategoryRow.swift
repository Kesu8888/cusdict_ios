//
//  CategoryRow.swift
//  Landmarks
//
//  Created by Fu Kaiqi on 2024/11/14.
//

import SwiftUI

struct CategoryRow: View {
    var categoryName: String
    var items: [Landmark]
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(categoryName)
                .font(.headline)
                .padding(.leading, 15)
                .padding(.top, 5)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(alignment: .top, spacing: 0) {
                    ForEach (items) { mark in
                        NavigationLink {
                            LandmarkDetail(landmark: mark)
                        } label: {
                            // The item text inside label is changed for unknown reasons
                            CategoryItem(landmark: mark)
                        }
                    }
                }
            }
            .frame(height: 185)
        }
    }
}

#Preview {
    let landmarks = ModelData().landmarks
    return CategoryRow(
        categoryName: landmarks[0].category.rawValue,
        // [array].prefix(2) means get the first 2 elements of the [array] as an array
        items: Array(landmarks.prefix(4))
    )
}
