//
//  TestSettingObjectNil.swift
//  Customized Dictionary
//
//  Created by Fu Kaiqi on 2025/3/25.
//

import SwiftUI
import PhotosUI

struct TestSettingObjectNil: View {
    @State var file: FileContent?
    @StateObject private var imagePicker = ImagePicker()
    
    var body: some View {
        VStack {
            Text("\(file.debugDescription)")
            PhotosPicker(selection: $imagePicker.imageSelection, label: {
                Text("select photo")
            })
            .onChange(of: imagePicker.image, { oldValue, newValue in
                if newValue == nil {
                    return
                }
                
                file = FileContent.image(newValue!)
            })
            Button(action: {
                file = nil
            }, label: {
                Text("Set to nil")
            })
        }
    }
}


#Preview {
    TestSettingObjectNil()
}
