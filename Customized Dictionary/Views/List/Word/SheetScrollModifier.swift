//
//  SheetScrollModifier.swift
//  Customized Dictionary
//
//  Created by Fu Kaiqi on 2025/2/22.
//

import SwiftUI

struct SheetScrollModifier: ViewModifier {
    @Environment(\.dismiss) var dismiss
    var withScroll: Bool

    func body(content: Content) -> some View {
        let view = VStack {
            // DismissButton HStack
            HStack {
                Button(action: {
                    dismiss()
                }, label: {
                    Text("Cancel")
                        .padding()
                })
                Spacer()
            }
            
            if withScroll {
                ScrollView(.vertical, showsIndicators: false) {
                    content
                }
                .frame(width: .infinity, height: .infinity)
                .onAppear(perform: {
                    UIScrollView.appearance().delaysContentTouches = false
                })
            } else {
                content
            }
        }
        return view
    }
}

extension View {
    func withDismissButton(withScroll: Bool = true) -> some View {
        self.modifier(SheetScrollModifier(withScroll: withScroll))
    }
}
