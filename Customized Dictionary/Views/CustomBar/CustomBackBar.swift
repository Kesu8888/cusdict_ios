//
//  CustomBackBar.swift
//  Customized Dictionary
//
//  Created by Fu Kaiqi on 2025/2/6.
//

import SwiftUI

// CustomBackBar model, all CustomBackBar should be like this
struct CustomBackBar<Content: View>: View {
    @Environment(\.presentationMode) var presentationMode
    @State var showTabBar = false
    let content: Content
    
    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    
    var body: some View {
        HStack {
            Button(action: {
                showTabBar = true
                presentationMode.wrappedValue.dismiss()
            }, label: {
                HStack(spacing: 6) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 21))
                    Text("Back")
                        .font(CustomFont.SFPro(.regular, size: 18))
                }
            })
            content
        }
    }
}

struct CustomToolbarModifier: ViewModifier {
    @Environment(\.dismiss) private var dismiss
    let additionalToolbarItems: () -> AnyView

    func body(content: Content) -> some View {
        content
            .toolbar {
                ToolbarItem(placement: .topBarLeading, content: {
                    Button(action: {
                        dismiss()
                    }, label: {
                        HStack(spacing: 6) {
                            Image(systemName: "chevron.left")
                            Text("Back")
                        }
                    })
                })
                ToolbarItem(placement: .topBarTrailing, content: {
                    additionalToolbarItems()
                })
            }
    }
}

extension View {
    func customToolbar<Content: View>(@ViewBuilder additionalToolbarItems: @escaping () -> Content) -> some View {
        self.modifier(CustomToolbarModifier(additionalToolbarItems: { AnyView(additionalToolbarItems()) }))
    }
}

fileprivate struct testView: View {
    var body: some View {
        VStack {
            CustomBackBar(content: {
                Text("Hello")
            })
            Spacer()
            Text("Hello Word")
        }
    }
}
struct CustomBackBar_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            NavigationLink(destination: {
                testView()
            }, label: {
                Text("tab")
            })
        }
    }
}
