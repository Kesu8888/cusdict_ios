//
//  en_cn_ResultWord.swift
//  Customized Dictionary
//
//  Created by Fu Kaiqi on 2025/2/2.
//

import SwiftUI

struct en_cn_ResultWord: View {
    let word: EnglishWord
    private let targetWord: EnglishWordTrans
    @ObservedObject var modelData: ModelData
    
    @State private var playPronounciation = false
    @State private var selectedMeaning: Set<Int> = []
    @State private var showErrorText: Bool = false
    @State private var addWord: Bool = false
    @State private var errorMsg: String = ""
    @Environment(\.presentationMode) private var presentationMode
    
    let rowHeight = UIScreen.main.bounds.height * 0.05
    
    init(word: EnglishWord, modelData: ModelData) {
        self.word = word
        self.targetWord = word.targetTrans!
        self.modelData = modelData
        self._selectedMeaning = State(initialValue: Set(0..<word.targetTrans!.meaning.count))
    }
    
    var body: some View {
        ZStack(alignment: .center) {
            VStack(alignment: .center, spacing: rowHeight * 0.2) {
                HStack {
                    Text(word.targetTrans!.word)
                        .font(CustomFont.SFPro_Rounded(.regular, size: rowHeight * 0.8))
                    Spacer()
                }
                
                HStack {
                    Text("/\(targetWord.phonetic)/")
                        .font(CustomFont.SFPro_Rounded(.regular, size: rowHeight * 0.5))
                        .foregroundStyle(Color.blue)
                    Button(action: {
                        playPronounciation.toggle()
                    }, label: {
                        Image(systemName: "speaker.wave.3.fill")
                            .symbolEffect(.variableColor.iterative, options: .repeat(2), value: playPronounciation)
                    })
                    Spacer()
                }
                
                ForEach(targetWord.meaning.indices, id: \.self) { i in
                    let insideCircleDiameter = rowHeight * 0.4
                    let interval = rowHeight * 0.5
                    let outsideCircleDiameter = rowHeight * 0.6
                    let mean = targetWord.meaning[i]
                    HStack {
                        Button(action: {
                            withAnimation(.default) {
                                if selectedMeaning.contains(i) {
                                    selectedMeaning.remove(i)
                                } else {
                                    selectedMeaning.insert(i)
                                }
                            }
                        }, label: {
                            ZStack {
                                Circle()
                                    .fill(Color.red)
                                    .frame(width: outsideCircleDiameter, height: outsideCircleDiameter)
                                Circle()
                                    .fill(Color.white)
                                    .frame(width: interval, height: interval)
                                
                                if selectedMeaning.contains(i) {
                                    Circle()
                                        .fill(Color.red)
                                        .frame(width: insideCircleDiameter, height: insideCircleDiameter)
                                }
                            }
                        })
                        
                        Text(mean.wordtype.rawValue)
                            .foregroundStyle(Color.white)
                            .font(.system(size: rowHeight * 0.5))
                            .padding(.horizontal, rowHeight * 0.15)
                            .background(RoundedRectangle(cornerRadius: 5)
                                .fill(Color.green))
                        
                        if !mean.phonetic.isEmpty {
                            Button(action: {
                                
                            }, label: {
                                Image(systemName: "speaker.wave.3")
                            })
                        }
                        
                        Text(mean.translation)
                        
                        Spacer()
                    }
                    .padding(.vertical, rowHeight * 0.1)
                }
                
                Spacer()
            }
            .padding()
        }
        .toolbar {
            ToolbarItem(placement: .topBarLeading, content: {
                HStack {
                    
                }
                .frame(width: 200, height: 30)
                .background(RoundedRectangle(cornerRadius: 8)
                    .fill(Color.gray))
            })
            ToolbarItem(placement: .topBarTrailing, content: {
                Button(action: {
                    
                }, label: {
                    Image(systemName: "info.circle")
                })
            })
            ToolbarItem(placement: .topBarTrailing, content: {
                Button(action: {
                    addWord = true
                }, label: {
                    Image(systemName: "plus")
                })
            })
        }
        .sheet(
            isPresented: $addWord,
            content: {
                addToWordlist(
                    word: word,
                    modelData: modelData,
                    errorMsg: $errorMsg
                )
                .background(CustomColor.colorFromHex(hex: "f2f2f6"))
        })
    }
}

fileprivate struct testView: View {
//struct test_en_cn_ResultWord: View {
    var modelData = ModelData()
    var word: EnglishWord
    
    init() {
        let wb = WordBaseConnector()
        let targetTrans = wb.searchWords(searchLan: .English, translateLan: .Chinese, pref: "te") as! [EnglishWordTrans]
        self.word = wb.en_SearchLemma(lan: .Chinese, targetTrans: targetTrans[0])
    }
    
    var body: some View {
        NavigationView(content: {
            VStack {
                NavigationLink(
                    destination: {
                        en_cn_ResultWord(word: word, modelData: modelData)
                            .background(CustomColor.colorFromHex(hex: "f2f2f6"))
                    }, label: {
                        Text("tap")
                    }
                )
            }
            
        })
    }
}
#Preview {
//    test_en_cn_ResultWord()
    testView()
}
