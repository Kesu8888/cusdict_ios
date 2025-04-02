//
//  playQuestion.swift
//  Customized Dictionary
//
//  Created by Fu Kaiqi on 2025/3/18.
//

import SwiftUI

struct playQuestion: View {
    let question: Question
    
    var body: some View {
        switch question.questionType {
        case .mcq:
            play_mcq(question: question)
        case .answer:
            play_answer(question: question)
        case .fill:
            play_fill(question: question)
        }
    }
}

fileprivate struct testView: View {
    private let passQuestion: Question
    
    init() {
        let question: mcq_question = mcq_question(
            answer: ans_exp(
                answer: "Joyful",
                explaination: "Happy means good things and Joyful also means good things, that's why they are synonyms"
                ),
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
        passQuestion = Question(
            bindedMeaning: 120,
            questionType: .mcq,
            questionData: question.toQuestionData(),
            questionString: ""
        )
    }
    
    
    var body: some View {
        playQuestion(question: passQuestion)
    }
}

#Preview {
    testView()
}
