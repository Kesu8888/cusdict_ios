//
//  FavouriteButton.swift
//  Landmarks
//
//  Created by Fu Kaiqi on 2024/11/12.
//

import SwiftUI

struct FavouriteButton: View {
    @Binding var isSet:Bool
    
    var body: some View {
        Button {
            isSet.toggle()
        } label: {
            Label("Toggle favourite", systemImage: "star.fill")
                .labelStyle(.iconOnly)
                .foregroundStyle(isSet ? .yellow : .gray)
        }
    }
}

#Preview {
    FavouriteButton(isSet: .constant(true))
}
