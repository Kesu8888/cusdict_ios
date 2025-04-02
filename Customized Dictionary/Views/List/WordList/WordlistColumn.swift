//
//  WordlistColumn.swift
//  Customized Dictionary
//
//  Created by Fu Kaiqi on 2024/12/30.
//

import SwiftUI

struct WordlistColumn: View {
    var w: WordList
    let ellipseSize = 36.0
    let wordString: LanguageString
    
    var body: some View {
        HStack(alignment: .center, spacing: 0) {
            // Image with name "CapitalC" inside an ellipse with white fill
            ZStack {
                Ellipse()
                    .fill(Color.clear)
                    .frame(width: ellipseSize, height: ellipseSize)
                    .overlay(
                        Ellipse()
                            .stroke(Color.gray, lineWidth: 2)
                    )
                
                Image("CapitalC")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: ellipseSize * 3 / 4, height: ellipseSize * 3 / 4)
                    .clipShape(Ellipse())
            }
            .padding(.horizontal, 10)
            
            // Text with w.id
            Text(w.name)
                .lineLimit(1)
                .font(CustomFont.SFPro(.medium, size: 24))
                .frame(width: 120, alignment: .leading)
                .foregroundColor(CustomColor.colorFromHex(hex: "333333"))
                .minimumScaleFactor(0.5)
            
            if w.start {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundStyle(Color.blue)
                    .font(.system(size: 20))
                    .padding(.leading, 10)
            } else {
                Image(systemName: "minus.circle.fill")
                    .foregroundStyle(Color.gray)
                    .font(.system(size: 20))
                    .padding(.leading, 10)
            }
            
            Text("\(w.wordCount) \(wordString.string)")
                .font(wordString.font)
                .foregroundStyle(CustomColor.colorFromHex(hex: "37849D"))
                .padding(.horizontal, 10)
        }
        .frame(width: 300, height: 50, alignment: .center)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Color.white)
        )
    }
}

fileprivate struct testView: View {
    @State var wl: [WordList] = [WordList(
        name: "My WordList 1",
        language: .english,
        passCount: 3,
        start: true
    ),
    WordList(
         name: "My WordList 2",
         language: .english,
         passCount: 3,
         start: false
    )]
    var body: some View {
        VStack {
            ForEach(wl.indices, id: \.self) { i in
                WordlistColumn(
                    w: wl[i],
                    wordString: LanguageString(string: "words", font: CustomFont.defaultFont())
                )
                .swipeActions(edge: .trailing) {
                    Button(action: {
                        wl.remove(at: i)
                    }, label: {
                        Label("delete", systemImage: "trash")
                    })
                }
            }
        }
    }
}
#Preview {
    testView()
}
