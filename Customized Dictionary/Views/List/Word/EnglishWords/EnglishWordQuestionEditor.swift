//
//  EnglishWordQuestionEditor.swift
//  Customized Dictionary
//
//  Created by Fu Kaiqi on 2025/2/26.
//

import SwiftUI
import PhotosUI

struct EnglishWordQuestionEditor: View {
    let answer: String
    let meanings: [Meaning]
    let questionType: QuestionType
    
    let addOrEdit: Bool //true represent add and false represent edit
    @Binding var questions: [Question]
    @Binding var questionOrigin: Question
    @Binding var files: Set<FileObject>
    
    @State private var doneErrorMsg: String = ""
    var body: some View {
        switch questionType {
        case .mcq:
            EWmcqEditor(
                addOrEdit: addOrEdit,
                questions: $questions,
                files: $files,
                questionOrigin: $questionOrigin,
                question: questionOrigin,
                answer: answer,
                meanings: meanings
            )
            .navigationBarBackButtonHidden(true)
        case .answer:
            EWAnsEditor(
                addOrEdit: addOrEdit,
                questions: $questions,
                files: $files,
                questionOrigin: $questionOrigin,
                question: questionOrigin,
                answer: answer,
                meanings: meanings
            )
            .navigationBarBackButtonHidden(true)
        case .fill:
            EWfillEditor(
                addOrEdit: addOrEdit,
                questions: $questions,
                files: $files,
                questionOrigin: $questionOrigin,
                question: questionOrigin,
                answer: answer,
                meanings: meanings
            )
            .navigationBarBackButtonHidden(true)
        }
    }
}

struct meaningSelector: View {
    let meanings: [Meaning]
    @Binding var selectedIndex: Int
    let rowWidth = UIScreen.main.bounds.width * 0.15
    
    var body: some View {
        List {
            ForEach(meanings.indices, id: \.self) { index in
                Button(action: {
                    selectedIndex = index
                }, label: {
                    HStack(spacing: 10) {
                        Text("\(meanings[index].wordtype.rawValue)")
                            .foregroundStyle(Color.white)
                            .padding(.vertical, 5)
                            .padding(.horizontal, 7)
                            .background(RoundedRectangle(cornerRadius: 8)
                                .fill(Color.brown))
                            .frame(width: rowWidth, alignment: .leading)
                        
                        Text(meanings[index].translation)
                            .foregroundStyle(Color.blue)
                        
                        Spacer()
                        
                        Image(systemName: "checkmark")
                            .foregroundStyle(selectedIndex == index ? Color.blue : Color.clear)
                    }
                    .foregroundStyle(Color.black)
                })
            }
        }
        .contentMargins(.top, 0)
    }
}

struct questionEditor: View {
    let logoBackgroundSize: CGFloat
    @Binding var questionTextOrigin: String
    @State var questionText: String
    
    @Binding var focusBinding: Bool
    @FocusState var focus: Bool
    @State private var error: Bool = false
    @State private var errorPopover: Bool = false
    
    var body: some View {
        // question section
        Section {
            HStack {
                Image(systemName: "questionmark.square.fill")
                    .font(.system(size: logoBackgroundSize))
                    .symbolRenderingMode(.multicolor)
                Text("Question")
                    .padding(.horizontal)
                Spacer()
                if error {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(Color.red)
                        .onTapGesture(perform: {
                            withAnimation {
                                errorPopover.toggle()
                            }
                        })
                    .popover(isPresented: $errorPopover, content: {
                        Text("Text contains |, #, §, ^, ~")
                            .padding(.horizontal)
                            .foregroundStyle(Color.red)
                            .presentationCompactAdaptation(.popover)
                    })
                }
            }
            .listRowSeparator(.hidden)
            
            TextField("Edit your question", text: $questionText, axis: .vertical)
                .focused($focus)
                .foregroundStyle(error ? Color.red : Color.black)
                .lineLimit(1...3)
                .onChange(of: questionText, {
                    withAnimation {
                        if ViewHelper.questionText_validation(text: questionText) {
                            error = true
                        } else {
                            error = false
                            questionTextOrigin = questionText
                        }
                    }
                })

        }
        .onChange(of: focus, {
            focusBinding = focus
        })
        .onChange(of: focusBinding, {
            focus = focusBinding
        })
    }
}

struct ImageEditor: View {
    @Binding var image: FileContent?
    @Environment(\.defaultMinListRowHeight) private var rowHeight
    @StateObject private var imagePicker = ImagePicker()
    
    var body: some View {
        Section {
            HStack(spacing: 0) {
                PhotosPicker(selection: $imagePicker.imageSelection, label: {
                    Text(imagePicker.image == nil ? "Add Image" : "")
                        .foregroundStyle(Color.blue)
                })

                if imagePicker.image != nil {
                    Image(uiImage: imagePicker.image!)
                        .resizable()
                        .frame(width: rowHeight * 0.6 * 1.3, height: rowHeight * 0.6)
                        .scaledToFit()
                        .cornerRadius(5)
                    Spacer()
                    Text("Cancel")
                        .foregroundStyle(Color.red)
                        .onTapGesture(perform: {
                            withAnimation(.default) {
                                imagePicker.image = nil
                                imagePicker.imageSelection = nil
                            }
                        })
                }
            }
            .onChange(of: imagePicker.image, { oldValue, newValue in
                withAnimation(.default) {
                    if newValue == nil {
                        image = nil
                    } else {
                        image = FileContent.image(imagePicker.image!)
                    }
                }
            })
            .onAppear(perform: {
                if self.image == nil {
                    imagePicker.image = nil
                }
                if let fileContent = image {
                    switch fileContent {
                    case .image(let uiImage):
                        imagePicker.image = uiImage
                    }
                }
            })
        }
    }
}

#Preview {
//    testEnglishWordQuestionEditor()
//    testView()
}
