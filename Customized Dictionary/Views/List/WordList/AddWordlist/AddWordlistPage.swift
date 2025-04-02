//
//  AddWordlistPage.swift
//  Customized Dictionary
//
//  Created by Fu Kaiqi on 2025/1/3.
//

import SwiftUI

struct AddWordlistPage: View {
    let languagePack: UILanguage
    @EnvironmentObject var modelData: ModelData
    @Environment(\.presentationMode) var presentationMode
    
    @State private var listName: String = ""
    @State private var languageOption: String = ""
    @State private var statusOption: Bool = false
    @State private var passCount: Int = 1
    
    @State private var debug: Int = 0
    @State private var errorMsg: String = ""
    @State private var showError: Bool = false
        
    var body: some View {
        GeometryReader { geometry in
            // Top VStack
            VStack {
//                Button(action: {
//                    debug += 1
//                }) {
//                    Text(languageOption)
//                }
                // Spacer to create 50-point gap from the top
                Spacer()
                    .frame(height: 50)
                
                // Profile view centered horizontally
                HStack {
                    Spacer()
                    
                    ZStack(alignment: .center) {
                        Ellipse()
                            .fill(Color.white)
                            .frame(width: 110, height: 110)
                            .shadow(color: .blue.opacity(0.7), radius: 3, x: 0, y: 2)
                        
                        Image(systemName: "plus")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 66, height: 66) // 2/3 of the ellipse size
                            .foregroundColor(CustomColor.colorFromHex(hex: "000000"))
                            .clipShape(Ellipse())
                    }
                    
                    Spacer()
                }
                
                // listName and MyList
                VStack(alignment: .leading, spacing: 10) {
                    // MyList text at the same horizontal position as listName
                    Text("MyList")
                        .font(CustomFont.SFPro(.semibold, size: 18))
                        .frame(width: geometry.size.width * 0.9 * 0.9, alignment: .leading)
                        .offset(x: 5)
                        


                    // listName wrapped in a yellow RoundedRectangle
                    ZStack {
                        RoundedRectangle(cornerRadius: 10)
                            .fill(CustomColor.colorFromHex(hex: "ffffff"))
                            .frame(width: geometry.size.width * 0.9, height: 40)
                            .shadow(color: .blue.opacity(0.7), radius: 3, x: 0, y: 2)
                        
                        // Editable MyList text at the same horizontal position as listName
                        TextField("Enter list name", text: $listName)
                            .font(CustomFont.SFPro(.semibold, size: 17))
//                            .foregroundStyle(CustomColor.colorFromHex(hex: "4469DB"))
                            .frame(width: geometry.size.width * 0.9 * 0.92, alignment: .leading)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.leading, geometry.size.width * 0.05) // Center the VStack horizontally
                
                Spacer()
                    .frame(height: 20)
                HStack(alignment: .top) {
                    VStack(alignment:.leading, spacing: 0) {
                        Text("Language")
                            .font(CustomFont.SFPro(.semibold, size: 18))
                            .offset(x: 4)
                        Spacer()
                            .frame(height: 5)
                        
                        AWPicker(
                            s: languagePack.addWordlistPage_lan.strings,
                            selection: $languageOption,
                            textSize: 80
                        )
                        .onAppear(perform: {
                            languageOption = languagePack.addWordlistPage_lan.strings[0]
                        })
                        .shadow(color: .blue.opacity(0.7), radius: 3, x: 0, y: 2)
                    }
                    .padding(.leading, geometry.size.width * 0.05) // Center the VStack horizontally
                    
                    Spacer()
                    
                    VStack(alignment: .leading, spacing: 0) {
                        Text("Status")
                            .font(CustomFont.SFPro(.semibold, size: 18))
                            .offset(x: 4)
                        Spacer()
                            .frame(height: 10)
                        Button(action: {
                            statusOption.toggle()
                        }) {
                            statusColumn(studyingStatus: statusOption)
                        }
                    }
                    
                    Spacer()
                    
                    VStack(spacing: 0) {
                        Text("passCount")
                            .font(CustomFont.SFPro(.semibold, size: 18))
                        Spacer()
                            .frame(height: 5)
                        AWPicker(
                            s: [1,2,3,4,5],
                            selection: $passCount,
                            textSize: 30
                        )
                        .shadow(color: .blue.opacity(0.7), radius: 3, x: 0, y: 2)
                    }
                    .padding(.trailing, geometry.size.width * 0.05) // Center the VStack horizontally
                }

                Spacer()
                
                if showError {
                    Text(errorMsg)
                        .font(CustomFont.SFPro_Rounded(.medium, size: 18))
                        .foregroundStyle(Color.red)
                        .opacity(showError ? 1 : 0)
                        .animation(.easeInOut(duration: 1), value: showError)
                }
                
                HStack(spacing: 50) {
                    Button(action: {
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        Text(languagePack.addWordlistPage_cancel.string)
                            .font(CustomFont.SFPro_Rounded(.medium, size: 18))
                    }
                    
                    // Add WordList Button
                    Button(
                        action: {
                            if modelData.currentSelectedFolder.lists.count >= 200 {
                                errorMsg = "Too many wordlists"
                                withAnimation {
                                    showError = true
                                }
                                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                    withAnimation {
                                        showError = false
                                    }
                                    errorMsg = ""
                                }
                                return
                            }
                            
                            if listName.isEmpty || containsInvalidCharacters(listName) {
                                errorMsg = "Invalid list name"
                                withAnimation {
                                    showError = true
                                }
                                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                    withAnimation {
                                        showError = false
                                    }
                                    errorMsg = ""
                                }
                                return
                            }
                            
                            let newW = WordList(
                                name: listName,
                                language: Language(rawValue: languageOption) ?? . english,
                                passCount: Int64(passCount),
                                start: statusOption
                            )
                            guard modelData.Folder_AddWordList(W: newW) else {
                                errorMsg = "Too many wordlists with the same name"
                                withAnimation {
                                    showError = true
                                }
                                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                    withAnimation {
                                        showError = false
                                    }
                                    errorMsg = ""
                                }
                                return
                            }
                            
                            // Add the new wordlist to the current selected folder
                            modelData.currentSelectedFolder.lists.append(newW)
                            
                            // Set needsSorting to true to trigger sorting in WordlistPage
//                            needsSorting = true
                            
                            // Dismiss the AddWordlistPage
                            presentationMode.wrappedValue.dismiss()
                        }
                    ) {
                        HStack(alignment: .center, spacing: 10) {
                            Image(systemName: "plus")
                            
                            Text(languagePack.addWordlistPage_confirm.string)
                                .font(CustomFont.SFPro_Rounded(.medium, size: 18))
                        }
                        .foregroundStyle(Color.white)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 10)
                        .background(RoundedRectangle(cornerRadius: 20)
                            .fill(CustomColor.colorFromHex(hex: "665496")))
                    }
                }
                .padding(.bottom, 20)
            }
            .frame(alignment: .leading)
//            .offset(y: -80)
        }
        .navigationBarBackButtonHidden(true)
    }
    
    private func containsInvalidCharacters(_ text: String) -> Bool {
        let invalidCharacters = CharacterSet(charactersIn: "<>{}[]\"'`~!@#$%^&*()_+=|\\:;?/.,")
        return text.rangeOfCharacter(from: invalidCharacters) != nil
    }
}

fileprivate struct testView: View {
    var modelData = ModelData()
    @State var needsort = false
    @State var showTabBar: Bool = false
    
    var body: some View {
        NavigationView {
            VStack {
                NavigationLink(
                    destination: AddWordlistPage(
                        languagePack: modelData.US.languagePackage
                    )
                    .environmentObject(modelData)
                    .background(CustomColor.colorFromHex(hex: "f1f1f1"))
                ) {
                    Text("Go to AddWordlistPage")
                        .font(.headline)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
            }
            .navigationTitle("Test View")
        }
    }
}

#Preview {
    testView()
}
