//
//  statusBar.swift
//  Customized Dictionary
//
//  Created by Fu Kaiqi on 2024/12/30.
//

import SwiftUI

struct statusColumn: View {
    let studyingStatus: Bool
    
    var body: some View {
        // status column
        HStack {
            Text(studyingStatus ? "学习中" : "未学习")
                .lineLimit(1)
                .font(.custom("SF Pro Semibold", size: 14)) // Set custom font and size
                .foregroundColor(CustomColor.colorFromHex(hex: studyingStatus ? "0C4DF0" : "ffffff"))
                .layoutPriority(1) // Give higher layout priority to the text
            
            Spacer()
                .frame(width: 5)
            
            Image(systemName: studyingStatus ? "checkmark.circle" : "minus.circle")
                .resizable()
                .frame(width: 20, height: 20) // Set the size to 20x20
                .foregroundColor(CustomColor.colorFromHex(hex: studyingStatus ? "0C4DF0" : "ffffff"))
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 5)
        .background(
            RoundedRectangle(cornerRadius: 30)
                .fill(CustomColor.colorFromHex(hex: studyingStatus ? "d0ff00" : "929292"))
        )
        .overlay(
        RoundedRectangle(cornerRadius: 30)
            .stroke(Color.black.opacity(0.4), lineWidth: 2) // Add black stroke with 2 points width
        )
    }
}

#Preview {
    statusColumn(studyingStatus: true)
}
