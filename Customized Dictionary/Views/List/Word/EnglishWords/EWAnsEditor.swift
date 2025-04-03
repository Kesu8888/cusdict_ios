//
//  EnglishWordAnswerEditor.swift
//  Customized Dictionary
//
//  Created by Fu Kaiqi on 2025/3/28.
//

import SwiftUI

struct EWAnsEditor: View {
    @Environment(\.dismiss) private var dismiss
    let addOrEdit: Bool //true represent add and false represent edit
    @Binding var questions: [Question]
    @Binding var questionOrigin: Question
    @Binding var files: Set<FileObject>
    
    @State private var errorMsg = ""
    @State private var showAlert = false
    
    @State var file: FileContent?
    
    let meanings: [Meaning]
    @State private var bindedMeaningIndex: Int
    
    @State private var questionText: String
    @State private var answers: [ans_exp]
    @State private var addChoice: Bool = false
    
    @State private var focus: Bool = false
    
    let logoBackgroundSize = UIScreen.main.bounds.height * 0.055 * 0.6
    
    init(addOrEdit: Bool, questions: Binding<[Question]>, files: Binding<Set<FileObject>>, questionOrigin: Binding<Question>, question: Question, answer: String, meanings: [Meaning]) {
        self.addOrEdit = addOrEdit
        self._questions = questions
        self._questionOrigin = questionOrigin
        self._files = files
        self.file = question.file?.file ?? nil
        self.meanings = meanings
        let ans = ans_exp(answer: answer, explaination: "")
        let temp_question = question.questionData == Question.blankQuestion ? answer_question(answers: [ans]) : answer_question(questionData: question.questionData)
        self.answers = temp_question.answers
        self.questionText = question.questionString
        self.bindedMeaningIndex = question.bindedMeaning == 0 ? 0 : meanings.firstIndex(where: { $0.hashValue == question.bindedMeaning }) ?? 0
    }
    
    var body: some View {
        NavigationView {
            List {
                // Editor title
                Section {
                    ZStack(alignment: .leading) {
                        HStack {
                            Text("answer editor")
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
                                        questionType: .answer,
                                        questionData: answer_question(
                                            answers: answers
                                        ).toQuestionData(),
                                        questionString: "",
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
                
                // answer section
                Section {
                    HideChevronNavigationLink(
                        destination: ans_expAdder(answers: $answers),
                        content: {
                        Text("Add Answer")
                            .foregroundStyle(Color.blue)
                    })
                    .listRowSeparator(.hidden)
                    ForEach($answers, id: \.id) { $choice in
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
                        answers.remove(atOffsets: indexSet)
                    }
                } footer: {
                    Text("All the answers will be accept")
                }
            }
            .listSectionSpacing(20)
            .toolbar {
                ToolbarItem(placement: .topBarLeading, content: {
                    Button(action: {
                        dismiss()
                    }, label: {
                        Text("Cancel")
                    })
                })
                ToolbarItem(placement: .topBarTrailing, content: {
                    Button(action: {
                        let bindedMeaning = meanings[bindedMeaningIndex].hashValue
                        let questionData = answer_question(answers: answers).toQuestionData()
                        
                        let qn = Question(
                            bindedMeaning: bindedMeaning,
                            questionType: .answer,
                            questionData: questionData,
                            questionString: questionText
                        )
                        
                        if questions.contains(where: { $0 == qn }) {
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
                    }, label: {
                        Text("Done")
                            .foregroundStyle(Color.green)
                    })
                })
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
                EWAnsEditor(
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
