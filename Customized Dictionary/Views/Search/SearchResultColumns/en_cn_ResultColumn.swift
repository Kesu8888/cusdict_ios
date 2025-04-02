//
//  SearchResultColumn.swift
//  Customized Dictionary
//
//  Created by Fu Kaiqi on 2025/2/2.
//

import SwiftUI

struct en_cn_ResultColumn: View {
    let word: EnglishWordTrans
    let width: CGFloat
    var body: some View {
        ZStack(alignment: .trailing) {
            VStack(spacing: 0) {
                Text(word.word)
                    .font(CustomFont.SFPro_Rounded(.semibold, size: 25))
                    .foregroundStyle(CustomColor.colorFromHex(hex: "084c51"))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.leading, 20)
                    .padding(.trailing, 50)
                HStack {
                    Text(word.meaning.map { $0.wordtype.rawValue }.joined(separator: "&"))
                        .font(CustomFont.SFPro_Rounded(.semibold, size: 18))
                        .foregroundStyle(CustomColor.colorFromHex(hex: "663cdd"))
                        .frame(width: 50, alignment: .leading)
                    Spacer()
                        .frame(width: 30)
//                    Text(word.translation.joined(separator: " "))
//                        .font(CustomFont.SFPro_Rounded(.regular, size: 18))
//                        .foregroundStyle(CustomColor.colorFromHex(hex: "095054"))
//                    Spacer()
//                        .frame(width: 30)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.leading, 20)
                .padding(.trailing, 50)
            }
            
            Button(action: {
                // Add the word to default wordlist
            }, label: {
                Image(systemName: "plus.app.fill")
                    .resizable()
                    .frame(width: 40, height: 40)
                    .offset(x: -10)
                    .symbolRenderingMode(.palette)
                    .foregroundStyle(Color.blue, Color.white)
            })
        }
        .foregroundStyle(Color.white)
        .frame(width: width, height: 60, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(CustomColor.colorFromHex(hex: "1de0a1"))
        )
    }
}

fileprivate struct testView: View {
    let word: EnglishWordTrans
    
    init() {
        let wb = WordBaseConnector()
        let targetTrans = wb.searchWords(searchLan: .English, translateLan: .Chinese, pref: "te") as! [EnglishWordTrans]
        self.word = targetTrans[0]
    }
    
    var body: some View {
        VStack {
            en_cn_ResultColumn(word: word, width: 350)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
        .background(Color(red: 241/255, green: 241/255, blue: 241/255))
    }
}
#Preview {
    testView()
}
