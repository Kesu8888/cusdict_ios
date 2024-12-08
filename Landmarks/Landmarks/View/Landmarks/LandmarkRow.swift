//
//  LandmarkRow.swift
//  Landmarks
//
//  Created by Fu Kaiqi on 2024/11/11.
//

import SwiftUI
import Foundation

struct LandmarkRow: View {
    var landmark: Landmark
    
    var body: some View {
        HStack(alignment: .center) {
            landmark.image
                .resizable()
                .frame(width: 60, height: 40)
            Text(landmark.name)
            
            Spacer()
            
            if (landmark.isFavorite) {
                Image(systemName: "star.fill")
                    .foregroundStyle(.yellow)
            }
        }
    }
}


#Preview {
    Group {
        LandmarkRow(landmark: ModelData().landmarks[0])
    }
}
