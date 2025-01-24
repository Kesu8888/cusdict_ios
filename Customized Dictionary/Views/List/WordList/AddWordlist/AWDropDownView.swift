//
//  AWDropDownView.swift
//  Customized Dictionary
//
//  Created by Fu Kaiqi on 2025/1/6.
//

import SwiftUI

struct AWPicker<T: Hashable & CustomStringConvertible>: View {
    let s: [T]
    @Binding var selection: T
    let textSize: CGFloat
    @State private var showOptions: Bool = false
    
    var body: some View {
        VStack(spacing: 5) {
            Button(action: {
                withAnimation(.snappy) {
                    showOptions.toggle()
                }
            }) {
                HStack {
                    Text(selection.description)
                        .font(CustomFont.SFPro_Rounded(.medium, size: 18))
                        .foregroundStyle(Color.black)
                        .frame(width: textSize, alignment: .center)
                    Image(systemName: showOptions ? "chevron.up" : "chevron.down")
                        .foregroundStyle(Color.black)
                }
                .frame(width: textSize + 40, height: 40)
                .background(RoundedRectangle(cornerRadius: 8)
                    .fill(Color.white))
            }

            if showOptions {
                AWDropDownView(
                    s: s,
                    selection: $selection,
                    textSize: textSize
                )
            }
        }
        .clipped()
        .frame(width: textSize + 40, height: 40, alignment: .top)
    }
    struct AWDropDownView: View {
        let s: [T]
        @Binding var selection: T
        let textSize: CGFloat
        
        var body: some View {
            Picker("Alphabet", selection: $selection) {
                ForEach(s, id: \.self) { str in
                    Text(str.description)
                        .font(CustomFont.SFPro_Rounded(.medium, size: 18))
                }
            }
            .pickerStyle(WheelPickerStyle()) // Use a menu picker style for better appearance
            .frame(width: textSize + 40, height: 140, alignment: .top)
            .background(RoundedRectangle(cornerRadius: 8)
                .fill(Color.green))
        }
    }
}



fileprivate struct testView: View {
    let s: [String] = ["English", "SChinese", "Japanese", "Korean"]
    @State var selection: String = "SChinese"
    
    var body: some View {
        AWPicker(s: s, selection: $selection, textSize: 80)
    }
}
#Preview {
    
    testView()
}
