//
//  WordListSetting.swift
//  Customized Dictionary
//
//  Created by Fu Kaiqi on 2025/1/15.
//

import SwiftUI

struct WordListSetting: View {
    @Binding var showContent: Bool
    @State var selection: Int = 0
    @Binding var cur_sortType: Int
    @Binding var cur_sortDirection: Bool
    @Binding var cur_groupType: Int
    @Binding var showColumn2: Bool
    @Binding var showColumn3: Bool
    @Binding var displayMode: Bool
    @EnvironmentObject var modelData: ModelData
    
    var body: some View {
//        ZStack(alignment: .topTrailing) {
        VStack(alignment: .trailing) {
            Button(action: {
                showContent.toggle()
            }, label: {
                Image(systemName: "ellipsis.circle")
                    .resizable()
                    .foregroundStyle(CustomColor.colorFromHex(hex: "e5b423"))
                    .opacity(showContent ? 0.5 : 1)
                    .frame(width: 24, height: 24)
            })
            .padding(.trailing, 10)
            
            Spacer()
            // Content VStack
            ZStack(alignment: .topTrailing) {
                if showColumn2 {
                    Color.clear
                        .contentShape(Rectangle())
                        .frame(width: 216, height: 80)
                        .onTapGesture {
                            withAnimation {
                                showColumn2 = false
                            }
                        }
                        .zIndex(10)
                }
                
                if showColumn3 {
                    Color.clear
                        .contentShape(Rectangle())
                        .frame(width: 216, height: 125.8)
                        .onTapGesture {
                            withAnimation {
                                showColumn3 = false
                            }
                        }
                        .zIndex(10)
                }
                VStack(alignment: .trailing, spacing: 0) {
                    NavigationLink(
                        destination: {
                            AddWordlistPage(
                                languagePack: modelData.US.languagePackage
                            )
                            .environmentObject(modelData)
                        },
                        label: {
                            column1(
                                text: "Add WordList",
                                imageName: "plus"
                            )
                            .opacity(showColumn2 || showColumn3 ? 0.3 : 1)
                    })
                    .simultaneousGesture(TapGesture().onEnded({
                        showContent = false
                    }))
                    
                    Divider()
                        .background(CustomColor.colorFromHex(hex: "ebebee"))
                        .opacity(showColumn2 || showColumn3 ? 0.3 : 1)
                    
                    Button(action: {
                        displayMode.toggle()
                        showContent = false
                    }, label: {
                        if displayMode {
                            column1(text: "View as Gallery", imageName: "square.grid.2x2")
                        } else {
                            column1(text: "View as List", imageName: "list.bullet")
                        }
                    })
                    .opacity(showColumn2 || showColumn3 ? 0.3 : 1)
                    Divider()
                        .background(CustomColor.colorFromHex(hex: "ebebee"))
                        .opacity(showColumn2 || showColumn3 ? 0.3 : 1)
                    Button(action: {
                        
                    }, label: {
                        column1(text: "SelectLists", imageName: "checkmark.circle")
                    })
                    .opacity(showColumn2 || showColumn3 ? 0.3 : 1)
                    Divider()
                        .background(CustomColor.colorFromHex(hex: "ebebee"))
                        .opacity(showColumn2 || showColumn3 ? 0.3 : 1)
                    column2(
                        text: "Sort By",
                        sortTypes: ["Date Edited", "Title"],
                        sortDirections: [["Newest First", "Oldest First"], ["A to Z", "Z to A"]],
                        cur_sortType: $cur_sortType,
                        cur_sortDirections: $cur_sortDirection,
                        showColumn2: $showColumn2,
                        showColumn3: $showColumn3
                    )
                    .backgroundStyle(Color.black)
                    .opacity(showColumn3 ? 0.3 : 1)
                    .scaleEffect(showColumn2 ? 1/0.9 : 1)
                    .offset(x: showColumn2 ? -13 : 0, y: showColumn2 ? -20 : 0)
                    .zIndex(showColumn2 ? 100 : 1)
                    
                    Divider()
                        .background(CustomColor.colorFromHex(hex: "ebebee"))
                    column3(
                        text: "Group By",
                        groupTypes: ["Language", "Status"],
                        cur_groupType: $cur_groupType,
                        showColumn2: $showColumn2,
                        showColumn3: $showColumn3
                    )
                    .opacity(showColumn2 ? 0.3 : 1)
                    .scaleEffect(showColumn3 ? 1/0.9 : 1)
                    .offset(x: showColumn3 ? -13 : 0, y: showColumn3 ? -20 : 0)
                    .zIndex(showColumn3 ? 100 : 1)
                }
                .foregroundStyle(Color.black)
                .frame(width: 240, alignment: .topLeading)
                .background(RoundedRectangle(cornerRadius: 15)
                    .fill(Color.white))
                .scaleEffect(showColumn2 || showColumn3 ? 0.9 : 1, anchor: .topTrailing)
                .scaleEffect(showContent ? 1 : 0, anchor: .topTrailing)
                .animation(.easeInOut(duration: 0.3), value: showContent)
            }
        }
        .frame(height: 24, alignment: .top)
//        }
        .onChange(of: cur_sortType, {
            showContent = false
        })
        .onChange(of: cur_sortDirection, {
            showContent = false
        })
        .onChange(of: cur_groupType, {
            showContent = false
        })
    }
}

fileprivate struct column1: View {
    let text: String
    let imageName: String
    var body: some View {
        HStack(spacing: 0) {
            Spacer()
                .frame(width: 30)
            Text(text)
                .frame(width: 150, height: 22, alignment: .leading)
                .lineLimit(1)
                .font(CustomFont.SFPro(.regular, size: 18))
                .foregroundStyle(Color.black)
            Spacer()
                .frame(width: 20)
            Image(systemName: imageName)
                .resizable()
                .frame(width: 20, height: 20)
                .foregroundStyle(Color.black)
        }
        .frame(width: 240, height: 36, alignment: .leading)
    }
}

fileprivate struct column2: View {
    let text: String
    let sortTypes: [String]
    let sortDirections: [[String]]
    @Binding var cur_sortType: Int
    @Binding var cur_sortDirections: Bool
    @Binding var showColumn2: Bool
    @Binding var showColumn3: Bool
    
    var body: some View {
        VStack(spacing: 0) {
            Button(action: {
                withAnimation(.easeInOut(duration: 0.3)) {
                    showColumn2.toggle()
                    showColumn3 = false
                }
            }, label: {
                HStack(spacing: 0) {
                    Image(systemName: "chevron.right")
                        .font(.system(size: 16, weight: .bold))
                        .frame(width: 26)
                        .padding(.leading, 4)
                        .rotationEffect(showColumn2 ? Angle(degrees: 90) : Angle(degrees: 0))
                    VStack(alignment: .leading) {
                        Text(text)
                            .font(showColumn2 ? CustomFont.SFPro(.semibold, size: 18) : CustomFont.SFPro(.regular, size: 18))
                            .foregroundStyle(Color.black)
                        Text(sortTypes[cur_sortType])
                            .foregroundStyle(Color.gray)
                    }
                    .frame(width: 150, height: 40, alignment: .leading)
                    
                    Spacer()
                        .frame(width: 20)
                    
                    Image(systemName: "arrow.up.arrow.down")
                        .resizable()
                        .frame(width: 20, height: 20)
                        .foregroundStyle(Color.black)
                }
                .frame(width: 240, height: 50, alignment: .leading)
            })
            
            if showColumn2 {
                Divider()
                VStack(spacing: 0) {
                    ForEach(0...1, id: \.self) { i in
                        Button(action: {
                            cur_sortType = i
                            showColumn2 = false
                        }, label: {
                            HStack(spacing: 0) {
                                Image(systemName: "checkmark")
                                    .font(.system(size: 16, weight: .bold))
                                    .frame(width: 26)
                                    .padding(.leading, 4)
                                    .opacity(cur_sortType == i ? 1 : 0.001)
                                Text(sortTypes[i])
                                    .frame(width: 150, height: 22, alignment: .leading)
                                    .lineLimit(1)
                                    .font(CustomFont.SFPro(.regular, size: 18))
                                    .foregroundStyle(Color.black)
                                Spacer()
                                    .frame(width: 20)
                            }
                            .frame(width: 240, height: 36, alignment: .leading)
                        })

                        Divider()
                    }
                    
                    CustomColor.gradient(
                        from: "efeff3",
                        to: "ededf1",
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                    .frame(height: 10)
                    
                    Button(action: {
                        cur_sortDirections = true
                        showColumn2 = false
                    }, label: {
                        HStack(spacing: 0) {
                            Image(systemName: "checkmark")
                                .font(.system(size: 16, weight: .bold))
                                .frame(width: 26)
                                .padding(.leading, 4)
                                .opacity(cur_sortDirections ? 1 : 0.001)
                            Text(sortDirections[cur_sortType][0])
                                .frame(width: 150, height: 22, alignment: .leading)
                                .lineLimit(1)
                                .font(CustomFont.SFPro(.regular, size: 18))
                                .foregroundStyle(Color.black)
                            Spacer()
                                .frame(width: 20)
                        }
                        .frame(width: 240, height: 36, alignment: .leading)
                    })
                    Divider()
                    
                    Button(action: {
                        cur_sortDirections = false
                        showColumn2 = false
                    }, label: {
                        HStack(spacing: 0) {
                            Image(systemName: "checkmark")
                                .font(.system(size: 16, weight: .bold))
                                .frame(width: 26)
                                .padding(.leading, 4)
                                .opacity(!cur_sortDirections ? 1 : 0.001)
                            Text(sortDirections[cur_sortType][1])
                                .frame(width: 150, height: 22, alignment: .leading)
                                .lineLimit(1)
                                .font(CustomFont.SFPro(.regular, size: 18))
                                .foregroundStyle(Color.black)
                            Spacer()
                                .frame(width: 20)
                        }
                        .frame(width: 240, height: 36, alignment: .leading)
                    })
                    Divider()
                }
            }
        }
        .background(RoundedRectangle(cornerRadius: 15)
            .fill(Color.white))
        .frame(width: 240, height: 50, alignment: .top)
    }
}

fileprivate struct column3: View {
    let text: String
    let groupTypes: [String]
    @Binding var cur_groupType: Int
    @Binding var showColumn2: Bool
    @Binding var showColumn3: Bool
    private let images = ["globe", "minus.circle"]
    
    var body: some View {
        VStack(spacing: 0) {
            Button(action: {
                withAnimation(.easeInOut(duration: 0.3)) {
                    showColumn3.toggle()
                    showColumn2 = false
                }
            }, label: {
                HStack(spacing: 0) {
                    Image(systemName: "chevron.right")
                        .font(.system(size: 16, weight: .bold))
                        .frame(width: 26)
                        .padding(.leading, 4)
                        .rotationEffect(showColumn3 ? Angle(degrees: 90) : Angle(degrees: 0))
                        
                    
                    VStack(alignment: .leading) {
                        Text(text)
                            .font(showColumn3 ? CustomFont.SFPro(.semibold, size: 18) : CustomFont.SFPro(.regular, size: 18))
                            .foregroundStyle(Color.black)
                        Text(groupTypes[cur_groupType])
                            .foregroundStyle(Color.gray)
                    }
                    .frame(width: 150, height: 40, alignment: .leading)
                    
                    Spacer()
                        .frame(width: 20)
                    
                    Image(systemName: images[cur_groupType])
                        .resizable()
                        .frame(width: 20, height: 20)
                        .foregroundStyle(Color.black)
                    Spacer()
                        .frame(width: 23)
                }
                .frame(width: 240, height: 50, alignment: .leading)
            })
            
            
            if showColumn3 {
                Divider()
                
                VStack(spacing: 0) {
                    ForEach(images.indices, id: \.self) { i in
                        Button(action: {
                            cur_groupType = i
                            showColumn3 = false
                        }, label: {
                            HStack(spacing: 0) {
                                Image(systemName: "checkmark")
                                    .font(.system(size: 16, weight: .bold))
                                    .frame(width: 26)
                                    .padding(.leading, 4)
                                    .opacity(cur_groupType == i ? 1 : 0.001)
                                Text(groupTypes[i])
                                    .frame(width: 150, height: 22, alignment: .leading)
                                    .lineLimit(1)
                                    .font(CustomFont.SFPro(.regular, size: 18))
                                    .foregroundStyle(Color.black)
                                Spacer()
                                    .frame(width: 20)
                                Image(systemName: images[i])
                                    .resizable()
                                    .frame(width: 20, height: 20)
                                    .foregroundStyle(Color.black)
                            }
                        })
                        .frame(width: 240, height: 36, alignment: .leading)
                        if i < 2 {
                            Divider()
                        }
                    }
                }
            }
        }
        .background(RoundedRectangle(cornerRadius: 15)
            .fill(Color.white))
        .frame(width: 240, height: 50, alignment: .top)
    }
}
fileprivate struct testView: View {
    
    var body: some View {
        NavigationView(
            content: {
                NavigationLink(
                    "Hello Word",
                    destination: hw())
        })
    }
}
fileprivate struct hw: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var sortType = 0
    @State private var sortDirection = false
    @State private var groupOption: Int = 1
    @State private var showContent = false
    @State private var showColumn2 = false
    @State private var showColumn3 = false
    @State private var displayMode: Bool = true
    var modelData = ModelData()
    
    var body: some View {
        GeometryReader{ geometry in
            VStack {
                ZStack(alignment: .top) {
                    if showContent {
                        Color.black.opacity(0.001)
                            .edgesIgnoringSafeArea(.all)
                            .onTapGesture {
                                showContent = false
                                showColumn2 = false
                                showColumn3 = false
                            }
                    }
                    
                    HStack {
                        Button(action: {
                            presentationMode.wrappedValue.dismiss()
                        }, label: {
                            HStack(spacing: 6) {
                                Image(systemName: "chevron.left")
                                    .font(.system(size: 21))
                                Text("Back")
                                    .font(CustomFont.SFPro(.regular, size: 18))
                            }
                        })
                        .padding(.leading, 10)
                        
                        Spacer()
                        
                        WordListSetting(
                            showContent: $showContent,
                            cur_sortType: $sortType,
                            cur_sortDirection: $sortDirection,
                            cur_groupType: $groupOption,
                            showColumn2: $showColumn2,
                            showColumn3: $showColumn3,
                            displayMode: $displayMode
                        )
                        .environmentObject(modelData)
                        Spacer()
                            .frame(width: 10)
                    }
                }
            }
            .frame(width: geometry.size.width, height: geometry.size.height, alignment: .top)
            .background(
                CustomColor.gradient(
                    from: "f2f2f6",
                    to: "e7e7eb",
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
        }
        .navigationBarBackButtonHidden(true)
    }
}
#Preview {
    testView()
}
