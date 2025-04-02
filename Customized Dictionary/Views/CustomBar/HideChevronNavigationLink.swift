//
//  HideChevronNavigationLink.swift
//  Customized Dictionary
//
//  Created by Fu Kaiqi on 2025/3/26.
//

import SwiftUI

/// This can only be used in a list section
struct HideChevronNavigationLink<Destination: View, Content: View>: View {
    let destination: Destination
    let content: Content
    
    init(destination: Destination, @ViewBuilder content: () -> Content) {
        self.destination = destination
        self.content = content()
    }
    
    var body: some View {
        ZStack(alignment: .leading) {
            NavigationLink(destination: destination) {
                EmptyView()
            }
            .opacity(0)
            
            content
        }
    }
}

fileprivate struct testView: View {
    var body: some View {
        NavigationStack {
            HideChevronNavigationLink(destination: Text("Hello"), content: {
                Text("tap")
            })
        }
    }
}

#Preview {
    testView()
}
