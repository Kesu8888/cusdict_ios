//
//  HikeBadge.swift
//  Landmarks
//
//  Created by Fu Kaiqi on 2024/11/15.
//

import SwiftUI

struct HikeBadge: View {
    var name: String
    
    var body: some View {
        VStack {
            //  To ensure the desired appearance, render in a frame of 300 x 300 points. To get the desired size for the final graphic, then scale the rendered result and place it in a comparably smaller frame.
            Badge()
                .frame(width: 300, height: 300)
                .scaleEffect(1.0 / 3.0)
                .frame(width: 100, height: 100)
            
            Text(name)
                .font(.caption)
                .accessibilityLabel("Badge for the \(name).")
        }
        
    }
}

#Preview {
    HikeBadge(name: "Preview Testing")
}
