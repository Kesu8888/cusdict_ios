//
//  WordlistColumn.swift
//  Customized Dictionary
//
//  Created by Fu Kaiqi on 2024/12/30.
//

import SwiftUI

struct WordlistColumn: View {
    var w: WordList
    let ellipseSize = 45.0
    let statusString: LanguageString
    let wordString: LanguageString
    
    var body: some View {
        HStack(alignment: .center, spacing: 0) {
            // Image with name "CapitalC" inside an ellipse with white fill
            ZStack {
                Ellipse()
                    .fill(Color.white)
                    .frame(width: ellipseSize, height: ellipseSize)
                
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
                .foregroundColor(CustomColor.colorFromHex(hex: "EEFF00"))
                .minimumScaleFactor(0.5)
//                .shadow(color: .black.opacity(0.8), radius: 2, x: 1, y: 2)
            
            Spacer(minLength: 0)
                        
            statusColumn(studyingStatus: w.start)
            
            Text("\(w.wordCount) \(wordString.string)")
                .font(wordString.font)
                .foregroundStyle(CustomColor.colorFromHex(hex: "37849D"))
                .padding(.horizontal, 10)
        }
        .frame(width: 370, height: 60, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(
                    LinearGradient(
                        gradient: CustomColor.gradient(from: "A599F3", to: "A6DCEA"),
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
        )
    }
}

#Preview {
    WordlistColumn(
        w: WordList(
            name: "My WordList",
            language: .english,
            passCount: 3,
            start: true
        ),
        statusString: LanguageString(string: "学习中", font: CustomFont.defaultFont()) ,
        wordString: LanguageString(string: "words", font: CustomFont.defaultFont())
    )
}
