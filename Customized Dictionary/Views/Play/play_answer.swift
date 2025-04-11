//
//  play_answer.swift
//  Customized Dictionary
//
//  Created by Fu Kaiqi on 2025/3/5.
//

import SwiftUI

struct play_answer: View {
    let answer: answer_question
    let questionString: String
    let image: UIImage?
    let fontSize = UIScreen.main.bounds.width * 0.05
    @State private var answerText = ""
    @State private var errorMsg = ""
    @State private var answerd = false
    @State private var answerCorrect = false
    @State private var displayExplain = false
    @FocusState private var isTyping
    
    private var bgColor: Color {
        if !answerd {
            return Color.blue
        }
        return answerCorrect ? Color.green : Color.red
    }
    
    private var answerBgColor: Color {
        if !answerd {
            return Color.gray
        }
        return answerCorrect ? Color.green : Color.red
    }
    
    private var bgImage: String {
        if !answerd {
            return "checkmark.circle.fill"
        }
        return answerCorrect ? "checkmark.circle.fill" : "xmark.circle.fill"
    }
    
    init(question: Question) {
        answer = answer_question(questionData: question.questionData)
        questionString = question.questionString
        if case let .image(uiImage) = question.file?.file {
            image = uiImage
        } else {
            image = nil
        }
    }
    
    var body: some View {
        NavigationView {
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
                    displayImageView(
                        displayImage: image!,
                        height: UIScreen.main.bounds.height * 0.3,
                        ratio: .wider
                    )
                }
                
                Spacer()
                
                VStack {
                    Text(errorMsg)
                        .foregroundStyle(Color.red)
                    if displayExplain {
                        VStack {
                            ForEach(answer.answers, id: \.id) { ans in
                                HStack {
                                    Text(
                                        "\(Text("\(ans.id):").bold().foregroundStyle(Color.yellow))  \(ans.explaination)"
                                    )
                                        .padding(.horizontal)
                                    Spacer()
                                }
                            }
                        }
                        .padding(.vertical)
                        .foregroundStyle(Color.white)
                        .background(Color.gray)
                        .cornerRadius(10)
                        .padding(.horizontal)
                    }
                    
                    GeometryReader { geometry in
                        HStack {
                            if answerd && answer.answers.contains(where: { $0.explaination != "" }) {
                                Button(action: {
                                    withAnimation(.default) {
                                        displayExplain.toggle()
                                    }
                                }, label: {
                                    Image(systemName: "info.circle")
                                        .frame(width: geometry.size.height * 0.6, height: geometry.size.height  * 0.6)
                                        .foregroundStyle(Color.blue)
                                })
                            }
                            
                            VStack(spacing: 0) {
                                TextField("", text: $answerText, prompt: Text("answer").foregroundStyle(Color.white.opacity(0.6)))
                                    .bold()
                                    .focused($isTyping)
                                    .accentColor(.white)
                                    .foregroundStyle(.white)
                                    .multilineTextAlignment(.center)
                                    .disabled(answerd)
                                    .frame(height: geometry.size.height * 0.85)
                                
                                RoundedRectangle(cornerRadius: 30)
                                    .fill(Color.white)
                                    .frame(height: geometry.size.height * 0.05)
                                    .padding(.horizontal)
                                    .padding(.bottom, geometry.size.height * 0.1)
                            }
                            .frame(width: geometry.size.width * 0.7, height: geometry.size.height)
                            .background(RoundedRectangle(cornerRadius: 10)
                                .fill(answerBgColor))
                            
                            Button(action: {
                                if answerText.isEmpty {
                                    errorMsg = "You have not answered yet"
                                    return
                                }
                                withAnimation(.default) {
                                    errorMsg = ""
                                    answerd = true
                                    if answer.answers.contains(where: { $0.id.lowercased() == answerText.lowercased() }) {
                                        answerCorrect = true
                                        return
                                    }
                                    answerCorrect = false
                                }
                            }, label: {
                                Image(systemName: bgImage)
                                    .resizable()
                                    .frame(width: geometry.size.height * 0.6, height: geometry.size.height  * 0.6)
                                    .foregroundStyle(bgColor)
                            })
                            .disabled(answerd)
                        }
                        .frame(width: geometry.size.width)
                    }
                    .frame(height: UIScreen.main.bounds.height * 0.05, alignment: .center)
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
        }
        .padding()
    }
}

fileprivate struct testView: View {
    let question: answer_question = answer_question(
        answers: [ans_exp(
            answer: "joyful",
            explaination: "no why"
        ),
          ans_exp(
            answer: "excited",
            explaination: "excited has the feeling of more than happy"
          )]
    )
    
    var body: some View {
        if let image = UIImage(named: "apples") {
            let fileObject = FileObject(fileType: .image, file: .image(image))
            play_answer(
                question: Question(
                    bindedMeaning: 0,
                    questionType: .answer,
                    questionData: question.toQuestionData(),
                    questionString: "What is the synonym of happy",
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
