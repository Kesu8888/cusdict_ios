//
//  AddFolderColumn.swift
//  Customized Dictionary
//
//  Created by Fu Kaiqi on 2025/1/14.
//

import SwiftUI

struct AddFolderBar: View {
    @State private var folderName: String = ""
    @Binding var addFolderBar: Bool
    @EnvironmentObject var modelData: ModelData
    @State var errormsg: String = ""
    
    var body: some View {
        VStack {
            Spacer()
                .frame(height: 20)
            
            HStack {
                Spacer()
                    .frame(width: 30)
                Text("Name")
                    .foregroundStyle(CustomColor.colorFromHex(hex: "003366"))
                Spacer()
                // Text Editor
                ZStack {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(CustomColor.colorFromHex(hex: "ffffff"))
                        .frame(width: 150, height: 34)
                        .shadow(color: .blue.opacity(0.7), radius: 3, x: 0, y: 2)
                    
                    TextField("", text: $folderName)
                        .font(CustomFont.SFPro(.semibold, size: 17))
                        .frame(width: 130, height: 30)
                        .onChange(of: folderName) {
                            folderName = filterSQLTableName(folderName)
                        }
                }
                Spacer()
                    .frame(width: 40)
            }
            
            Spacer()
            
            if !errormsg.isEmpty {
                Text(errormsg)
                    .foregroundColor(.red)
                    .opacity(errormsg.isEmpty ? 0 : 1)
                    .transition(.opacity)
                    .onAppear {
                        withAnimation {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                withAnimation {
                                    errormsg = ""
                                }
                            }
                        }
                    }
            }
            
            Button(action: {
                if folderName == "" {
                    errormsg = "Invalid folder name"
                    return
                }
                
                let f = Folder(id: folderName)
                if modelData.MainFolder_AddFolder(f: f) {
                    withAnimation {
                        modelData.mainFolder.insert(f, at: 0) // Insert at the beginning
                    }
                    addFolderBar = false
                } else {
                    errormsg = "Repeated folder name"
                }
            }, label: {
                Image(systemName: "plus.app")
                    .resizable()
                    .frame(width: 30, height: 30)
            })
            
            Spacer()
                .frame(height: 10)
        }
        .frame(width: 300, height: 180, alignment: .top)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(
                    CustomColor.colorFromHex(hex: "e0f7fa")
                )
        )
    }

    private func filterSQLTableName(_ input: String) -> String {
        let allowedCharacters = CharacterSet(charactersIn: "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789_")
        return String(input.unicodeScalars.filter { allowedCharacters.contains($0) })
    }
}

fileprivate struct testView: View {
    @State var addFolderBar = false
    
    var body: some View {
        AddFolderBar(addFolderBar: $addFolderBar)
            .environmentObject(ModelData())
    }
}
#Preview {
    testView()
}
