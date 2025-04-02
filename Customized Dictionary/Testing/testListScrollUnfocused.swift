//
//  testListScrollUnfocused.swift
//  Customized Dictionary
//
//  Created by Fu Kaiqi on 2025/3/28.
//

import SwiftUI

struct testListScrollUnfocused: View {
    @State private var text: String = ""
    @FocusState private var state: Bool
    
    var body: some View {
        List {
            TextField("Type something", text: $text)
                .focused($state)
        }
        .simultaneousGesture(
            DragGesture()
                .onChanged { _ in
                    state = false
                }
        )
    }
}

#Preview {
    testListScrollUnfocused()
}
