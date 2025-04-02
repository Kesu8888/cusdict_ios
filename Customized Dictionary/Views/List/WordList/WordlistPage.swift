//
//  WordlistPage.swift
//  Customized Dictionary
//
//  Created by Fu Kaiqi on 2024/12/30.
//

import SwiftUI

class WordListGroup: Identifiable {
    let name: String
    var list: [WordList]
    
    init(name: String, list: [WordList]) {
        self.name = name
        self.list = list
    }
}

struct WordlistPage: View {
    @EnvironmentObject var modelData: ModelData
    @State private var sort1 = 0
    @State private var sortDirection = false
    @State private var groupOption: Int = 1
    @State private var sortedWordLists: [WordListGroup] = []
    @State private var displayMode: Bool = true //true for list view, false for gallery view
    @Environment(\.presentationMode) var presentationMode
    @Binding var showTabBar: Bool
    
    @State private var showColumn2: Bool = false
    @State private var showColumn3: Bool = false
    @State private var showContent: Bool = false
    
    var body: some View {
        ZStack(alignment: .top) {
            if showContent {
                Color.black.opacity(0.001)
                    .edgesIgnoringSafeArea(.all)
                    .onTapGesture {
                        showContent = false
                        showColumn2 = false
                        showColumn3 = false
                    }
                    .zIndex(10)
            }
            
            // navigation bar
            HStack {
                Button(action: {
                    showTabBar = true
                    presentationMode.wrappedValue.dismiss()
                }, label: {
                    HStack(spacing: 6) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 21))
                        Text("Back")
                            .font(CustomFont.SFPro(.regular, size: 18))
                    }
                })
                .padding(.leading, 10)
                
                Spacer()
                
                WordListSetting(
                    showContent: $showContent,
                    cur_sortType: $sort1,
                    cur_sortDirection: $sortDirection,
                    cur_groupType: $groupOption,
                    showColumn2: $showColumn2,
                    showColumn3: $showColumn3,
                    displayMode: $displayMode
                )
                .environmentObject(modelData)
                Spacer()
                    .frame(width: 10)
            }
            .zIndex(100)
            
            List {
                ForEach(sortedWordLists, id: \.id) { wl in
                    WordlistSectionList(
                        deleteItem: delete_WordList(w:),
                        wordString: modelData.US.languagePackage.wordlistPage_wordCount,
                        name: wl.name,
                        wl: wl.list,
                        displayMode: displayMode
                    )
                }
            }
            .frame(alignment: .top)
            .offset(y: 30)
        }
        .onAppear(perform: {
            groupWordLists()
            showTabBar = false
        })
        .onChange(of: groupOption, {
            groupWordLists()
        })
        .onChange(of: sort1, {
            groupWordLists()
        })
        .onChange(of: sortDirection, {
            groupWordLists()
        })
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .navigationBarBackButtonHidden(true)
    }
    
    func delete_WordList(w: WordList) {
        modelData.currentSelectedFolder.lists.removeAll(where: {
            $0.id == w.id
        })
    }
    
    private func sortWordLists(list: [WordList]) -> [WordList] {
        return list.sorted {
            switch sort1 {
            case 0:
                return sortDirection ? $0.date < $1.date : $0.date > $1.date
            case 1:
                return sortDirection ? $0.id < $1.id : $0.id > $1.id
            default:
                fatalError("sort1 is out of range")
            }
        }
    }
    
    private func groupWordLists() {
        switch groupOption {
        case 1:
            sortedWordLists = [WordListGroup(
                        name: "Status On",
                        list: sortWordLists(list: modelData.currentSelectedFolder.lists.filter(
                            {
                                $0.start == true
                            }))),
                    WordListGroup(
                        name: "Status Off",
                        list: sortWordLists(list: modelData.currentSelectedFolder.lists.filter(
                            {
                                $0.start == false
                            }))
                    )]
        default:
            sortedWordLists = [WordListGroup(
                name: "English",
                list: sortWordLists(list: modelData.currentSelectedFolder.lists.filter(
                    {
                        $0.language == .english
                    }))
            ),
//                    WordListGroup(
//                        name: "Chinese",
//                        list: sortWordLists(list: modelData.currentSelectedFolder.lists.filter(
//                            {
//                                $0.language == .chinese
//                            }))
//                    )
            ]
        }
    }
}

fileprivate struct testView: View {
    @State var showTab: Bool = false
    
    var body: some View {
        NavigationView(
            content: {
                NavigationLink(
                    "WordlistPage",
                    destination: {
                        WordlistPage(showTabBar: $showTab)
                        .environmentObject(ModelData())
                        .background(
                            CustomColor.gradient(
                                from: "f2f2f6",
                                to: "e7e7eb",
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
            })
        })
    }
}

#Preview {
    testView()
}
