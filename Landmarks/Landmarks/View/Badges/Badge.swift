//
//  Badge.swift
//  Landmarks
//
//  Created by Fu Kaiqi on 2024/11/13.
//

import SwiftUI

struct Badge: View {
    var badgeSymbol : some View {
        // "..<" is half open range operator
        ForEach (0..<8) { index in
            RotatedBadgeSymbol(angle: Angle(degrees: 360.0 / 8.0 * Double(index)))
        }
        .opacity(0.5)
    }
    
    var body: some View {
        //Zstack is puting the views inward and inward
        ZStack {
            BadgeBackground()
            
            GeometryReader { geometry in
                badgeSymbol
                    .scaleEffect(1.0 / 4.0, anchor: .top)
                    .position(x: geometry.size.width / 2.0, y: 3.0 / 4.0 * geometry.size.height)
            }
        }
        .scaledToFit()
    }
}

#Preview {
    Badge()
}
