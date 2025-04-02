//
//  EnglishWordmcqEditor.swift
//  Customized Dictionary
//
//  Created by Fu Kaiqi on 2025/3/28.
//

import SwiftUI

struct EWmcqEditor: View {
    @Environment(\.dismiss) private var dismiss
    
    let addOrEdit: Bool //true represent add and false represent edit
    @Binding var questions: [Question]
    @Binding var questionOrigin: Question
    @Binding var files: Set<FileObject>
    
    @State private var errorMsg = ""
    @State private var showAlert = false
    
    @State private var file: FileContent?
    let meanings: [Meaning]
    @State private var bindedMeaningIndex: Int
    
    @State private var questionTextEnable: Bool = true
    @State private var questionText: String
    
    @State private var answer: ans_exp
    @State private var choices: [ans_exp]
    @State private var addChoice: Bool = false
    
    @State private var focus: Bool = false
    
    @State private var AICompletion: Bool = false
    let logoBackgroundSize = UIScreen.main.bounds.height * 0.055 * 0.6
    
    init(addOrEdit: Bool, questions: Binding<[Question]>, files: Binding<Set<FileObject>>, questionOrigin: Binding<Question>, question: Question, answer: String, meanings: [Meaning]) {
        self.addOrEdit = addOrEdit
        self._questions = questions
        self._questionOrigin = questionOrigin
        self._files = files
        let ans = ans_exp(answer: answer, explaination: "")
        let temp_question = question.questionData == Question.blankQuestion ? mcq_question(answer: ans) : mcq_question(questionData: question.questionData)
        self.questionText = question.questionString
        self.file = question.file?.file ?? nil
        self.answer = temp_question.answer
        self.choices = temp_question.choices
        self.meanings = meanings
        self.bindedMeaningIndex = question.bindedMeaning == 0 ? 0 : meanings.firstIndex(where: { $0.hashValue == question.bindedMeaning }) ?? 0
    }
    
    var body: some View {
        NavigationView {
            List {
                // Editor title
                Section {
                    ZStack(alignment: .leading) {
                        HStack {
                            Text("mcq editor")
                                .font(.title)
                                .foregroundStyle(Color.white)
                                .padding(.horizontal)
                                .background(
                                    RoundedRectangle(cornerRadius: 10)
                                        .fill(
                                            CustomColor.gradient(
                                                from: "eb3cce",
                                                to: "dd70b5",
                                                startPoint: .leading,
                                                endPoint: .topTrailing
                                            )
                                        )
                                )
                            Spacer()
                            HStack {
                                Image(systemName: "magnifyingglass")
                                Text("Preview")
                            }
                            .foregroundStyle(Color.blue)
                        }
                        NavigationLink(
                            destination: {
                                playQuestion(
                                    question: Question(
                                        bindedMeaning: bindedMeaningIndex,
                                        questionType: .mcq,
                                        questionData: mcq_question(
                                            answer: answer,
                                            choices: choices
                                        ).toQuestionData(),
                                        questionString: questionText,
                                        file: FileObject(fileType: Question.fileType(type: .mcq), file: file)
                                    )
                                )
                                .background(CustomColor.colorFromHex(hex: "f2f2f6"))
                            },
                            label: {
                                EmptyView()
                            })
                        .opacity(0.0)
                    }
                    
                }
                .listRowBackground(Color.clear)
                
                // meaning section
                Section {
                    NavigationLink(destination: {
                        meaningSelector(
                            meanings: meanings,
                            selectedIndex: $bindedMeaningIndex
                        )
                    }, label: {
                        HStack {
                            Image(systemName: "link.circle.fill")
                                .symbolRenderingMode(.multicolor)
                                .foregroundStyle(Color.blue)
                                .font(.system(size: logoBackgroundSize))
                            Text("Meaning")
                                .padding(.leading)
                            Spacer()
                            Text(meanings[bindedMeaningIndex].wordtype.rawValue)
                                .foregroundStyle(Color.blue)
                        }
                    })
                }
                
                // question section
                questionEditor(
                    logoBackgroundSize: logoBackgroundSize,
                    questionTextOrigin: $questionText,
                    questionText: questionText,
                    focusBinding: $focus
                )
                
                // image section
                ImageEditor(image: $file)
                
                Section {
                    Text("\(choices.count)")
                }
                
                // answer section
                Section {
                    HideChevronNavigationLink(destination: ans_expAdder(answers: $choices), content: {
                        Text("Add Choice")
                            .foregroundStyle(Color.blue)
                    })
                    .listRowSeparator(.hidden)
                    
                    HideChevronNavigationLink(destination: ans_expEditor(answerOrigin: $answer, answer: answer, editWordAllow: false), content: {
                        HStack {
                            Text(answer.id)
                                .foregroundStyle(Color.brown)
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundStyle(Color.green)
                            Spacer()
                            Text(answer.explaination.isEmpty ? "You can add explaination" : answer.explaination)
                                .foregroundStyle(Color.orange)
                                .frame(width: UIScreen.main.bounds.width * 0.4, height: .infinity)
                                .lineLimit(1)
                        }
                    })
                    
                    ForEach($choices, id: \.id) { $choice in
                        HideChevronNavigationLink(destination: ans_expEditor(answerOrigin: $choice, answer: choice), content: {
                            HStack {
                                Text(choice.id)
                                    .foregroundStyle(Color.brown)
                                Spacer()
                                Text(choice.explaination.isEmpty ? "You can add explaination" : choice.explaination)
                                    .foregroundStyle(Color.orange)
                                    .frame(width: UIScreen.main.bounds.width * 0.4, height: .infinity)
                                    .lineLimit(1)
                            }
                        })
                    }
                    .onDelete { indexSet in
                        choices.remove(atOffsets: indexSet)
                    }
                }
                
                Section {
                    HStack {
                        ZStack {
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color.blue)
                                .frame(width: logoBackgroundSize, height: logoBackgroundSize)
                            Image("robot")
                                .resizable()
                                .frame(width: logoBackgroundSize * 0.6, height: logoBackgroundSize * 0.6)
                        }
                        Text("AI Completion")
                            .padding(.horizontal)
                        
                        Spacer()
                        Toggle("ai completion", isOn: $AICompletion)
                            .labelsHidden()
                    }
                    .opacity(0.5)
                    .disabled(true)
                } footer: {
                    Text("This function will be available soon")
                }
            }
            .listSectionSpacing(20)
            .alert("", isPresented: $showAlert, actions: {}, message: {
                Text(errorMsg)
            })
            .toolbar {
                ToolbarItem(placement: .topBarLeading, content: {
                    Button(action: {
                        dismiss()
                    }, label: {
                        Text("Cancel")
                    })
                })
                ToolbarItem(placement: .topBarTrailing) {
                    Button(
                        action: {
                            let bindedMeaning = meanings[bindedMeaningIndex].hashValue
                            let questionData = mcq_question(
                                answer: answer,
                                choices: choices
                            ).toQuestionData()
                            
                            var qn = Question(
                                bindedMeaning: bindedMeaning,
                                questionType: .mcq,
                                questionData: questionData,
                                questionString: questionText
                            )
                            
                            if questions.contains(where: { $0.id == qn.id }) {
                                if !addOrEdit && qn == questionOrigin {
                                    dismiss()
                                    return
                                }
                                showAlert = true
                                errorMsg = "Duplicate question exists"
                                return
                            }
                            
                            // file validation
                            if let fileContent = file {
                                var fileObject: FileObject = FileObject(fileType: Question.fileType(type: .answer))
                                if questionOrigin.file == nil {
                                    // Set a new unique FileObject
                                    var i = 0
                                    while i < 3 {
                                        // The files should not have duplicate of fileObject
                                        if !files.contains(fileObject) {
                                            break
                                        }
                                        fileObject = FileObject(fileType: .image)
                                        i += 1
                                    }
                                    if i >= 3 {
                                        fatalError("too many duplicate FileObject error, files always contain new fileObject")
                                    }
                                } else {
                                    fileObject = questionOrigin.file!
                                }
                                fileObject.file = fileContent
                                
                                // Add fileObject to files, replacing any duplicate
                                files.update(with: fileObject)
                                qn.file = fileObject
                            }

                            if addOrEdit {
                                questions.append(qn)
                            } else {
                                questionOrigin = qn
                            }
                            
                            dismiss()
                        },
                        label: {
                    Text("Done")
                        .foregroundStyle(Color.green)
                })
                }
                ToolbarItemGroup(placement: .keyboard, content: {
                    Button(action: {
                        focus = false
                    }, label: {
                        Text("Done")
                    })
                    Spacer()
                })
            }
            .contentMargins(.top, 10)
        }
    }
}

fileprivate struct testView: View {
    @State private var showSheet = false
    let englishWord: EnglishWordTrans
    @State var qn = Question()
    @State var questions: [Question] = []
    @State var files: Set<FileObject> = []
    
    init() {
        let wordBaseConnector = WordBaseConnector()
        let targetTrans = wordBaseConnector.searchWords(searchLan: .English, translateLan: .Chinese, pref: "adhere") as! [EnglishWordTrans]
        self.englishWord = targetTrans[0]
    }
    
    var body: some View {
        Button(action: {
            showSheet = true
        }, label: {
            Text("tap")
        })
        .sheet(
            isPresented: $showSheet,
            content: {
                EWmcqEditor(
                    addOrEdit: true,
                    questions: $questions,
                    files: $files,
                    questionOrigin: $qn,
                    question: qn,
                    answer: englishWord.word,
                    meanings: englishWord.meaning

                )
            })
    }
}
#Preview {
    testView()
}
