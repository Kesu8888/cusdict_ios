//
//  fillTextField.swift
//  Customized Dictionary
//
//  Created by Fu Kaiqi on 2025/3/6.
//

import SwiftUI

struct fillTextField: View {
    private let wordSpell = "number"
    private let charCover = [0, 2, 4]
    private let numberOfFields = 3
    
    @State var enterValue: [String]
    @FocusState private var fieldFocus: Int?
    
    init() {
        self.enterValue = Array(repeating: "", count: wordSpell.count)
    }
    
    var body: some View {
        let charArray = Array(wordSpell)
        HStack {
            ForEach(charArray.indices, id: \.self) { index in
                if charCover.contains(index) {
                    TextField("", text: $enterValue[index])
                        .foregroundStyle(Color.white)
                        .frame(width: 50, height: 50)
                        .background(Color.blue.opacity(0.8))
                        .cornerRadius(8)
                        .multilineTextAlignment(.center)
                        .focused($fieldFocus, equals: index)
                        .tag(index)
                        .onChange(of: enterValue[index], {
                            if enterValue[index].isEmpty {
                                let cur_index = charCover.firstIndex(of: index) ?? 0
                                if cur_index == 0 {
                                    fieldFocus = index
                                } else {
                                    fieldFocus = charCover[cur_index - 1]
                                }
                            } else {
                                let cur_index = charCover.firstIndex(of: index) ?? 0
                                if cur_index == charCover.count - 1 {
                                    fieldFocus = nil
                                } else {
                                    fieldFocus = charCover[cur_index + 1]
                                }
                            }
                        })
                        .tint(Color.white)
                } else {
                    Text("\(charArray[index])")
                        .foregroundStyle(Color.black)
                }
            }
        }
    }
}

#Preview {
    fillTextField()
}
