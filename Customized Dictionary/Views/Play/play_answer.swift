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
    let image: FileObject?
    let fontSize = UIScreen.main.bounds.width * 0.05
    @State private var answerText = ""
    @State private var errorMsg = ""
    @State private var answerd = false
    @State private var answerCorrect = false
    @State private var displayExplain = false
    
    private var bgColor: Color {
        if !answerd {
            return Color.blue
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
        self.image = question.file
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
            
            Spacer()
            
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
                        TextField("answer", text: $answerText)
                            .multilineTextAlignment(.center)
                            .disabled(answerd)
                            .frame(height: geometry.size.height * 0.85)
                        
                        RoundedRectangle(cornerRadius: 30)
                            .fill(Color.black.opacity(0.3))
                            .frame(height: geometry.size.height * 0.05)
                            .padding(.horizontal)
                            .padding(.bottom, geometry.size.height * 0.1)
                    }
                    .frame(width: geometry.size.width * 0.7, height: geometry.size.height)
                    .background(RoundedRectangle(cornerRadius: 10)
                        .fill(Color.white))
                    
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
        play_answer(
            question: Question(
                bindedMeaning: 0,
                questionType: .answer,
                questionData: question.toQuestionData(),
                questionString: "What is the synonym of happy"
            )
        )
            .background(CustomColor.colorFromHex(hex: "f2f2f6"))
    }
}

#Preview {
    testView()
}
