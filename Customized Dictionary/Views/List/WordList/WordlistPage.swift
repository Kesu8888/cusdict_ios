//
//  WordlistPage.swift
//  Customized Dictionary
//
//  Created by Fu Kaiqi on 2024/12/30.
//

import SwiftUI

struct WordlistPage: View {
    @EnvironmentObject var modelData: ModelData
    @State private var sort1 = 0
    @State private var sortDirection = false
    @State private var sortedWordLists: [WordList] = []
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
            
            HStack {
                Button(action: {
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
                    showColumn2: $showColumn2,
                    showColumn3: $showColumn3
                )
                .environmentObject(modelData)
                Spacer()
                    .frame(width: 10)
            }
            .zIndex(100)
            
            ScrollView {
                VStack(alignment: .center) {
                    ForEach(sortedWordLists) { w in
                        WordlistColumn(
                            w: w,
                            statusString: modelData.setting.appSettings.languagePackage.folderPage_statusOn,
                            wordString: modelData.setting.appSettings.languagePackage.wordlistPage_wordCount
                        )
                    }
                }
            }
            .zIndex(1)
            .offset(y: 50)
            .onAppear(perform: {
                self.sort1 = modelData.setting.wordlistPageSettings.sort1
                self.sortDirection = modelData.setting.wordlistPageSettings.sortDirection
                sortWordLists()
                showTabBar = false
            })
            .onChange(of: sort1) {
                modelData.setting.wordlistPageSettings.sort1 = sort1
                sortWordLists()
            }
            .onChange(of: sortDirection) {
                modelData.setting.wordlistPageSettings.sortDirection = sortDirection
                sortWordLists()
            }
        }
        .navigationBarBackButtonHidden(true)
    }
    
    private func sortWordLists() {
        sortedWordLists = modelData.currentSelectedFolder.lists.sorted {
            switch sort1 {
            case 0:
                return sortDirection ? $0.date < $1.date : $0.date > $1.date
            case 1:
                return sortDirection ? $0.id < $1.id : $0.id > $1.id
            case 2:
                return sortDirection ? $0.wordCount < $1.wordCount : $0.wordCount > $1.wordCount
            default:
                return true
            }
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
                                LinearGradient(
                                    gradient: CustomColor.gradient(from: "f2f2f6", to: "e7e7eb"),
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
            })
        })
    }
}

#Preview {
    testView()
}
