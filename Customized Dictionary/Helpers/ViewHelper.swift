//
//  ViewHelper.swift
//  Customized Dictionary
//
//  Created by Fu Kaiqi on 2025/2/28.
//

import Foundation
import SwiftUI

struct ViewHelper {
    // return true if the text passed the validation
    // ^, |, ~, #, §
    static func questionText_validation(text: String) -> Bool {
        let separators: CharacterSet = ["^", "|", "~", "#", "§"]
        return text.rangeOfCharacter(from: separators) != nil
    }
    
//    static func imageColumn(imageName: String, fg: Color, bg: Color, content: some View) -> some View {
//        let rowHeight = UIScreen.main.bounds.height * 0.055
//        let logoBackgroundSize = rowHeight * 0.6
//        let image = Image(systemName: imageName)
//            .font(.system(size: 16))
//            .foregroundStyle(fg)
//            .frame(width: logoBackgroundSize, height: logoBackgroundSize)
//            .background(RoundedRectangle(cornerRadius: 5)
//                .fill(bg))
//            .padding(.horizontal, logoBackgroundSize * 2 / 3)
//        
//        
//        let returnView = HStack {
//            image
//            content
//        }
//            .frame(height: rowHeight)
//            .background(RoundedRectangle(cornerRadius: 10)
//                .fill(Color.white))
//        return returnView
//    }
//    
//    static func imageColumnFlexHeight(imageName: String, fg: Color, bg: Color, content: some View) -> some View {
//        let rowHeight = UIScreen.main.bounds.height * 0.055
//        let logoBackgroundSize = rowHeight * 0.6
//        let image = Image(systemName: imageName)
//            .font(.system(size: 16))
//            .foregroundStyle(fg)
//            .frame(width: logoBackgroundSize, height: logoBackgroundSize)
//            .background(RoundedRectangle(cornerRadius: 5)
//                .fill(bg))
//            .padding(.horizontal, logoBackgroundSize * 2 / 3)
//        
//        
//        let returnView = HStack {
//            image
//            content
//        }
//            .background(RoundedRectangle(cornerRadius: 10)
//                .fill(Color.white))
//        return returnView
//    }
}
