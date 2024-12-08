//
//  ProfileEditor.swift
//  Landmarks
//
//  Created by Fu Kaiqi on 2024/11/16.
//

import SwiftUI

struct ProfileEditor: View {
    @Binding var profile:Profile
    
    var dateRange: ClosedRange<Date> {
        let min = Calendar.current.date(byAdding: .year, value: -1, to: profile.goalDate)!
        let max = Calendar.current.date(byAdding: .year, value: 1, to: profile.goalDate)!
        return min...max
    }
    
    var body: some View {
        List {
            HStack {
                Text("Username")
                Spacer()
                TextField("Username", text: $profile.username)
                // sets the color
                    .foregroundStyle(.secondary)
                //sets the item follow the alignment
                    .multilineTextAlignment(.trailing)
            }
            
            Toggle(isOn: $profile.prefersNotification) {
                Text("Enable Notification")
            }
            
            Picker("Seasonal Photo", selection: $profile.seasonalPhoto) {
                ForEach(Profile.Season.allCases) { season in
                    Text(season.rawValue).tag(season)
                }
            }
            //Quite confused
            DatePicker(selection: $profile.goalDate, in: dateRange, displayedComponents: .date) {
                Text("Goal date")
            }
        }
    }
}

#Preview {
    ProfileEditor(profile: .constant(.default))
}
