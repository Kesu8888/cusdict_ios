//
//  PageView.swift
//  Landmarks
//
//  Created by Fu Kaiqi on 2024/11/16.
//

import SwiftUI

struct PageView<Page: View>: View {
    var pages: [Page]
    @State private var currentPage = 0
    
    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            PageViewController(
                pages: pages,
                currentPage: $currentPage
            )
                .aspectRatio(3/2, contentMode: .fit)
            PageControl(
                numberOfPages: pages.count,
                currentPage: $currentPage
            )
            .frame(width: CGFloat(pages.count*18))
            .padding(.trailing)
        }
        .aspectRatio(3/2, contentMode: .fit)
    }
}

#Preview {
    // map method is used to convert the [features] array to [View] by transforming each landmark to a FeatureCard view
    PageView(pages: ModelData().features.map {
        FeatureCard(landmark: $0)
    })
}
