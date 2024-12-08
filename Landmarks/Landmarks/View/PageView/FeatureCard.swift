//
//  FeatureCard.swift
//  Landmarks
//
//  Created by Fu Kaiqi on 2024/11/16.
//

import SwiftUI

struct FeatureCard: View {
    var landmark: Landmark
    
    var body: some View {
        landmark.featureImage?
            .resizable()
            .overlay {
                TextOverlay(landmark: landmark)
            }
    }
}

struct TextOverlay: View {
    var landmark: Landmark
    
    var gradient: LinearGradient {
        .linearGradient(
            Gradient(colors: [.black.opacity(0.6), .black.opacity(0.0)]),
            startPoint: .bottom,
            endPoint: .center
        )
    }
    
    var body: some View {
        ZStack(alignment: .bottomLeading) {
            gradient
            VStack(alignment: .leading) {
                Text(landmark.name)
                    .font(.title)
                    .bold()
                Text(landmark.park)
            }
            .foregroundStyle(.white)
            .padding()
        }
    }
}

#Preview {
    FeatureCard(landmark: ModelData().features[0])
        .aspectRatio(3/2, contentMode: .fit)
//    TextOverlay(landmark: ModelData().features[0])
}
