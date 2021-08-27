//
//  AssetsColor.swift
//  EventViewSDK
//
//  Created by Artem Grebinik on 10.08.2021.
//

import UIKit

extension UIColor {
    
    public enum AssetsColor: String, CaseIterable {
        case anytimeSolidBlue = "AnytimeSolidBlue"
        case anytimeLightBlue = "AnytimeLightBlue"
        case anytimeWhite = "White"
       
        case anytimeBrown = "anytimeBrown"
        case anytimeOrange = "anytimeOrange"
        
        case whiteBorder = "WhiteBorder"
        case blueBorder = "BlueBorder"
        
        case lightCeruleanBlue = "CardLightCeruleanBlue"
        case lightSeaGreen = "CardLightSeaGreen"
        case lightSlateBlue = "CardLightSlateBlue"
        case ceruleanBlue = "CardCeruleanBlue"
        case burntSienna = "CardBurntSienna"
        case cornFlower = "CardCornflower"
        case steelBlue = "CardSteelBlue"
        case tapestry = "CardTapestry"
        case sun = "CardSun"
        case fern = "CardFern"
        case puce = "CardPuce"
        case mandy = "CardMandy"
        case bronco = "CardBronco"
        case scampi = "CardScampi"
        case sinbad = "CardSinbad"
        case concord = "CardConcord"
        case negroni = "CardNegroni"
        case saffron = "CardSaffron"
        case seagull = "CardSeagull"
        case flamingo = "CardFlamingo"
    }
    
    static func appColor(_ name: AssetsColor) -> UIColor {
        switch name {
        case .anytimeLightBlue:
            if #available(iOS 11.0, *) {
                return UIColor.bundledColor(named: name.rawValue) ?? .cyan
            } else {
                return .cyan
            }
        case .anytimeSolidBlue:
            if #available(iOS 11.0, *) {
                return UIColor.bundledColor(named: name.rawValue) ?? .blue
            } else {
                return .blue
            }
        case .anytimeWhite:
            if #available(iOS 11.0, *) {
                return UIColor.bundledColor(named: name.rawValue) ?? .white
            } else {
                return .white
            }
            
        case .anytimeBrown:
            if #available(iOS 11.0, *) {
                return UIColor.bundledColor(named: name.rawValue) ?? .brown
            } else {
                return .brown
            }
        case .anytimeOrange:
            if #available(iOS 11.0, *) {
                return UIColor.bundledColor(named: name.rawValue) ?? .orange
            } else {
                return .orange
            }
        case .lightCeruleanBlue:
            if #available(iOS 11.0, *) {
                return UIColor.bundledColor(named: name.rawValue) ?? .blue
            } else {
                return .blue
            }
        case .lightSeaGreen:
            if #available(iOS 11.0, *) {
                return UIColor.bundledColor(named: name.rawValue) ?? .green
            } else {
                return .green
            }
        case .lightSlateBlue:
            if #available(iOS 11.0, *) {
                return UIColor.bundledColor(named: name.rawValue) ?? .blue
            } else {
                return .blue
            }
        case .ceruleanBlue:
            if #available(iOS 11.0, *) {
                return UIColor.bundledColor(named: name.rawValue) ?? .blue
            } else {
                return .blue
            }
        case .burntSienna:
            if #available(iOS 11.0, *) {
                return UIColor.bundledColor(named: name.rawValue) ?? .purple
            } else {
                return .purple
            }
        case .cornFlower:
            if #available(iOS 11.0, *) {
                return UIColor.bundledColor(named: name.rawValue) ?? .magenta
            } else {
                return .magenta
            }
        case .steelBlue:
            if #available(iOS 11.0, *) {
                return UIColor.bundledColor(named: name.rawValue) ?? .blue
            } else {
                return .blue
            }
        case .tapestry:
            if #available(iOS 11.0, *) {
                return UIColor.bundledColor(named: name.rawValue) ?? .blue
            } else {
                return .blue
            }
        case .sun:
            if #available(iOS 11.0, *) {
                return UIColor.bundledColor(named: name.rawValue) ?? .yellow
            } else {
                return .yellow
            }
        case .fern:
            if #available(iOS 11.0, *) {
                return UIColor.bundledColor(named: name.rawValue) ?? .yellow
            } else {
                return .yellow
            }
        case .puce:
            if #available(iOS 11.0, *) {
                return UIColor.bundledColor(named: name.rawValue) ?? .orange
            } else {
                return .orange
            }
        case .mandy:
            if #available(iOS 11.0, *) {
                return UIColor.bundledColor(named: name.rawValue) ?? .orange
            } else {
                return .orange
            }
        case .bronco:
            if #available(iOS 11.0, *) {
                return UIColor.bundledColor(named: name.rawValue) ?? .orange
            } else {
                return .orange
            }
        case .scampi:
            if #available(iOS 11.0, *) {
                return UIColor.bundledColor(named: name.rawValue) ?? .orange
            } else {
                return .orange
            }
        case .sinbad:
            if #available(iOS 11.0, *) {
                return UIColor.bundledColor(named: name.rawValue) ?? .orange
            } else {
                return .orange
            }
        case .concord:
            if #available(iOS 11.0, *) {
                return UIColor.bundledColor(named: name.rawValue) ?? .orange
            } else {
                return .orange
            }
        case .negroni:
            if #available(iOS 11.0, *) {
                return UIColor.bundledColor(named: name.rawValue) ?? .orange
            } else {
                return .orange
            }
        case .saffron:
            if #available(iOS 11.0, *) {
                return UIColor.bundledColor(named: name.rawValue) ?? .orange
            } else {
                return .orange
            }
        case .seagull:
            if #available(iOS 11.0, *) {
                return UIColor.bundledColor(named: name.rawValue) ?? .orange
            } else {
                return .orange
            }
        case .flamingo:
            if #available(iOS 11.0, *) {
                return UIColor.bundledColor(named: name.rawValue) ?? .orange
            } else {
                return .orange
            }
        case .whiteBorder:
            if #available(iOS 11.0, *) {
                return UIColor.bundledColor(named: name.rawValue) ?? .white
            } else {
                return .white
            }
        case .blueBorder:
            if #available(iOS 11.0, *) {
                return UIColor.bundledColor(named: name.rawValue) ?? .blue
            } else {
                return .blue
            }
        }
    }
}
