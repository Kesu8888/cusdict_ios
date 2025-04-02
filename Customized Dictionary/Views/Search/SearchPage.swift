//
//  SearchPage.swift
//  Customized Dictionary
//
//  Created by Fu Kaiqi on 2025/1/28.
//

import SwiftUI

struct SearchPage: View {
    @State private var searchText: String = ""
    private var wordBase: WordBaseConnector = WordBaseConnector()
    @State private var words: [EnglishWordTrans] = []
    @EnvironmentObject var modelData: ModelData
    
    var body: some View {
        NavigationView {
            VStack {
                HStack(spacing: 0) {
                    Image(systemName: "magnifyingglass")
                        .font(.system(size: 20))
                        .foregroundStyle(Color.white)
                        .padding(.horizontal, 8)
                    ZStack(alignment: .leading) {
                        if searchText.isEmpty {
                            Text("Search...")
                                .foregroundColor(.white)
                                .padding(8)
                        }
                        TextField("", text: $searchText)
                            .padding(8)
                            .foregroundStyle(Color.white)
                            .cornerRadius(8)
                            .frame(width: 200)
                    }
                }
                .frame(alignment: .leading)
                .background(RoundedRectangle(cornerRadius: 10)
                    .fill(Color.gray))
                ForEach(words.indices, id: \.self) { i in
                    NavigationLink(destination: {
                        en_cn_ResultWord(word: wordBase.en_SearchLemma(lan: .Chinese, targetTrans: words[i]), modelData: modelData)
                    }, label: {
                        en_cn_ResultColumn(word: words[i], width: 350)
                    })
                }
            }
            .onChange(of: searchText, {
                if searchText.isEmpty {
                    words = []
                } else {
                    let results = wordBase.searchWords(searchLan: .English, translateLan: .Chinese, pref: searchText)
                    words = results.compactMap { $0 as? EnglishWordTrans }
                }
            })
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        }
    }
}

fileprivate struct testView: View {
    var modelData = ModelData()
    
    var body: some View {
        SearchPage()
            .environmentObject(modelData)
    }
}
#Preview {
    testView()
}
