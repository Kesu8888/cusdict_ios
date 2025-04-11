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
    let answer: [Character]
    @State private var inputText: String = ""
    @State private var isTyping: Bool = false
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
        answer = Array(fill.answer.id)
        if case let .image(uiImage) = question.file?.file {
            image = uiImage
        } else {
            image = nil
        }
        charCover = fill_question.coverChar(question: fill)
    }
    
    var body: some View {
        NavigationView {
            VStack {
                // Display question
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
                    displayImageView(
                        displayImage: image!,
                        height: UIScreen.main.bounds.height * 0.3,
                        ratio: .wider
                    )
                }
                
                // interaction fill
                testClearTextfield(
                    answer: answer,
                    blankChar: charCover,
                    inputText: $inputText,
                    isAnswered: $answerd,
                    typing: $isTyping,
                    answerCorrect: $answerCorrect
                )
                
                Spacer()
                
                VStack {
                    Text(errorMsg)
                        .foregroundStyle(Color.red)
                    HStack {
                        Button(action: {
                            if inputText.count < charCover.count {
                                errorMsg = "Incomplete answer"
                                return
                            }
                            errorMsg = ""
                            
                            withAnimation{
                                answerd = true
                            }
                            
                            let expectedAnswer = charCover.map { String(answer[$0]) }.joined()
                            if inputText == expectedAnswer {
                                answerCorrect = true
                            } else {
                                answerCorrect = false
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
            }
            .toolbar {
                ToolbarItemGroup(placement: .keyboard, content: {
                    Button(action: {
                        isTyping = false
                    }, label: {
                        Text("Done")
                    })
                    
                    Spacer()
                })
            }
            .padding()
            .background(CustomColor.colorFromHex(hex: "f2f2f6"))
        }
    }
}

fileprivate struct fillText: View {
    var inputTextArray: [Character] {
        return Array(inputText)
    }
    @State var answer: [Character] = ["A", "p", "p", "l", "e"]
    @State var blankChar: [Int] = [1, 2]
    @State var inputText: String = "P"
    @FocusState var isTyping: Bool
    @Binding var isAnswered: Bool
    @Binding var typing: Bool
    
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
            
            if isAnswered {
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
    private let question: fill_question = fill_question(
        answer: ans_exp(
            answer: "hello",
            explaination: "Happy means good things and Joyful also means good things, that's why they are synonyms"
        )
    )
    
    var body: some View {
        if let image = UIImage(named: "apples") {
            let fileObject = FileObject(fileType: .image, file: .image(image))
            play_fill(
                question: Question(
                    bindedMeaning: 0,
                    questionType: .fill,
                    questionData: question.toQuestionData(),
                    questionString: "What is the synonym of the word \"happy\"?",
                    file: fileObject
                )
            )
        } else {
            Text("Image not found")
                .foregroundColor(.red)
        }
    }
}

#Preview {
    testView()
}
