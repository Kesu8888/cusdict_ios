//
//  BadgeBackground.swift
//  Landmarks
//
//  Created by Fu Kaiqi on 2024/11/13.
//

import SwiftUI

struct BadgeBackground: View {
    var body: some View {
        GeometryReader { geometry in
            Path {
                path in
                // Adding the container size 100px*100px
                var width : CGFloat = min(
                    geometry.size.width, geometry.size.height
                )
                let height = width
                
                let xSacle: CGFloat = 0.832
                let xoffset = (width * (1.0 - xSacle)) / 2.0
                width = width * xSacle
                
                
                // Adding an extra point that link to last points of the hexagon
                path.move(
                    to: CGPoint(
                        x: width*0.95 + xoffset,
                        y: height * (0.2 + HexagonParameters.adjustment))
                )
                
                HexagonParameters.segments.forEach {
                    segment in
                    path.addLine(
                        to: CGPoint(
                            x: width*segment.line.x + xoffset,
                            y: height*segment.line.y
                        )
                    )
                    
                    path.addQuadCurve(
                        to: CGPoint(
                            x: width*segment.curve.x + xoffset,
                            y: height*segment.curve.y
                        ),
                        control: CGPoint(
                            x: width*segment.control.x + xoffset,
                            y: height*segment.control.y
                        )
                    )
                }
            }
            .fill(
                .linearGradient(
                    Gradient(colors: [Self.gradientStart, Self.gradientEnd]),
                    startPoint: UnitPoint(x: 0.5, y: 0),
                    endPoint: UnitPoint(x: 0.5, y: 0.6)
                )
            )
        }
        .aspectRatio(1, contentMode: .fit)
    }
    static let gradientStart = Color(red: 239.0 / 255, green: 120.0 / 255, blue: 221.0 / 255)
    static let gradientEnd = Color(red: 239.0 / 255, green: 172.0 / 255, blue: 120.0 / 255)
}

#Preview {
    BadgeBackground()
}
