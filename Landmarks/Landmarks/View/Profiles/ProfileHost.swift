//
//  ProfileHost.swift
//  Landmarks
//
//  Created by Fu Kaiqi on 2024/11/15.
//

import SwiftUI

struct ProfileHost: View {
    //editmode is a swiftUI native bool
    @Environment(\.editMode) var editMode
    // Read the user’s profile data from the environment to pass control of the data to the profile host.
    @Environment(ModelData.self) var modelData
    @State private var draftProfile = Profile.default
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack() {
                if editMode?.wrappedValue == .active {
                    Button("Cancel", role: .cancel) {
                        draftProfile = modelData.profile
                        editMode?.wrappedValue = .inactive
                    }
                }
                
                Spacer()
                //EditButton is used with editMode environment which will toggle editMode when pressed
                EditButton()
            }
            
            // This is the way how the views is changed base on the editMode Value
            if editMode?.wrappedValue == .inactive {
                ProfileSummary(profile: modelData.profile)
            } else {
                ProfileEditor(profile: $draftProfile)
                    .onAppear {
                        draftProfile = modelData.profile
                    }
                    .onDisappear {
                        modelData.profile = draftProfile
                    }
            }
        }
        //padding automatically adjust the objects to better fit the frame
        .padding()
    }
}

#Preview {
    // \() is the formatter in swift
    ProfileHost()
        .environment(ModelData())
}
