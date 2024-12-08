//
//  ProfileSummary.swift
//  Landmarks
//
//  Created by Fu Kaiqi on 2024/11/15.
//

import SwiftUI

struct ProfileSummary: View {
    @Environment(ModelData.self) var modelData
    var profile: Profile
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 10) {
                Text(profile.username)
                    .bold()
                    .font(.title)
                Text("Notifications: \(true)")
                Text("Seasonal photo: \(profile.seasonalPhoto.rawValue)")
                Text("Goal: ") + Text(profile.goalDate, style: .date)
                
                Divider()
                
                VStack(alignment: .leading) {
                    Text("Completed Badges")
                    
                    ScrollView(.horizontal) {
                        HStack {
                            HikeBadge(name: "First Hike")
                            HikeBadge(name: "Earth Day")
                            // hueRotation can change the color by degree(?) Idon't know what that mean but that's how it does
                                .hueRotation(Angle(degrees: 90))
                            HikeBadge(name: "Tenth Hike")
                            // reduces the indensity of the colors
                                .grayscale(0.5)
                                .hueRotation(Angle(degrees: 45))
                        }
                        .padding(.bottom)
                    }
                }
                
                Divider()
                
                VStack(alignment: .leading) {
                    Text("Recent Hikes")
                        .bold()
                    
                    HikeView(hike: modelData.hikes[0])
                }
            }
        }
    }
}

#Preview {
    ProfileSummary(profile: Profile.default)
        .environment(ModelData())
}
