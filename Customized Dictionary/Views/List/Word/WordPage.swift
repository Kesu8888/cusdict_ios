//
//  WordPage.swift
//  Customized Dictionary
//
//  Created by Fu Kaiqi on 2025/2/13.
//

import SwiftUI

struct WordPage: View {
    @EnvironmentObject var modelData: ModelData
    
    var body: some View {
        Text("")
//        switch modelData.currentSelectedWordlist.language {
//        case .english:
//            EnglishWordPage()
//        }
    }
}

fileprivate struct testView: View {
    var modelData = ModelData()
    var body: some View {
        WordPage()
            .environmentObject(modelData)
    }
}
#Preview {
    testView()
}
