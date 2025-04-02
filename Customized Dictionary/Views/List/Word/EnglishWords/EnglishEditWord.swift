//
//  EnglishEditWord.swift
//  Customized Dictionary
//
//  Created by Fu Kaiqi on 2025/2/22.
//

import SwiftUI
import PhotosUI

enum editWordFunction {
    case delete
    case edit
    case add
}
struct EnglishEditWord: View {
    @Environment(\.dismiss) private var dismiss
    @State var w: EnglishWord
    var doneAction: (editWordFunction, EnglishWord) -> Void
    @State private var transforms: [EnglishWordTrans]
    @State private var currentTransWord: String
    @State private var addQuestion = false
    @State private var addQuestionType: QuestionType = .mcq
    
    @State private var meanings: [Meaning]
    @State private var addMeaning = false
    @State private var questions: [Question]
    @State private var files: Set<FileObject>
    
    @State private var deleteWord = false
    
    init(w: EnglishWord, action: @escaping (editWordFunction, EnglishWord) -> Void) {
        self.w = w
        self.doneAction = action
        self.transforms = w.transforms
        currentTransWord = w.transforms[0].word
        meanings = w.transforms[0].meaning
        questions = w.transforms[0].question
        files = w.transforms[0].files
    }
    
    var body: some View {
        NavigationStack {
            VStack {
                ForEach($transforms, id: \.word) { $trans in
                    if trans.word == currentTransWord {
                        List {
                            Section {
                                HStack {
                                    Spacer()
                                    Text(trans.word)
                                        .foregroundStyle(Color.white)
                                        .font(.title2)
                                        .padding(.horizontal, 20)
                                        .padding(.vertical, 8)
                                        .background(
                                            CustomColor.gradient(
                                                colorFrom: Color.blue,
                                                colorTo: Color.gray,
                                                startPoint: .topLeading,
                                                endPoint: .bottomTrailing
                                            )
                                        )
                                        .cornerRadius(10)
                                    Spacer()
                                        .frame(width: 50)
                                    ZStack {
                                        Image(systemName: "app.badge.checkmark")
                                            .font(.largeTitle)
                                            .foregroundStyle(Color.green)
                                            .offset(y: 3)
                                        Text("\(trans.passCount)")
                                            .foregroundStyle(Color.green)
                                    }
                                    Spacer()
                                }
                            }
                            .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
                            .listRowSpacing(0)
                            .listRowBackground(Color.clear)
                            .listRowSeparator(.hidden)
                            
                            // meaning section
                            Section {
                                // translation Column
                                ForEach(meanings, id: \.id) { meaning in
                                    HStack {
                                        Text(meaning.wordtype.rawValue)
                                            .foregroundStyle(Color.brown)
                                            .bold()
                                        
                                        Text(meaning.translation)
                                            .lineLimit(1)
                                        
                                        Spacer()
                                        
                                        Image(systemName: "checkmark.seal.text.page")
                                            .foregroundStyle(Color.brown)
                                        Text("\(questions.filter { $0.bindedMeaning == meaning.hashValue }.count)")
                                            .foregroundStyle(Color.blue)
                                    }
                                    .padding(.horizontal, 20)
                                }
                                .onDelete { indexSet in
                                    if let index = indexSet.first {
                                        let meaning = meanings[index]
                                        questions.removeAll(where: { $0.bindedMeaning == meaning.hashValue })
                                    }
                                    meanings.remove(atOffsets: indexSet)
                                }
                            } header: {
                                Text("meanings")
                                    .textCase(nil)
                            }
                            .onChange(of: meanings, {
                                trans.meaning = meanings
                            })
                            .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
                            .listSectionSpacing(0)
                            
                            Section {
                                HStack {
                                    Image(systemName: "plus.circle.fill")
                                        .symbolRenderingMode(.palette)
                                        .font(.system(size: 24))
                                        .foregroundStyle(Color.white, Color.blue)
                                    
                                    Text("New Meaning")
                                        .foregroundStyle(Color.blue)
                                    Spacer()
                                }
                                .onTapGesture(perform: {
                                    addMeaning = true
                                })
                            }
                            .navigationDestination(
                                isPresented: $addMeaning,
                                destination: {
                                    MeaningAdder(word: trans.word, meanings: $meanings)
                                })
                            .listSectionSpacing(0)
                            .listRowBackground(Color.clear)
                            
                            // Question part
                            Section {
                                UIMenuView(
                                    questionTypes: QuestionType.allCases,
                                    onSelect: { type in
                                        addQuestionType = type
                                        addQuestion = true
                                    }
                                )
                                .listRowSeparator(.hidden)
                                ForEach($questions, id: \.id) { $qn in
                                    ZStack {
                                        Button("") {}
                                        
                                        HideChevronNavigationLink(destination: EnglishWordQuestionEditor(
                                            answer: trans.word,
                                            meanings: meanings,
                                            questionType: qn.questionType,
                                            addOrEdit: false,
                                            questions: $questions,
                                            questionOrigin: $qn,
                                            files: $files
                                        ), content: {
                                            if qn.questionString.isEmpty {
                                                Text("Blank Question")
                                                    .foregroundStyle(Color.red)
                                                    .lineLimit(1)
                                                    .padding(.horizontal, 20)
                                            } else {
                                                Text(qn.questionString)
                                                    .lineLimit(1)
                                                    .padding(.horizontal, 20)
                                            }
                                        })
                                    }
                                }
                                .onDelete { indexSet in
                                    questions.remove(atOffsets: indexSet)
                                }
                            } header: {
                                Text("Question")
                                    .textCase(nil)
                            }
                            .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
                            .navigationDestination(
                                isPresented: $addQuestion,
                                destination: {
                                    EnglishWordQuestionEditor(
                                        answer: trans.word,
                                        meanings: meanings,
                                        questionType: addQuestionType,
                                        addOrEdit: true,
                                        questions: $questions,
                                        questionOrigin: Binding.constant(
                                            Question(
                                                bindedMeaning: 0,
                                                questionType: .mcq,
                                                questionData: Question.blankQuestion,
                                                questionString: ""
                                            )
                                        ),
                                        files: $files
                                    )
                                })
                            .onChange(of: questions, {
                                trans.question = questions
                            })
                        }
                        .environment(\.editMode, Binding.constant(EditMode.active))
                        .listSectionSpacing(20)
                        .contentMargins(.top, 10)
                        .transition(.scale)
                    }
                }
            }
            .alert("", isPresented: $deleteWord, actions: {
                Button("Delete") {
                    dismiss()
                }
                Button("Cancel") {
                    deleteWord = false
                }
            }, message: {
                Text("This Lemma contains no transforms, the Lemma word will be deleted after return")
            })
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
                        let removedIndex = transforms.firstIndex(where: { $0.word == currentTransWord }) ?? 0
                        var index = 0
                        if removedIndex == (transforms.count - 1) {
                            index = removedIndex - 1
                        } else {
                            index = removedIndex + 1
                        }
                        withAnimation {
                            if transforms.count == 1 {
                                currentTransWord = ""
                            } else {
                                currentTransWord = transforms[index].word
                            }
                        }
                        
                        transforms.remove(at: removedIndex)
                    }, label: {
                        Image(systemName: "trash")
                            .foregroundStyle(Color.red.opacity(currentTransWord.isEmpty ? 0.3 : 1))
                    })
                    .disabled(currentTransWord.isEmpty)
                })
                ToolbarItem(placement: .topBarTrailing, content: {
                    Button(action: {
                        
                    }, label: {
                        Image(systemName: "plus")
                            .foregroundStyle(Color.blue)
                    })
                })
                ToolbarItem(placement: .topBarTrailing, content: {
                    Button(action: {
                        if transforms.isEmpty {
                            deleteWord = true
                            return
                        }
                    }, label: {
                        Text("Done")
                            .foregroundStyle(Color.green)
                    })
                })
            }
            .safeAreaInset(edge: .bottom, content: {
                ScrollableSegmentedPicker(
                    options: transforms.map { $0.word },
                    currentTrans: $currentTransWord,
                    animatedCurrentTrans: currentTransWord
                )
                .padding(.horizontal, 20)
            })
            .onChange(of: currentTransWord, {
                let currentTransIndex = transforms.firstIndex(where: { $0.word == currentTransWord }) ?? -1
                if currentTransIndex >= 0 {
                    meanings = transforms[currentTransIndex].meaning
                    questions = transforms[currentTransIndex].question
                    files = transforms[currentTransIndex].files
                }
            })
        }
    }
}

fileprivate struct ScrollableSegmentedPicker: View {
    let options: [String]
    @Binding var currentTrans: String
    @State var animatedCurrentTrans: String
    let rowHeight = UIScreen.main.bounds.height * 0.05
    @Namespace private var ns
    @Environment(\.colorScheme) private var colorScheme
        
    var body: some View {
        let backgroundColor = colorScheme == .dark ? CustomColor.colorFromHex(hex: "2E2E2E") : CustomColor.colorFromHex(hex: "e2e2e2")
        let backgroundActiveColor = colorScheme == .dark ? CustomColor.colorFromHex(hex: "606060") : CustomColor.colorFromHex(hex: "ffffff")
        let foregroundColor = Color.primary
        let foregroundActiveColor = Color.primary
        let groupHeight: CGFloat = rowHeight * 0.8
        
        GeometryReader { proxy in
            let groupWidth: CGFloat = proxy.size.width / 4
            let extraPadding = options.count < 4 ? groupWidth * CGFloat(4 - options.count) / 2.0 : 0
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 0) {
                    ForEach(options, id: \.self) { option in
                        Group {
                            if animatedCurrentTrans == option {
                                ZStack {
                                    RoundedRectangle(cornerRadius: 9, style: .continuous).fill(backgroundActiveColor).frame(height: .infinity)
                                        .matchedGeometryEffect(id: "anim_pill", in: ns)
                                    
                                    Text(option)
                                        .font(CustomFont.SFPro(.regular, size: groupHeight * 0.4))
                                        .layoutPriority(1)
                                        .padding(0)
                                        .foregroundStyle(foregroundActiveColor)
                                }
                            } else {
                                Button(action: {
                                    withAnimation(.snappy) {
                                        animatedCurrentTrans = option
                                    }
                                }, label: {
                                    Text(option)
                                        .font(CustomFont.SFPro(.regular, size: groupHeight * 0.4))
                                        .foregroundStyle(foregroundColor)
                                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                                })
                            }
                        }
                        .frame(width: groupWidth, height: groupHeight)
                    }
                }
                .onChange(of: animatedCurrentTrans, {
                    currentTrans = animatedCurrentTrans
                })
                .onChange(of: currentTrans, {
                    withAnimation(.snappy) {
                        animatedCurrentTrans = currentTrans
                    }
                })
                .frame(height: groupHeight)
                .background(backgroundColor, in: RoundedRectangle(cornerRadius: 9, style: .continuous))
                .padding(.horizontal, extraPadding)
            }
            .scrollDisabled(options.count < 5)
            .frame(height: groupHeight)
            .scrollTargetLayout()
        }
        .frame(height: groupHeight)
    }
}

fileprivate struct UIMenuView: UIViewRepresentable {
    let questionTypes: [QuestionType]
    let onSelect: (QuestionType) -> Void

    func makeUIView(context: Context) -> UIButton {
        // Create a UIButton to attach the UIMenu
        let button = UIButton(type: .system)

        var configuration = UIButton.Configuration.plain()
        configuration.title = "Add Question"
        configuration.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 20, bottom: 0, trailing: 0) // Add padding to the leading
        configuration.baseForegroundColor = .systemBlue // Set the text color
        button.configuration = configuration
        button.contentHorizontalAlignment = .leading
        
        // Create the UIMenu with buttons for each QuestionType
        let menu = UIMenu(title: "", children: questionTypes.map { type in
            UIAction(title: type.rawValue, handler: { _ in
                onSelect(type) // Call the onSelect closure when a menu item is tapped
            })
        })

        // Attach the menu to the button
        button.menu = menu
        button.showsMenuAsPrimaryAction = true // Show the menu when the button is tapped

        return button
    }

    func updateUIView(_ uiView: UIButton, context: Context) {
        // No updates needed for now
    }
}

fileprivate struct MeaningEditor: View {
    @Binding var bindedMeaning: Meaning
    var meanings: [Meaning]
    @State var meaning: Meaning
    @Environment(\.dismiss) private var dismiss
    @State private var errorMsg = ""
    
    var body: some View {
        NavigationView {
            List {
                Picker("edit Wordtype", selection: $meaning.wordtype, content: {
                    ForEach(EnglishWordtype.allCases) { type in
                        Text(type.rawValue)
                            .tag(type)
                    }
                })
                TextField("Edit translation", text: $meaning.translation)
            }
            .toolbar {
                ToolbarItem(placement: .topBarLeading, content: {
                    Button(action: {
                        dismiss()
                    }, label: {
                        Text("Cancel")
                            .foregroundStyle(Color.red)
                    })
                })
                ToolbarItem(placement: .topBarTrailing, content: {
                    Button(action: {
                        if ViewHelper.questionText_validation(text: meaning.translation) {
                            errorMsg = "The translation contains invalid characters ^, |, ~, #, §"
                            return
                        }
                        if meanings.contains(where: { $0 == meaning }) {
                            errorMsg = "Duplicate meaning exist"
                            return
                        }
                        bindedMeaning = meaning
                        dismiss()
                    }, label: {
                        Text("Done")
                    })
                })
            }
        }
    }
}

fileprivate struct MeaningAdder: View {
    let word: String
    @Binding var meanings: [Meaning]
    @State private var meaning: Meaning = Meaning(wordtype: EnglishWordtype.verb, translation: "", phonetic: "")
    @Environment(\.dismiss) private var dismiss
    @State private var errorMsg = ""
    
    var body: some View {
        List {
            Section {
                HStack {
                    Spacer()
                    Text(word)
                        .font(.title2)
                        .foregroundStyle(Color.gray)
                    Spacer()
                }
            }
            .listRowBackground(Color.clear)
            .listSectionSpacing(10)
            
            Section {
                Picker("edit Wordtype", selection: $meaning.wordtype, content: {
                    ForEach(EnglishWordtype.allCases) { type in
                        Text(type.rawValue)
                            .tag(type)
                    }
                })
                .foregroundStyle(Color.blue)
                
                TextField("Edit translation", text: $meaning.translation)
                    .foregroundStyle(Color.brown)
            }
            .listSectionSpacing(0)
            
            Text(errorMsg)
                .foregroundStyle(Color.red)
                .listRowBackground(Color.clear)
        }
        .navigationBarBackButtonHidden(true)
        .contentMargins(.vertical, 0)
        .toolbar {
            ToolbarItem(placement: .topBarLeading, content: {
                Button(action: {
                    dismiss()
                }, label: {
                    Text("Cancel")
                        .foregroundStyle(Color.red)
                })
            })
            ToolbarItem(placement: .topBarTrailing, content: {
                Button(action: {
                    if ViewHelper.questionText_validation(text: meaning.translation) {
                        errorMsg = "The translation contains invalid characters ^, |, ~, #, §"
                        return
                    }
                    if meanings.contains(where: { $0 == meaning }) {
                        errorMsg = "Duplicate meaning exist"
                        return
                    }
                    meanings.append(meaning)
                    dismiss()
                }, label: {
                    Text("Done")
                })
            })
        }
    }
}

//fileprivate struct testView: View {
struct testEditWordView: View {
    @State private var showSheet = false
    let englishWord: EnglishWord
    
    init() {
        let wordBaseConnector = WordBaseConnector()
        let targetTrans = wordBaseConnector.searchWords(searchLan: .English, translateLan: .Chinese, pref: "adhere") as! [EnglishWordTrans]
        self.englishWord = wordBaseConnector.en_SearchLemma(lan: .Chinese, targetTrans: targetTrans[0])
    }
    
    var body: some View {
        Button("showSheet") {
            showSheet.toggle()
        }
        .sheet(
            isPresented: $showSheet,
            content: {
                EnglishEditWord(
                    w: englishWord,
                    action: editEnglishWord(function:w:)
                )
                .presentationBackground(CustomColor.colorFromHex(hex: "f2f2f6"))
                .onAppear {
                    setWindowBackgroundColor(UIColor.black)
                }
        })
    }
    
    private func setWindowBackgroundColor(_ color: UIColor) {
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first {
            window.backgroundColor = color
        }
    }
    
    private func editEnglishWord(function: editWordFunction, w: EnglishWord) {
        
    }
}

#Preview {
//    testView()
    testEditWordView()
}
