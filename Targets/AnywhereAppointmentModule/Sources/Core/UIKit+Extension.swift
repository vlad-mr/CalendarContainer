//
//  UIKit+Extension.swift
//  EventViewSDK
//
//  Created by Artem Grebinik on 10.08.2021.
//

import SwiftDate
import UIKit

extension UIColor {
    convenience init(red: CGFloat, green: CGFloat, blue: CGFloat) {
        self.init(red: red / 255, green: green / 255, blue: blue / 255, alpha: 1)
    }
}

extension UIFont {
    public enum MetropolisType: String {
        case semibold = "-Semibold"
        case medium = "-Medium"
        case bold = "-Bold"
        case regular = "-Regular"
    }

    static func Metropolis(_ type: MetropolisType = .bold, size: CGFloat = UIFont.systemFontSize) -> UIFont? {
        return UIFont(name: "Metropolis\(type.rawValue)", size: size)
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
        let nameLabel = UILabel(frame: frame)
        nameLabel.textAlignment = .center
        nameLabel.backgroundColor = AppDecor.getColor(forCharacter: firstLetter)
        nameLabel.textColor = .white
        nameLabel.font = font

        nameLabel.text = initials
        UIGraphicsBeginImageContext(frame.size)
        guard let currentContext = UIGraphicsGetCurrentContext() else {
            return
        }
        nameLabel.layer.render(in: currentContext)
        guard let nameImage = UIGraphicsGetImageFromCurrentImageContext() else {
            return
        }
        image = nameImage
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
