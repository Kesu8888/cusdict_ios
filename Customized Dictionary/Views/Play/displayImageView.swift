//
//  displayImageView.swift
//  Customized Dictionary
//
//  Created by Fu Kaiqi on 2025/4/3.
//

import SwiftUI

enum ImageRatio {
    case taller
    case wider
    
    var value: CGFloat {
        switch self {
        case .taller:
            return 3 / 4
        case .wider:
            return 4 / 3
        }
    }
}

struct displayImageView: View {
    let displayImage: UIImage
    let height: CGFloat
    let ratio: ImageRatio
    
    var body: some View {
        HStack {
//            let originalWidth = displayImage.size.width
//            let originalHeight = displayImage.size.height
//            let originalRatio = originalWidth / originalHeight
            // Calculate the cropping width based on the desired ratio
            let croppedWidth: CGFloat = height * ratio.value

            Image(uiImage: displayImage)
                .resizable()
                .scaledToFill()
                .frame(width: croppedWidth, height: height)
                .clipped()
                .cornerRadius(10)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(CustomColor.gradient(colorFrom: .green, colorTo: .blue, startPoint: .leading, endPoint: .trailing), lineWidth: 4) // Add a gray border with 4pt width
                )
                .shadow(color: .black.opacity(0.2), radius: 5, x: 0, y: 5) // Add a shadow for a 3D effect
        }
    }
}

fileprivate struct testView: View {
    var body: some View {
        if let image = UIImage(named: "apples") {
            displayImageView(
                displayImage: image,
                height: UIScreen.main.bounds.height * 0.2,
                ratio: .wider
            )
        } else {
            Text("Image not found")
                .foregroundColor(.red)
        }
    }
}

#Preview {
    testView()
}
