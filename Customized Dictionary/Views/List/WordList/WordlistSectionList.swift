//
//  WordlistDisplay.swift
//  Customized Dictionary
//
//  Created by Fu Kaiqi on 2025/1/25.
//

import SwiftUI

struct WordlistSectionList: View {
    let deleteItem: (WordList) -> Void
    let wordString: LanguageString
    let name: String
    @State var wl: [WordList]
    let displayMode: Bool
    
    var body: some View {
        if wl.isEmpty {
            EmptyView()
        } else {
            if displayMode {
                WordListSectionList
            }
        }
    }
    
    var WordListSectionList: some View {
        Section(
            header: Text(name)
                .textCase(nil)
                .font(CustomFont.SFPro(.regular, size: 20))
                .padding(.bottom, 6)
                .foregroundStyle(Color.black),
            content: {
                ForEach(wl, id: \.id) { w in
                WordlistColumn(
                    w: w,
                    wordString: wordString
                )
                .listRowInsets(EdgeInsets())
                .swipeActions(edge: .trailing, content: {
                    Button(role: .destructive)
                    {
                        wl.removeAll(where: {
                            $0.id == w.id
                        })
                        deleteItem(w)
                    } label: {
                        Label("Delete", systemImage: "trash")
                    }
                })
            }
        })
    }
}

fileprivate struct testView: View {
    @State var wlg: WordListGroup = WordListGroup(
        name: "English",
        list: [
            WordList(name: "ewe123", language: .english, passCount: 3, start: true),
            WordList(name: "ewe1231", language: .english, passCount: 3, start: false),
            WordList(name: "ewe1232", language: .english, passCount: 3, start: true),
            WordList(name: "ewe1233", language: .english, passCount: 3, start: false),
            WordList(name: "ewe1234", language: .english, passCount: 3, start: true),
        ]
    )
    @State var wl = [
        WordList(name: "ewe123", language: .english, passCount: 3, start: true),
        WordList(name: "ewe1231", language: .english, passCount: 3, start: false),
        WordList(name: "ewe1232", language: .english, passCount: 3, start: true),
        WordList(name: "ewe1233", language: .english, passCount: 3, start: false),
        WordList(name: "ewe1234", language: .english, passCount: 3, start: true),
    ]
    
    var body: some View {
        List {
            WordlistSectionList(
                deleteItem: delete_item(w:),
                wordString: ModelData().US.languagePackage.wordlistPage_wordCount,
                name: wlg.name,
                wl: wl,
                displayMode: true
            )
        }
    }
    func delete_item(w: WordList) {
        
    }
}
#Preview {
    testView()
}
