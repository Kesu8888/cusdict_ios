//
//  LandmarkDetail.swift
//  Landmarks
//
//  Created by Fu Kaiqi on 2024/11/11.
//

import SwiftUI
import MapKit

struct LandmarkDetail: View {
    @Environment(ModelData.self) var modelData
    var landmark: Landmark
    
    //! means it defintely is a value and please use it
    var landmarkIndex : Int {
        modelData.landmarks.firstIndex(where: {
            $0.id == landmark.id
        })!
    }
    
    var body: some View {
        @Bindable var modelData = modelData
        
        VStack {
            Map(initialPosition: .region(MKCoordinateRegion(
                    center: landmark.locationCoordinate,
                    span: MKCoordinateSpan(latitudeDelta: 0.2, longitudeDelta: 0.2)
                    )
                )
            )
            .frame(height: 300)
            
            landmark.image
                .clipShape(Circle())
                .overlay{
                    Circle().stroke(.white, lineWidth: 5)
                }
                .shadow(radius: 10)
                .offset(y: -130)
                .padding(.bottom, -130)
            
            VStack(alignment: .leading) {
                HStack {
                    Text(landmark.name)
                        .font(.title)
                    FavouriteButton(isSet: $modelData.landmarks[landmarkIndex].isFavorite)
                }
                HStack {
                    Text(landmark.park)
                    Spacer()
                    Text(landmark.state)
                }
                .font(.subheadline)
                Divider()
                Text(landmark.description)
                    .font(.body)
                    .foregroundStyle(.blue)
            }
            .padding()
            Spacer()
        }
    }
}

#Preview {
    LandmarkDetail(landmark: ModelData().landmarks[0])
        .environment(ModelData())
}
