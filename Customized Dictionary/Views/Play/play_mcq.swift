//
//  play_mcq.swift
//  Customized Dictionary
//
//  Created by Fu Kaiqi on 2025/3/5.
//

import SwiftUI

struct play_mcq: View {
    let mcq: mcq_question
    let questionString: String
    
    let image: FileObject?
    var randomizedChoices: [ans_exp]
    let fontSize = UIScreen.main.bounds.width * 0.05
    let answerHeight = UIScreen.main.bounds.height * 0.07
    let correctAnswer: String
    @State private var answerd: String = ""
    @State private var explainAnswer: String = ""
    
    var correctAnswerBgColor: Color {
        return answerd.isEmpty ?  Color.gray : Color.green
    }
    
    var wrongAnswerBgColor: Color {
        return answerd.isEmpty ?  Color.gray : Color.red
    }
    
    init(question: Question) {
        mcq = mcq_question(questionData: question.questionData)
        questionString = question.questionString
        self.image = question.file
        correctAnswer = mcq.answer.id
        randomizedChoices = mcq.choices + [mcq.answer]
        randomizedChoices.shuffle()
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
            
            VStack {
                ForEach(randomizedChoices, id: \.id) { choice in
                    let rightOrWrong = choice.id == correctAnswer
                    // Row Button
                    VStack {
                        ZStack {
                            Button(action: {
                                withAnimation(.default) {
                                    answerd = choice.id
                                }
                            }, label: {
                                HStack {
                                    RoundedRectangle(cornerRadius: 0)
                                        .fill(Color.clear)
                                }
                                .frame(height: answerHeight)
                            })
                            .disabled(!answerd.isEmpty)
                            
                            HStack {
                                Text(choice.id)
                                    .font(CustomFont.SFPro_Rounded(.semibold, size: answerHeight * 0.3))
                                    .foregroundStyle(Color.white)
                                    .padding(.horizontal)
                                if !answerd.isEmpty && !choice.explaination.isEmpty {
                                    // Info button
                                    Button(action: {
                                        withAnimation(.default) {
                                            explainAnswer = choice.id
                                        }
                                    }, label: {
                                        Image(systemName: "info.circle")
                                            .font(.title3)
                                            .foregroundStyle(Color.white)
                                    })
                                }
                                
                                Spacer()
                                if answerd == choice.id {
                                    Image(systemName: answerd == correctAnswer ? "checkmark.circle.fill" : "xmark.circle.fill")
                                        .font(.title3)
                                        .foregroundStyle(Color.white)
                                        .padding(.horizontal)
                                }
                            }
                        }
                        if explainAnswer == choice.id {
                            HStack {
                                Text(choice.explaination)
                                    .foregroundStyle(Color.white)
                                Spacer()
                            }
                            .padding(.horizontal)
                            .padding(.bottom)
                        }
                    }
                    .background(RoundedRectangle(cornerRadius: 10)
                        .fill(rightOrWrong ? correctAnswerBgColor : wrongAnswerBgColor))
                }
            }
        }
        .padding()
        .background(CustomColor.colorFromHex(hex: "f2f2f6"))
    }
}

fileprivate struct testView: View {
    private let question: mcq_question = mcq_question(
        answer: ans_exp(answer: "as", explaination: ""),
        choices:
             [ans_exp(
                answer: "Angry",
                explaination: "This is not the correct answer"
             ),
             ans_exp(
                answer: "Sad",
                explaination: ""
             ),
             ans_exp(
                answer: "Tired",
                explaination: ""
             )]
    )
    
    var body: some View {
        NavigationStack {
            NavigationLink(
                destination: {
                    play_mcq(
                        question: Question(
                            bindedMeaning: 0,
                            questionType: .mcq,
                            questionData: question.toQuestionData(),
                            questionString: "What's the synonym of happy?"
                        )
                    )
                },
                label: {
                Text("tap")
            })
        }
    }
}
#Preview {
    testView()
}
