//
//  EnglishWordPage.swift
//  Customized Dictionary
//
//  Created by Fu Kaiqi on 2025/2/13.
//

import SwiftUI

struct EnglishWordPage: View {
    var modelData: ModelData
    @State private var allWords: [EnglishWord]
    @State private var showAllWords = false
    private var wordRange: WordRange
    @State private var ranges: [String]
    @State private var wordsArray: [[EnglishWord]]
    @State private var currentRange: Int
    
    @State private var words: [EnglishWord]
    @State private var showWord = false
    // This word is used by EnglishEditWord and will be set to the word to be edited when pass to EnglishEditWord
    @State private var editingWord: EnglishWord = EnglishWord(lemma: "", lemmaVar: 0, range: "", transforms: [])
    
    init(modelData: ModelData) {
        self.modelData = modelData
        let wordRange = modelData.currentSelectedWordlist.wordRange
        self.wordRange = wordRange
        let ranges = wordRange.ranges()
        self.ranges = ranges
        let currentRange = ranges.firstIndex(of: wordRange.getCurRange()) ?? 0
        self.currentRange = currentRange
        var words = Array(repeating: [EnglishWord](), count: ranges.count)
        
        for (key, value) in modelData.currentSelectedWords {
            if let index = ranges.firstIndex(of: key) {
                words[index].append(contentsOf: value.compactMap { $0 as? EnglishWord })
            }
        }
        
        self.wordsArray = words
        self.allWords = words.flatMap { $0 }
        self.words = words[currentRange]
    }
    
    var body: some View {
        List {
            Section {
                Text("The count of the allWords \(allWords.count)")
                Text("The count of the allWords \(wordsArray[currentRange].count)")
                Text("The count of the words \(words.count)")
            }
            
            Section {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack {
                        ForEach(ranges.indices, id: \.self) { index in
                            Button(action: {
                                withAnimation {
                                    currentRange = index
                                }
                            }, label: {
                                Text(ranges[index])
                                    .foregroundStyle(Color.white)
                                    .font(.headline)
                                    .padding(.horizontal, 5)
                                    .padding(.vertical, 3)
                                    .background(currentRange == index ? Color.green : Color.teal)
                                    .cornerRadius(5)
                            })
                            .buttonStyle(.borderless)
                        }
                    }
                }
            }
            .listRowBackground(Color.clear)
            .onChange(of: currentRange, {
                words = wordsArray[currentRange]
            })

            Section {
                if showAllWords {
//                    ForEach()
                } else {
                    Text("\(words.count)")
                    ForEach(words) { w in
                        if w.lemma.last == "+" {
                            Text("\(w.lemma)")
                        } else {
                            HStack {
                                Text("\(w.lemma)")
                                Spacer()
                                Image(systemName: "square.2.layers.3d")
                                Text("\(w.transforms.count)")
                            }
                            .foregroundStyle(Color.brown)
                        }
                    }
                    .onDelete {indexSet in
                        editEnglishWord(function: .delete, w: words[indexSet.first!])
                    }
                }
            }
        }
        .listSectionSpacing(15)
        .contentMargins(.vertical, 10)
        .sheet(isPresented: $showWord, content: {
            EnglishEditWord(w: editingWord, action: editEnglishWord(function:w:))
                .withDismissButton(withScroll: true)
                .presentationBackground(CustomColor.colorFromHex(hex: "f2f2f6"))
                .onAppear {
                    setWindowBackgroundCOlor(UIColor.black)
                }
        })
    }
    
    // function(.delete): delete the word w from words, allWords, wordsArray, Database
    // function(.edit): edit the word w in words, allWords, Database
    // function(.add): add the word w in words, allWords, Database
    private func editEnglishWord(function: editWordFunction, w: EnglishWord) {
        switch function {
        case .delete:
            // Remove from database
            modelData.WordList_DeleteWord(w: w)
            
            // Remove the word from `words` and `wordsArray` at the current range
            if let wordIndex = words.firstIndex(where: { $0.id == w.id }) {
                words.remove(at: wordIndex)
                wordsArray[currentRange].remove(at: wordIndex)
            }
            
            // Remove the word from `allWords`
            allWords.removeAll { $0.id == w.id }
        case .edit:
            //Edit word in database
            modelData.WordList_EditWord(w: w)
            
            // Replace the word in `words`
            if let wordIndex = words.firstIndex(where: { $0.id == w.id }) {
                words[wordIndex] = w
                
                // Replace the word in `wordsArray` at the current range
                wordsArray[currentRange][wordIndex] = w
            }
            
            // Replace the word in `allWords`
            if let index = allWords.firstIndex(where: { $0.id == w.id }) {
                allWords[index] = w
            }
        case .add:
            // It got some problem, because the new word might not be added to the words
            let newWord = modelData.WordList_AddWord(w: w) as! EnglishWord
            
            // Append the word to `allWords`
            allWords.append(newWord)
            
            // Append the word to `wordsArray` at the index corresponding to `w.range`
            if let rangeIndex = ranges.firstIndex(of: w.range) {
                wordsArray[rangeIndex].append(newWord)
            }
            
            // Append the word to `words`
            words.append(w)
        }
    }
}

private func setWindowBackgroundCOlor(_ color: UIColor) {
    if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
       let window = windowScene.windows.first {
        window.backgroundColor = color
    }
}

struct testEnglishWordPage: View {
//fileprivate struct testView: View {
    var modelData = ModelData()
    
    var body: some View {
//        NavigationStack {
//            NavigationLink(
//                destination: {
//                    EnglishWordPage(modelData: modelData)
//                },
//                label: {
//                Text("tap")
//            })
//        }
        EnglishWordPage(modelData: modelData)
    }
}
#Preview {
//    testView()
    testEnglishWordPage()
}
