//
//  UIKit+Extension.swift
//  EventViewSDK
//
//  Created by Artem Grebinik on 10.08.2021.
//

import UIKit
import SwiftDate

extension UIColor {
    convenience init(red: CGFloat, green: CGFloat, blue: CGFloat) {
        self.init(red: red / 255, green: green / 255, blue: blue / 255, alpha: 1)
    }
}

extension UIFont {

    public enum MetropolisType: String, CaseIterable {
        case semibold = "-Semibold"
        case medium = "-Medium"
        case bold = "-Bold"
        case regular = "-Regular"
       
        func metropolisName() -> String {
            return "Metropolis\(self.rawValue)"
        }
    }
    
    static func Metropolis(_ type: MetropolisType = .bold, size: CGFloat = UIFont.systemFontSize) -> UIFont? {
        return UIFont(name: "Metropolis\(type.rawValue)", size: size)
    }
}

extension UIColor {
    class func bundledColor(named: String, from bundle: Bundle = Bundle(for: EventViewSDK.self)) -> UIColor? {
        let color = UIColor(named: named)
        if color == nil {
            return UIColor(named: named, in: bundle, compatibleWith: nil)
        }
        return color
    }
}

extension UIImage {
    class func bundledImage(named: String, from bundle: Bundle = Bundle(for: EventViewSDK.self)) -> UIImage? {
        let image = UIImage(named: named)
        if image == nil {
            return UIImage(named: named, in: bundle, compatibleWith: nil)
        } // Replace MyBasePodClass with yours
        return image
    }
    
    convenience init?(named: String, from bundle: Bundle) {
        let bundleURL = bundle.resourceURL?.appendingPathComponent("AnywhereAppointmentModule.bundle")
        let resourceBundle = Bundle(url: bundleURL!)
        self.init(named: named, in: resourceBundle, compatibleWith: nil)
    }
}

extension UIImageView {
    
    func setImage(forName name: String?, font: UIFont = AppDecor.Fonts.medium.withSize(20)) {

        var initials = ""
        guard let nameComponents = name?.components(separatedBy: " "), let firstWord = nameComponents.first, let firstLetter = firstWord.first else {
            return
        }
        //        if nameComponents.count > 1, let lastWord = nameComponents.last, let lastLetter = lastWord.first {
        //                initials += String(lastLetter).capitalized
        //        }
        initials += String(firstLetter).capitalized
        let nameLabel = UILabel(frame: self.frame)
        nameLabel.textAlignment = .center
        nameLabel.backgroundColor = AppDecor.getColor(forCharacter: firstLetter)
        nameLabel.textColor = .white
        nameLabel.font = font

        nameLabel.text = initials
        UIGraphicsBeginImageContext(frame.size)
        guard  let currentContext = UIGraphicsGetCurrentContext() else {
            return
        }
        nameLabel.layer.render(in: currentContext)
        guard let nameImage = UIGraphicsGetImageFromCurrentImageContext() else {
            return
        }
        self.image = nameImage
    }

    func setImage(forColorCode code: Int, size: CGSize = CGSize(width: 1, height: 1)) {
        let rect = CGRect(origin: .zero, size: size)
        guard let color = AppDecor.getCardColor(forCode: code) else { return }
        UIGraphicsBeginImageContext(size)
        color.setFill()
        UIRectFill(rect)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        self.image = image
    }
}

extension UIImage {
    static func getImage(forColorCode code: Int, size: CGSize = CGSize(width: 1, height: 1)) -> UIImage? {
        let color = AppDecor.getCardColor(forCode: code)
        return getImage(forColor: color, size: size)
    }
    
    static func getImage(forColor color: UIColor?, size: CGSize = CGSize(width: 1, height: 1)) -> UIImage? {
        guard let color = color else {
            return nil
        }
        let rect = CGRect(origin: .zero, size: size)
        UIGraphicsBeginImageContext(size)
        color.setFill()
        UIRectFill(rect)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
}
