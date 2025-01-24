//
//  WordPage.swift
//  Customized Dictionary
//
//  Created by Fu Kaiqi on 2025/1/7.
//

import SwiftUI

struct WordPage: View {
    @State private var scrollPosition = ScrollPosition(y: 0)
    @State private var offsetY: CGFloat = 0

    var body: some View {
        NavigationView {
            ZStack(alignment: .top) {
                ScrollView {
                    VStack(alignment: .center) {
                        HStack(alignment: .center) {
                            // Your content here
                        }
                    }
                }
                .scrollPosition($scrollPosition)
                .onScrollGeometryChange(for: CGFloat.self) { geometry in
                    geometry.contentOffset.y
                } action: { oldValue, newValue in
                    if oldValue != newValue {
                        offsetY = newValue
                    }
                }
                
                VStack {
                    Spacer()
                        .frame(height: 10)
                    Text("Current Offset: \(String(format: "%.2f", offsetY))")
                        .padding()
                        .background(Color.white)
                        .cornerRadius(10)
                        .shadow(radius: 5)
                        .padding(.top, 10)
                }
            }
        }
    }
}

#Preview {
    WordPage()
}
