//
//  CategoryItem.swift
//  Landmarks
//
//  Created by Fu Kaiqi on 2024/11/15.
//

import SwiftUI

struct CategoryItem: View {
    var landmark: Landmark
    
    var body: some View {
        VStack {
            landmark.image
            // the image may render as the environment's accent color. so we use .original to disallow the image to change with environment color accent
                .renderingMode(.original)
                .resizable()
                .frame(width: 155, height: 155)
                .cornerRadius(10)
            Text(landmark.name)
            // foregroundstyle is used to change the color of the text instead of background style
                .foregroundStyle(.black)
        }
        // (.leading) means the interval between each item is the same. .horizontal means the each item has the same interval for its left side and right side which makes the interval for middle items look bigger
        .padding(.leading, 15)
    }
}

#Preview {
    CategoryItem(landmark: ModelData().landmarks[0])
}
