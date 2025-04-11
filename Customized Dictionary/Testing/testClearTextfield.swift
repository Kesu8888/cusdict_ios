//
//  testClearTextfield.swift
//  Customized Dictionary
//
//  Created by Kesu Peterill on 2025/4/4.
//

import SwiftUI

struct testClearTextfield: View {
    var inputTextArray: [Character] {
        return Array(inputText)
    }
    @State var answer: [Character]
    @State var blankChar: [Int]
    @Binding var inputText: String
    @FocusState var isTyping: Bool
    @Binding var isAnswered: Bool
    @Binding var typing: Bool
    @Binding var answerCorrect: Bool
    
    var body: some View {
        VStack {
            let totalSpacePerChar: CGFloat = spacePerChar(charCount: answer.count)
            let TextSide: CGFloat = totalSpacePerChar * 4 / 5
            let remainingSpace = totalSpacePerChar * 1 / 5
            let horizontalPadding: CGFloat = remainingSpace * 2 / 6
            let verticalPadding: CGFloat = horizontalPadding * 1.5
            let spacing: CGFloat = totalSpacePerChar * 2 / 6
            ZStack {
                TextField("", text: $inputText)
                    .textInputAutocapitalization(.never)
                    .focused($isTyping)
                    .autocorrectionDisabled(true)
                    .foregroundStyle(Color.clear)
                    .accentColor(.clear)
                    .frame(width: 1, height: 1)
                    .background(.clear)
                    .onChange(of: inputText, { oldText, newText in
                        if newText.count >= blankChar.count {
                            inputText = String(newText.prefix(blankChar.count))
                            if oldText.count == blankChar.count - 1 {
                                isTyping = false
                            }
                        }
                    })
                    .onChange(of: typing, {
                        isTyping = typing
                    })
                    .onChange(of: isTyping, {
                        typing = isTyping
                    })
                HStack(spacing: spacing) {
                    ForEach(answer.indices, id: \.self) { charIndex in
                        if let blankCharPos = blankChar.firstIndex(of: charIndex) {
                            let displayChar = blankCharPos < inputTextArray.count ? inputTextArray[blankCharPos] : " "
                            Text(String(displayChar))
                                .foregroundStyle(Color.white)
                                .frame(width: TextSide * 0.8, height: TextSide)
                                .padding(.vertical, verticalPadding)
                                .padding(.horizontal, horizontalPadding)
                                .background(RoundedRectangle(cornerRadius: 10))
                                .cornerRadius(radiusPerChar(charCount: 4))
                        } else {
                            Text("\(answer[charIndex])")
                                .foregroundStyle(.black)
                                .bold()
                        }
                    }
                }
                .font(.system(size: 20))
                .contentShape(Rectangle())
                .onTapGesture {
                    isTyping = true
                }
            }
            
            if isAnswered && !answerCorrect {
                ZStack {
                    HStack(spacing: spacing) {
                        ForEach(answer.indices, id: \.self) { charIndex in
                            if let blankCharPos = blankChar.firstIndex(of: charIndex) {
                                let displayChar = blankCharPos < inputTextArray.count ? inputTextArray[blankCharPos] : " "
                                Text(String(answer[charIndex]))
                                    .foregroundStyle(Color.white)
                                    .frame(width: TextSide * 0.8, height: TextSide)
                                    .padding(.vertical, verticalPadding)
                                    .padding(.horizontal, horizontalPadding)
                                    .background(RoundedRectangle(cornerRadius: 10)
                                        .fill(displayChar == answer[charIndex] ? .green : .red))
                                    .cornerRadius(radiusPerChar(charCount: 4))
                            } else {
                                Text("\(answer[charIndex])")
                                    .foregroundStyle(.black)
                                    .bold()
                            }
                        }
                    }
                    .font(.system(size: 20))
                }
            }
        }
    }
    private func spacePerChar(charCount: Int) -> CGFloat {
        if charCount <= 5 { return 34 }
        if charCount <= 10 { return 25 }
        return 20
    }
    
    private func radiusPerChar(charCount: Int) -> CGFloat {
        if charCount <= 5 { return 8 }
        if charCount <= 10 { return 6 }
        return 4
    }
    
    private func fontPerChar(charCount: Int) -> Font {
        if charCount <= 8 { return Font.system(size: 20) }
        if charCount <= 12 { return Font.system(size: 17) }
        return Font.system(size: 14)
    }
}

fileprivate struct testView: View {
    @State var inputText = "pp"
    @State var answerd: Bool = false
    @State var isTyping = false
    @State var answerCorrect = false
    
    var body: some View {
        NavigationView(
            content: {
                VStack {
                    Text("Hello")
                    testClearTextfield(
                        answer: ["a", "p", "p", "l", "e"],
                        blankChar: [1, 2],
                        inputText: $inputText,
                        isAnswered: $answerd,
                        typing: $isTyping,
                        answerCorrect: $answerCorrect
                    )
                Button(action: {
                    
                }, label: {
                    
                })
                Spacer()
            }
            .toolbar {
                ToolbarItem(placement: .keyboard, content: {
                    Button(action: {
                        isTyping = false
                    }, label: {
                        Text("Done")
                    })
                })
            }
        })

//        .background(.black)
    }
}

#Preview {
    testView()
}
