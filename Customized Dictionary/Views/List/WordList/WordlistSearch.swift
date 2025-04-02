//
//  WordlistSearch.swift
//  Customized Dictionary
//
//  Created by Fu Kaiqi on 2024/12/30.
//

import SwiftUI

struct WordlistSearch: View {
    let searbarText: LanguageString
//    let sortOptions: LanguageStrings
//    @Binding var sort1: Int
//    @Binding var sortDirection: Bool
    
    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: "magnifyingglass")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 15, height: 15)
                .foregroundColor(CustomColor.colorFromHex(hex: "787aa3"))
            
            Text(searbarText.string)
                .font(.custom("SF Pro Regular", size: 16))
                .foregroundColor(CustomColor.colorFromHex(hex: "787aa3"))
        }
        .padding(.horizontal, 15)
        .frame(width: 200, height: 40)
        .background(
            RoundedRectangle(cornerRadius: 15)
                .fill(CustomColor.colorFromHex(hex: "C9EAF0"))
                .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
        )
    }
}

struct testWordlistSearch: View {
    @State var sort1: Int = 0
    @State var sortDirection: Bool = false
    
    var body: some View {
        
        VStack {
            Text("\(sort1)")
            Text("\(sortDirection)")
            WordlistSearch(
                searbarText: LanguageString(string: "Search in Wordlist", font: CustomFont.defaultFont())
            )
        }
    }
}
#Preview {
    testWordlistSearch()
}
