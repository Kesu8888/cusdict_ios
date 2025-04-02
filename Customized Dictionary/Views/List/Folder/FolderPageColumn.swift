//
//  FolderPageColumn.swift
//  Customized Dictionary
//
//  Created by Fu Kaiqi on 2024/12/29.
//

import SwiftUI

struct FolderPageColumn: View {
    var f: Folder
    
    var body: some View {
        RoundedRectangle(cornerRadius: 20)
            .fill(
                CustomColor.gradient(
                    from: "A599F3",
                    to: "A6DCEA",
                    startPoint: .leading,
                    endPoint: .trailing
                    )
            )
            .frame(width: 350, height: 140)
            .overlay(
                VStack(alignment: .leading, spacing: 5) {
                    Spacer()
                        .frame(height: 20)
                    
                    HStack {
                        Spacer()
                            .frame(width: 40)
                        Image(systemName: "folder")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 40, height: 40) // Adjust the size as needed
                        Spacer()
                            .frame(width: 60)
                        Text(f.id)
                            .font(.custom("SF Pro Semibold", size: 24)) // Set custom font and size
                            .foregroundColor(.black)
                    }
                    
                    Spacer()
                        .frame(height: 20)
                    .offset(x: 40) // Align the text with the folder icon
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            )
    }
}

#Preview {
    let f = Folder(id: "雅思单词")
    FolderPageColumn(f: f)
}
