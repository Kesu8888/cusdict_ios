//
//  testNavigation.swift
//  Customized Dictionary
//
//  Created by Fu Kaiqi on 2025/3/29.
//

import SwiftUI

struct testNavigation: View {
    var body: some View {
        NavigationStack {
            List {
                NavigationLink(destination: Text("Hello"), label: {
                    Text("tap")
                })
            }
        }
    }
}

#Preview {
    testNavigation()
}
