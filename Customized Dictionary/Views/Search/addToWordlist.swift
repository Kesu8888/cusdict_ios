//
//  addToWordlist.swift
//  Customized Dictionary
//
//  Created by Fu Kaiqi on 2025/3/13.
//

import SwiftUI

struct addToWordlist: View {
    @Environment(\.dismiss) private var dismiss
    let word: EnglishWord
    var modelData: ModelData
    @State private var lastAddFolder: Folder?
    @State private var lastAddWordList: WordList?
    
    @State private var displayFolders: Bool = true
    
    @State private var addLemma: Bool = true
    @State private var addLemmaInfo = false
    @Binding var errorMsg: String
    
    let rowHeight = UIScreen.main.bounds.height * 0.05
    
    var body: some View {
        VStack {
            CustomBackBar(content: {
                HStack {
                    Button(action: {
                        modelData.lastAddFolder = lastAddFolder
                        modelData.lastAddWordList = lastAddWordList
                        guard let result = modelData.WordList_AddWord(w: word) as? EnglishWord else {
                            fatalError("The result from modelData.WordList_AddWord is not an EnglishWord")
                        }
                        let failedTrans = result.transforms
                        if !failedTrans.isEmpty {
                            let failedWords = failedTrans.map { $0.word }.joined(separator: ", ")
                            errorMsg = "\(failedWords) already exist in the \(lastAddWordList!.name)"
                        }
                        
                        dismiss()
                    }, label: {
                        Text("Add")
                    })
                    .disabled(lastAddFolder == nil || lastAddWordList == nil)
                }
            })
            
            HStack {
                Button(action: {
                    withAnimation(.default) {
                        displayFolders = true
                    }
                }, label: {
                    Text(lastAddFolder?.id ?? "empty")
                        .foregroundStyle(displayFolders ? Color.white : Color.blue)
                        .padding(.vertical, 5)
                        .padding(.horizontal, 5)
                        .background(RoundedRectangle(cornerRadius: 5)
                            .fill(displayFolders ? Color.blue : Color.clear))
                })
                
                Image(systemName: "arrow.right")
                    .foregroundStyle(Color.blue)
                
                Button(action: {
                    withAnimation(.default) {
                        displayFolders = false
                    }
                }, label: {
                    Text(lastAddWordList?.name ?? "empty")
                        .foregroundStyle(displayFolders ? Color.blue : Color.white)
                        .padding(.vertical, 5)
                        .padding(.horizontal, 5)
                        .background(RoundedRectangle(cornerRadius: 5)
                            .fill(displayFolders ? Color.clear : Color.blue))
                })
                
            }
            .onAppear {
                self.lastAddFolder = modelData.lastAddFolder
                self.lastAddWordList = modelData.lastAddWordList
                if self.lastAddWordList != nil {
                    displayFolders = false
                }
                if self.word.lemma.isEmpty {
                    addLemma = false
                }
            }
            
            Spacer()
            
            List {
                Section {

                    HStack {
                        Text("add all transforms")
                            .opacity(word.lemma.isEmpty ? 0.4 : 1)
                        
                        Button(action: {
                            withAnimation(.easeInOut) {
                                addLemmaInfo.toggle()
                            }
                        }, label: {
                            Image(systemName: "info.circle")
                        })
                        .foregroundStyle(addLemmaInfo ? Color.brown : Color.blue)
                        .scaleEffect(addLemmaInfo ? 1.1 : 1)
                        .buttonStyle(.borderless)
                        
                        Spacer()
                        
                        Toggle("", isOn: $addLemma)
                        .labelsHidden()
                        .disabled(word.lemma.isEmpty)
                    }
                    
                }
                .contentMargins(.bottom, 0)
                
                Section {
                    if displayFolders {
                        ForEach(modelData.mainFolder) { folder in
                            HStack {
                                Button(action: {
                                    withAnimation(.default) {
                                        lastAddFolder = folder
                                        displayFolders = false
                                    }
                                }, label: {
                                    Text(folder.id)
                                })
                                Spacer()
                                if lastAddFolder == folder {
                                    Image(systemName: "checkmark")
                                        .foregroundStyle(Color.blue)
                                }
                            }
                        }
                    } else {
                        if lastAddFolder == nil || lastAddFolder!.lists.isEmpty  {
                            Color.clear
                        } else {
                            ForEach(lastAddFolder!.lists.indices, id: \.self) { index in
                                HStack {
                                    Button(action: {
                                        withAnimation(.default) {
                                            lastAddWordList = lastAddFolder!.lists[index]
                                        }
                                    }, label: {
                                        Text(lastAddFolder!.lists[index].name)
                                    })
                                    Spacer()
                                    if lastAddWordList == lastAddFolder!.lists[index] {
                                        Image(systemName: "checkmark")
                                            .foregroundStyle(Color.blue)
                                    }
                                }
                            }
                        }
                        
                    }
                }
                
                Section {
                    Color.clear
                }
                .listRowBackground(Color.clear)
            }
            .listSectionSpacing(rowHeight * 0.4)
            .contentMargins(.vertical, 10)
            Spacer()
        }
        .padding()
        .onChange(of: lastAddFolder, {
            withAnimation(.default) {
                lastAddWordList = nil
            }
        })
    }
}

fileprivate struct testView: View {
//struct testAddToWordList: View {
    var modelData = ModelData()
    let word: EnglishWord
    @State private var displayAdd = false
    @State private var errorMsg = ""
    
    init() {
        let wordBaseConnector = WordBaseConnector()
        let targetTrans = wordBaseConnector.searchWords(searchLan: .English, translateLan: .Chinese, pref: "te") as! [EnglishWordTrans]
        self.word = wordBaseConnector.en_SearchLemma(lan: .Chinese, targetTrans: targetTrans[0])
    }
    
    var body: some View {
        NavigationStack {
            VStack {
                Button(action: {
                    displayAdd = true
                }, label: {
                    Text("tap")
                })
                
                Text(errorMsg)
            }
        }
        .sheet(isPresented: $displayAdd, content: {
            addToWordlist(word: word, modelData: modelData, errorMsg: $errorMsg)
                .background(CustomColor.colorFromHex(hex: "f2f2f6"))
        })
    }
}

#Preview {
    testView()
}
