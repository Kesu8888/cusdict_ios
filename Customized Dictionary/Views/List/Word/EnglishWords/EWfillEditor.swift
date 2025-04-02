//
//  EWfillEditor.swift
//  Customized Dictionary
//
//  Created by Fu Kaiqi on 2025/3/28.
//

import SwiftUI

struct EWfillEditor: View {
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
    
    @State private var answer: ans_exp
    @State private var coverage: Int
    @State private var coverArea: fillCoverArea
    
    @State private var focus: Bool = false
    
    let coverageValues = [1, 2, 3, 4]
    let logoBackgroundSize = UIScreen.main.bounds.height * 0.055 * 0.6
    let answerWidth = UIScreen.main.bounds.width * 0.3
    
    init(addOrEdit: Bool, questions: Binding<[Question]>, files: Binding<Set<FileObject>>, questionOrigin: Binding<Question>, question: Question, answer: String, meanings: [Meaning]) {
        self.addOrEdit = addOrEdit
        self._questions = questions
        self._questionOrigin = questionOrigin
        self._files = files
        self.file = question.file?.file ?? nil
        let ans = ans_exp(answer: answer, explaination: "")
        let temp_question = question.questionData == Question.blankQuestion ? fill_question(answer: ans) : fill_question(questionData: question.questionData)
        self.questionText = question.questionString
        self.answer = temp_question.answer
        self.coverage = temp_question.coverage
        self.coverArea = temp_question.coverArea
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
                            Text("fill editor")
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
                                        questionType: .fill,
                                        questionData: fill_question(
                                            answer: answer,
                                            coverage: coverage,
                                            coverArea: coverArea
                                        ).toQuestionData(),
                                        questionString: "",
                                        file: FileObject(fileType: Question.fileType(type: .fill), file: file)
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
                    HideChevronNavigationLink(destination: ans_expEditor(answerOrigin: $answer, answer: answer), content: {
                        HStack {
                            Text(answer.id)
                                .foregroundStyle(Color.brown)
                            Spacer()
                            Text(answer.explaination.isEmpty ? "You can add explaination" : answer.explaination)
                                .foregroundStyle(Color.orange)
                                .frame(width: UIScreen.main.bounds.width * 0.5)
        //                            .frame(width: UIScreen.main.bounds.width * 0.5, height: .infinity)
                        }
                    })
                }
                
                // coverage section
                Section {
                    HStack {
                        Image(systemName: "eye.slash.fill")
                            .font(.system(size: logoBackgroundSize * 0.8))
                            .foregroundStyle(Color.green)
                        
                        Text("coverage")
                            .padding(.horizontal)
                        
                        Spacer()
                        
                        Picker("", selection: $coverage, content: {
                            ForEach(coverageValues, id: \.self) {
                                Text("\($0 * 2)0%")
                            }
                        })
                        .labelsHidden()
                    }
                    HStack {
                        HStack(spacing: 1.6) {
                            let ellipseSize = logoBackgroundSize * 0.2
                            Ellipse()
                                .fill(coverArea == fillCoverArea.leading || coverArea == fillCoverArea.side ? Color.green : CustomColor.colorFromHex(hex: "d9d9d9"))
                                .frame(width: ellipseSize, height: ellipseSize)
                            Ellipse()
                                .fill(coverArea == fillCoverArea.leading || coverArea == fillCoverArea.random ? Color.green : CustomColor.colorFromHex(hex: "d9d9d9"))
                                .frame(width: ellipseSize, height: ellipseSize)
                            Ellipse()
                                .fill(coverArea == fillCoverArea.middle ? Color.green : CustomColor.colorFromHex(hex: "d9d9d9"))
                                .frame(width: ellipseSize, height: ellipseSize)
                            Ellipse()
                                .fill(coverArea == fillCoverArea.trailing || coverArea == fillCoverArea.random ? Color.green : CustomColor.colorFromHex(hex: "d9d9d9"))
                                .frame(width: ellipseSize, height: ellipseSize)
                            Ellipse()
                                .fill(coverArea == fillCoverArea.trailing || coverArea == fillCoverArea.side ? Color.green : CustomColor.colorFromHex(hex: "d9d9d9"))
                                .frame(width: ellipseSize, height: ellipseSize)
                        }
                        
                        Text("cover area")
                            .frame(height: 30)
                            .padding(.horizontal)
                        
                        Picker("", selection: $coverArea, content: {
                            ForEach(fillCoverArea.allCases, id: \.self) { area in
                                Text(area.rawValue).tag(area)
                            }
                        })
                        .frame(height: 30)
                    }
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
                ToolbarItem(placement: .topBarTrailing) {
                    Button(
                        action: {
                            let bindedMeaning = meanings[bindedMeaningIndex].hashValue
                            let questionData = fill_question(
                                answer: answer,
                                coverage: coverage,
                                coverArea: coverArea
                            ).toQuestionData()
                            
                            var qn = Question(
                                bindedMeaning: bindedMeaning,
                                questionType: .fill,
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
                EWfillEditor(
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
