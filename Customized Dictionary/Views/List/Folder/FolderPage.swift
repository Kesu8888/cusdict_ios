//
//  FolderPage.swift
//  Customized Dictionary
//
//  Created by Fu Kaiqi on 2024/12/29.
//

import SwiftUI

struct FolderPage: View {
    @State var modelData: ModelData
    @State private var scrollPosition = ScrollPosition(y: 0)
    @State private var offsetY: CGFloat = 0
    @Binding var showTabBar: Bool
    @State var addFolderBar: Bool = false
    
    var body: some View {
        NavigationView {
            ZStack(alignment: .top) {
                ZStack(alignment: .top) {
                    ScrollView {
                        VStack {
                            Spacer()
                                .frame(height: 120)
                            ForEach (modelData.mainFolder) { f in
                                NavigationLink(destination: WordlistPage(showTabBar: $showTabBar).environmentObject(modelData)) {
                                    FolderPageColumn(f: f)
//                                        .transition(.scale)
                                }
                                .simultaneousGesture(TapGesture().onEnded({
                                    modelData.currentSelectedFolder = f
                                }))
                            }
                        }
                    }
                    .animation(.smooth, value: modelData.mainFolder)
                    .scrollPosition($scrollPosition)
                    .onScrollGeometryChange(for: CGFloat.self) { geometry in
                        geometry.contentOffset.y
                    } action: { oldValue, newValue in
                        if oldValue != newValue {
                            offsetY = newValue
                        }
                    }
                    
                    Button(action: {
                        withAnimation {
                            addFolderBar = true
                        }
                    }, label: {
                        FolderPageAddButton(contentOffset: offsetY)
                    })
                    .offset(x: 120, y:45)
                    
                    VStack {
                        Spacer()
                            .frame(height: 10)
                        Text("Current Offset: \(String(format: "%.2f", offsetY))")
                            .padding()
                            .background(Color.white)
                            .cornerRadius(10)
                            .shadow(radius: 5)
                            .padding(.top, 10)
                    }
                }
                .blur(radius: addFolderBar ? 20 : 0)
                .animation(.easeInOut(duration: 0.3), value: addFolderBar)
                
                if addFolderBar {
                    Color.black.opacity(0.4)
                        .edgesIgnoringSafeArea(.all)
                        .onTapGesture {
                            addFolderBar = false
                        }
                    
                    AddFolderBar(addFolderBar: $addFolderBar)
                        .environmentObject(modelData)
                        .offset(y: 100)
                }
            }
        }
        .onDisappear(perform: {
            showTabBar = false
        })
    }
}

fileprivate struct testView: View {
    @State var showBar = false
    var body: some View {
        FolderPage(modelData: ModelData(), showTabBar: $showBar)
    }
}

#Preview {
    testView()
}
