//
//  CustomColor.swift
//  Customized Dictionary
//
//  Created by Fu Kaiqi on 2024/12/29.
//

import Foundation
import SwiftUI

struct CustomColor {
    static func colorFromHex(hex: String) -> Color {
        guard hex.count <= 6 else {
            fatalError("Hex color string length should not be more than 6 characters.")
        }
        
        let scanner = Scanner(string: hex)
        var rgbValue: UInt64 = 0
        scanner.scanHexInt64(&rgbValue)
        
        let red = Double((rgbValue & 0xFF0000) >> 16) / 255.0
        let green = Double((rgbValue & 0x00FF00) >> 8) / 255.0
        let blue = Double(rgbValue & 0x0000FF) / 255.0
        
        return Color(red: red, green: green, blue: blue)
    }
    
    static func gradient(from: String, to: String, startPoint: UnitPoint, endPoint: UnitPoint) -> LinearGradient {
        let fromColor = colorFromHex(hex: from)
        let toColor = colorFromHex(hex: to)
        
        return LinearGradient(gradient: Gradient(colors: [fromColor, toColor]), startPoint: startPoint, endPoint: endPoint) 
    }
    
    static func gradient(colorFrom: Color, colorTo: Color, startPoint: UnitPoint, endPoint: UnitPoint) -> LinearGradient {
        return LinearGradient(colors: [colorFrom, colorTo], startPoint: startPoint, endPoint: endPoint)
    }
}
