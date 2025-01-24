//
//  FolderPageAddButton.swift
//  Customized Dictionary
//
//  Created by Fu Kaiqi on 2024/12/29.
//

import SwiftUI

struct FolderPageAddButton: View {
    var contentOffset: CGFloat
    
    var body: some View {
        HStack(spacing: 5) {
            Text("添加")
                .font(.custom("SF Pro Semibold", size: 16))
                .foregroundColor(.white)
            
            Image(systemName: "plus")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 14, height: 14)
                .foregroundColor(.white)
        }
        .frame(width: 100, height: 40)
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(CustomColor.colorFromHex(hex: "4B6CFF"))
                .shadow(color: Color.black.opacity(0.2), radius: 4, x: 0, y: 4) // Add drop shadow
        )
    }
}

#Preview {
    FolderPageAddButton(contentOffset: -40)
}
