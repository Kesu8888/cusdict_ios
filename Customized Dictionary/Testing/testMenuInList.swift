//
//  testMenuInList.swift
//  Customized Dictionary
//
//  Created by Fu Kaiqi on 2025/3/29.
//

import SwiftUI
import UIKit

struct testMenuInList: View {
    @Environment(\.defaultMinListRowHeight) private var rowHeight: CGFloat
    @State private var showMenu = false
    
    var body: some View {
        List {
            Section {
                Text("\(showMenu)")
            }
            
            Text("\(rowHeight)")
            Section {
                UIMenuView()
//                    .frame(height: rowHeight, alignment: .leading)
            }
            .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
        }
    }
}

fileprivate struct UIMenuView: UIViewRepresentable {
    func makeUIView(context: Context) -> UIButton {
        // Create a UIButton
        let button = UIButton(type: .system)
        
        // Configure the button using UIButton.Configuration
        var configuration = UIButton.Configuration.plain()
        configuration.title = "Add Question"
        configuration.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 20, bottom: 0, trailing: 0) // Add padding to the leading
        configuration.baseForegroundColor = .systemBlue // Set the text color
        
        button.configuration = configuration
        button.contentHorizontalAlignment = .leading
        
        // Create the UIMenu with four buttons
        let menu = UIMenu(title: "", children: [
            UIAction(title: "Button 1", handler: { _ in print("Button 1 tapped") }),
            UIAction(title: "Button 2", handler: { _ in print("Button 2 tapped") }),
            UIAction(title: "Button 3", handler: { _ in print("Button 3 tapped") }),
            UIAction(title: "Button 4", handler: { _ in print("Button 4 tapped") })
        ])
        
        // Attach the menu to the button
        button.menu = menu
        button.showsMenuAsPrimaryAction = true // Show the menu when the button is tapped
        
        return button
    }
    
    func updateUIView(_ uiView: UIButton, context: Context) {
        // No updates needed for now
    }
}

#Preview {
    testMenuInList()
}
