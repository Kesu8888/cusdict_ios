//
//  SortPicker.swift
//  Customized Dictionary
//
//  Created by Fu Kaiqi on 2025/1/1.
//

import SwiftUI

struct testingView: View {
//    @StateObject private var viewModel = DropDownViewModel()
    @State var selection1: Int = 0
    @State var sortSelection = false
//    @State var selection2: String = "Date"
//    @State var selection3: String = "Date"
    
    var body: some View {
        VStack {
            DropDownView(
                options: ["Date", "alpa", "words"],
                selection: $selection1,
                sortDirection: $sortSelection
            )
            .zIndex(10)
        }
        .navigationTitle("DropDown Picker")
    }
}

struct DropDownView: View {
    var options: [String]
    var maxWidth: CGFloat = 180
    var cornerRadius: CGFloat = 15
    @Binding var selection: Int
    
    @Binding var sortDirection: Bool
    @State private var showOptions: Bool = false
    @State private var zIndex: Double = 1000.0
    
    var body: some View {
            VStack(spacing: 0) {
                ZStack {
                    RoundedRectangle(cornerRadius: 0)
                        .fill(Color.white)
                        .frame(width: 100, height: 50)
                    HStack(spacing: 0) {
                        Text(options[selection])
                            .frame(alignment: .trailing)
                            .lineLimit(1)
                            
                        Spacer()
                            .frame(width: 10)
                        Image(systemName: "chevron.down")
                            .font(.title3)
                            .rotationEffect(.degrees(showOptions ? -180 : 0))
                    }
                    .padding(.horizontal, 10)
                    .frame(width: 100, height: 40)
                    .onTapGesture {
                        withAnimation(.snappy) {
                            showOptions.toggle()
                        }
                    }
                    .contentShape(.rect)
                    .foregroundStyle(Color.white)
                    
                    .background(RoundedRectangle(cornerRadius: 10)
                        .fill(Color.cyan))
//
                    
                }
                .zIndex(10)
                
                if showOptions {
                    OptionsView()
                }
            }
            .clipped()
            .frame(width: 100, height: 50, alignment: .top)
            .background(Color.white)
    }
    
    /// Options View
    @ViewBuilder
    func OptionsView() -> some View {
        VStack(spacing: 10) {
            ForEach(options.indices, id: \.self) { i in
                HStack(spacing: 0) {
                    Text(options[i])
                        .lineLimit(1)
                    
                    Spacer()
                        .frame(width: 10)
                    
                    Image(systemName: sortDirection ? "arrow.up" : "arrow.down")
                        .font(.title3)
                        .opacity(selection == i ? 1 : 0)
                }
                .foregroundStyle(selection == i ? Color.blue : Color.white)
                .animation(.none, value: selection)
                .frame(width: 100, height: 40)
                .onTapGesture {
                    withAnimation(.snappy) {
                        if selection == i {
                            sortDirection.toggle()
                        } else {
                            selection = i
                        }
                        // closing drop down view
                        showOptions = false
                    }
                }
            }
        }
        .frame(width: 100)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Color.cyan)
        )
        .transition(.move(edge: .top))
        .zIndex(1)
    }
    enum Anchor {
        case top
        case bottom
    }
}

#Preview {
    testingView()
}
