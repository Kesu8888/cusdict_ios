//
//  testListToolbarBg.swift
//  Customized Dictionary
//
//  Created by Fu Kaiqi on 2025/4/1.
//

import SwiftUI

struct testListToolbarBg: View {
    var body: some View {
        NavigationStack {
            List {
                Text("Hello")
            }
            .toolbar {
                ToolbarItem(placement: .topBarLeading, content: {
                    Text("Hello")
                })
            }
        }
    }
}

fileprivate struct testView: View {
    @State private var showSheet = false
    
    var body: some View {
        Button(action: {
            showSheet = true
        }, label: {
            Text("tap")
        })
        .sheet(isPresented: $showSheet, content: {
            testListToolbarBg()
        })
    }
}
#Preview {
    testView()
}
