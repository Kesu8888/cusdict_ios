//
//  testFonts.swift
//  Customized Dictionary
//
//  Created by Fu Kaiqi on 2025/1/3.
//

import SwiftUI

struct testFonts: View {
    var body: some View {
        VStack {
            Text("ABC abc 列表名 123")
                .font(CustomFont.SFPro(.regular, size: 18))
            Text("ABC abc 列表名 123")
                .font(CustomFont.SFPro(.semibold, size: 18))
            Text("ABC abc 列表名 123")
                .font(CustomFont.Songti(.semibold, size: 18))
            Text("ABC abc 列表名 123")
                .font(CustomFont.Songti(.bold, size: 18))
            Text("ABC abc 列表名 123")
                .font(CustomFont.Songti(.heavy, size: 18))
        }
    }
    
    init() {
        for familyName in UIFont.familyNames {
            print(familyName)
            
            for fontName in UIFont.fontNames(forFamilyName: familyName) {
                print("-- \(fontName)")
            }
        }
    }
}

#Preview {
    testFonts()
}
