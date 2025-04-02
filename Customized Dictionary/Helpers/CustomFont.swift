//
//  Fonts.swift
//  Customized Dictionary
//
//  Created by Fu Kaiqi on 2024/12/18.
//
import SwiftUI

enum fontStyle {
    case regular
    case medium
    case semibold
    case bold
    case heavy
}

struct CustomFont {
    static func SFPro_Rounded(_ fontStyle: fontStyle, size: CGFloat) -> Font {
        switch fontStyle {
        case .regular:
            return Font.custom("SFProRounded-Regular", size: size)
        case .medium:
            return Font.custom("SFProRounded-Medium", size: size)
        case .semibold:
            return Font.custom("SFProRounded-Semibold", size: size)
        case .bold:
            return Font.custom("SFProRounded-Bold", size: size)
        case .heavy:
            return Font.custom("SFProRounded-Heavy", size: size)
        }
    }
    
    static func SFPro(_ fontStyle: fontStyle, size: CGFloat) -> Font {
        switch fontStyle {
        case .regular:
            return Font.custom("SFProText-Regular", size: size)
        case .medium:
            return Font.custom("SFProText-Medium", size: size)
        case .semibold:
            return Font.custom("SFProText-Semibold", size: size)
        case .bold:
            return Font.custom("SFProText-Bold", size: size)
        case .heavy:
            return Font.custom("SFProText-Heavy", size: size)
        }
    }
    
    static func SFPro_italic(_ fontStyle: fontStyle, size: CGFloat) -> Font {
        switch fontStyle {
        case .regular:
            return Font.custom("SFProText-RegularItalic", size: size)
        case .medium:
            return Font.custom("SFProText-MediumItalic", size: size)
        case .semibold:
            return Font.custom("SFProText-SemiboldItalic", size: size)
        case .bold:
            return Font.custom("SFProText-BoldItalic", size: size)
        case .heavy:
            return Font.custom("SFProText-HeavyItalic", size: size)
        }
    }
    
    static func Songti(_ fontStyle: fontStyle, size: CGFloat) -> Font {
        switch fontStyle {
        case .regular:
            return Font.custom("SourceHanSerifSC-Regular", size: size)
        case .medium:
            return Font.custom("SourceHanSerifSC-Regular", size: size)
        case .semibold:
            return Font.custom("SourceHanSerifSC-SemiBold", size: size)
        case .bold:
            return Font.custom("SourceHanSerifSC-Bold", size: size)
        case .heavy:
            return Font.custom("SourceHanSerifSC-Heavy", size: size)
        }
    }
    
    static func defaultFont() -> Font {
        return Font.custom("SFProText-Regular", size: 16)
    }
}
