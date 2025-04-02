//
//  ans_expView.swift
//  Customized Dictionary
//
//  Created by Fu Kaiqi on 2025/3/8.
//

import SwiftUI

struct ans_expEditor: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var answerOrigin: ans_exp
    @State private var errorMsg: String = ""
    @State var answer: ans_exp
    @State var editWordAllow = true
    
    var body: some View {
        List {
            Section {
                TextField("Edit your answer", text: $answer.id)
                    .disabled(!editWordAllow)
                TextField("Edit your explaination", text: $answer.explaination)
                    .foregroundStyle(Color.brown)
            } footer: {
                Text(errorMsg)
                    .foregroundStyle(Color.red)
            }
        }
        .contentMargins(.top, 15)
        .toolbar {
            ToolbarItem(placement: .topBarLeading, content: {
                Button(action: {
                    if answer.id.isEmpty {
                        errorMsg = "The answer part is blank"
                        return
                    }
                    
                    if ViewHelper.questionText_validation(text: answer.id) || ViewHelper.questionText_validation(text: answer.explaination) {
                        withAnimation(.default) {
                            errorMsg = "answer or explaination contains characters ^, |, ~, #, §"
                        }
                        return
                    }
                    answerOrigin.id = answer.id
                    answerOrigin.explaination = answer.explaination
                    dismiss()
                }, label: {
                    HStack {
                        Image(systemName: "chevron.left")
                            .fontWeight(.medium)
                        Text("Back")
                    }
                })
            })
            ToolbarItem(placement: .topBarTrailing, content: {
                Button(action: {
                    dismiss()
                }, label: {
                    Text("Cancel")
                        .foregroundStyle(Color.red)
                })
            })
        }
        .navigationBarBackButtonHidden(true)
    }
}

struct ans_expAdder: View {
    @State private var answer: ans_exp = ans_exp(answer: "", explaination: "")
    @Binding var answers: [ans_exp]
    @State private var errorMsg: String = ""
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        List {
            Section {
                TextField("Edit your answer", text: $answer.id)
                TextField("Edit your explaination", text: $answer.explaination)
                    .foregroundStyle(Color.brown)
            } footer: {
                Text(errorMsg)
                    .foregroundStyle(Color.red)
            }
        }
        .contentMargins(.top, 15)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing, content: {
                Button(action: {
                    if answer.id.isEmpty {
                        errorMsg = "The answer part is blank"
                        return
                    }
                    
                    if answers.contains(where: { $0.id == answer.id }) {
                        withAnimation(.default) {
                            errorMsg = "The choice already exist"
                        }
                        return
                    }
                    
                    if ViewHelper.questionText_validation(text: answer.id) || ViewHelper.questionText_validation(text: answer.explaination) {
                        withAnimation(.default) {
                            errorMsg = "answer or explaination contains characters ^, |, ~, #, §"
                        }
                        return
                    }
                    
                    answers.append(answer)
                    dismiss()
                }, label: {
                    Text("Add")
                })
            })
        }
    }
}

struct question_Editor: View {
    @Environment(\.dismiss) private var dismiss
    @State private var errorMsg: String = ""
    @Binding var questionTextOrigin: String
    @State var questionText: String
    
    var body: some View {
        List {
            Section {
                TextField("Type your answer", text: $questionText, axis: .vertical)
                    .lineLimit(3...4)
            } footer: {
                Text(errorMsg)
                    .foregroundStyle(Color.red)
            }
        }
        .contentMargins(.top, 15)
        .toolbar {
            ToolbarItem(placement: .topBarLeading, content: {
                Button(action: {
                    if ViewHelper.questionText_validation(text: questionText) || ViewHelper.questionText_validation(text: questionText) {
                        withAnimation(.default) {
                            errorMsg = "answer or explaination contains characters ^, |, ~, #, §"
                        }
                        return
                    }
                    questionTextOrigin = questionText
                    dismiss()
                }, label: {
                    HStack {
                        Image(systemName: "chevron.left")
                            .fontWeight(.medium)
                        Text("Back")
                    }
                })
            })
            ToolbarItem(placement: .topBarTrailing, content: {
                Button(action: {
                    dismiss()
                }, label: {
                    Text("Cancel")
                        .foregroundStyle(Color.red)
                })
            })
        }
        .navigationBarBackButtonHidden(true)
    }
}

fileprivate struct testView2: View {
    @State private var questionText:String = ""
    
    var body: some View {
        question_Editor(questionTextOrigin: $questionText, questionText: questionText)
    }
}

fileprivate struct testView: View {
    @State private var ans: ans_exp = ans_exp(
        answer: "do",
        explaination: "the answer is do"
    )
    var body: some View {
        NavigationStack {
            NavigationLink(destination: {
                ans_expEditor(answerOrigin: $ans, answer: ans)
            }, label: {
                Text("tap")
            })
        }
        
    }
}

#Preview {
    testView()
}
