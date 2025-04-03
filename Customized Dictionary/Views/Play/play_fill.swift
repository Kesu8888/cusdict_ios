//
//  play_fill.swift
//  Customized Dictionary
//
//  Created by Fu Kaiqi on 2025/3/6.
//

import SwiftUI

struct play_fill: View {
    let questionString: String
    let fill: fill_question
    let fontSize = UIScreen.main.bounds.width * 0.05
    let image: UIImage?
    let maximumChars = 10
    let charCover: [Int]
    private var charArray: [Character]
    @State private var charColor: [Color]
    
    @State private var userInput: [String]
    @FocusState private var focusedField: Int?
    @State private var answerd: Bool = false
    @State private var answerCorrect: Bool = false
    @State private var showExplain: Bool = false
    @State private var errorMsg: String = ""
    private var answerColor: Color {
        if !answerd {
            return Color.teal
        }
        return answerCorrect ? Color.green : Color.red
    }
    
    init(question: Question) {
        fill = fill_question(questionData: question.questionData)
        questionString = question.questionString
        if question.file != nil {
            image = FileContent.image(question.file!.file)
        } else {
            image = nil
        }
//        image = question.file? ??
        userInput = Array(repeating: "", count: fill.answer.id.count)
        charCover = fill_question.coverChar(question: fill)
        charArray = Array(fill.answer.id)
        charColor = Array(repeating: Color.gray, count: fill.answer.id.count)
    }
    
    var body: some View {
        VStack {
            HStack {
                Spacer()
                if questionString.isEmpty {
                    Text("No question added")
                        .padding()
                        .foregroundStyle(Color.red)
                } else {
                    Text(questionString)
                        .padding()
                }
                Spacer()
            }
            .font(CustomFont.SFPro_Rounded(.semibold, size: fontSize))
            
            if image != nil {
                
            }
            
            let sizeChange: CGFloat = charArray.count <= maximumChars ? 1 : (CGFloat(charArray.count) / CGFloat(maximumChars)) * 0.95
            let charFontSize = fontSize / sizeChange
            let charSpacing = UIScreen.main.bounds.width * 0.02 / sizeChange
            let charWidth = charFontSize * 1.5
            let charHeight = charFontSize * 2
            let coverChar = fill_question.coverChar(question: fill)
            // fill question HStack
            HStack(spacing: charSpacing) {
                Spacer()
                ForEach(charArray.indices, id: \.self) { charIndex in
                    if coverChar.contains(charIndex) {
                        // fill Char TextField
                        TextField("", text: $userInput[charIndex])
                            .focused($focusedField, equals: charIndex)
                            .onChange(of: userInput[charIndex], {
                                if userInput[charIndex].isEmpty {
                                    let cur_index = charCover.firstIndex(of: charIndex) ?? 0
                                    if cur_index == 0 {
                                        focusedField = charIndex
                                    } else {
                                        focusedField = charCover[cur_index - 1]
                                    }
                                } else {
                                    let cur_index = charCover.firstIndex(of: charIndex) ?? 0
                                    if cur_index == charCover.count - 1 {
                                        focusedField = nil
                                    } else {
                                        focusedField = charCover[cur_index + 1]
                                    }
                                }
                            })
                            .font(CustomFont.SFPro_Rounded(.semibold, size: charFontSize))
                            .frame(width: charWidth, height: charHeight)
                            .background(charColor[charIndex])
                            .cornerRadius(8)
                            .foregroundStyle(Color.white)
                            .multilineTextAlignment(.center)
                            .tag(charIndex)
                            .tint(Color.white)
                    } else {
                        Text("\(charArray[charIndex])")
                            .font(CustomFont.SFPro_Rounded(.semibold, size: charFontSize))
                    }
                }
                Spacer()
            }
            .padding(.vertical)
            
            if answerd && !answerCorrect {
                HStack(spacing: charSpacing) {
                    Spacer()
                    ForEach(charArray.indices, id: \.self) { charIndex in
                        if coverChar.contains(charIndex) {
                            // fill Char TextField
                            Text("\(charArray[charIndex])")
                                .font(CustomFont.SFPro_Rounded(.semibold, size: charFontSize))
                                .frame(width: charWidth, height: charHeight)
                                .background((Color.green))
                                .cornerRadius(8)
                                .foregroundStyle(Color.white)
                                .multilineTextAlignment(.center)
                                .tag(charIndex)
                                .tint(Color.white)
                        } else {
                            Text("\(charArray[charIndex])")
                                .font(CustomFont.SFPro_Rounded(.semibold, size: charFontSize))
                        }
                    }
                    Spacer()
                }
            }
            
            Spacer()
            Text(errorMsg)
                .foregroundStyle(Color.red)
            
            HStack {
                Button(action: {
                    var matchCharacters = 0
                    // implement answer
                    for index in charCover {
                        guard let char = userInput[index].first else {
                            withAnimation(.default) {
                                errorMsg = "answer not complete"
                            }
                            return
                        }
                        if charArray[index].lowercased() == char.lowercased() {
                            matchCharacters += 1
                            charColor[index] = Color.green
                        } else {
                            charColor[index] = Color.red
                        }
                    }
                    withAnimation(.default) {
                        answerd = true
                        errorMsg = ""
                        if matchCharacters == coverChar.count {
                            answerCorrect = true
                        } else {
                            answerCorrect = false
                        }
                    }
                }, label: {
                    if !answerd {
                        Text("confirm")
                            
                    } else {
                        if answerCorrect {
                            Image(systemName: "checkmark.circle")
                                .font(.system(size: fontSize * 1.2))
                        } else {
                            Image(systemName: "xmark.circle")
                                .font(.system(size: fontSize * 1.2))
                        }
                    }
                })
                .foregroundStyle(Color.white)
                .frame(width: fontSize * 6, height: fontSize * 2)
                .background(answerColor)
                .cornerRadius(15)
                .disabled(answerd)
                
                if !fill.answer.explaination.isEmpty && answerd {
                    Button(action: {
                        withAnimation(.default) {
                            showExplain.toggle()
                        }
                    }, label: {
                        Image(systemName: "info.circle")
                    })
                }
            }
            
            if showExplain {
                Text(fill.answer.explaination)
                    .foregroundStyle(Color.white)
                    .padding()
                    .background(Color.gray)
                    .cornerRadius(15)
            }
        }
        .padding()
        .background(CustomColor.colorFromHex(hex: "f2f2f6"))
    }
}

fileprivate struct testView: View {
    private let question: fill_question = fill_question(
        answer: ans_exp(
            answer: "hello",
            explaination: "Happy means good things and Joyful also means good things, that's why they are synonyms"
        )
    )
    
    var body: some View {
        play_fill(
            question: Question(
                bindedMeaning: 0,
                questionType: .fill,
                questionData: question.toQuestionData(),
                questionString: "What is the synonym of the word \"happy\"?"
            )
        )
    }
}

#Preview {
    testView()
}
