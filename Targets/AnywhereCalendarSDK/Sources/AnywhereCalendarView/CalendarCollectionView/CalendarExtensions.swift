//
//  CalendarExtensions.swift
//  Anytime
//
//  Created by Vignesh on 20/02/20.
//  Copyright © 2020 FullCreative Pvt Ltd. All rights reserved.
//

import Foundation
import SwiftDate
import UIKit

extension CALayer {
    func addBorder(edge: UIRectEdge, color: UIColor, thickness: CGFloat) {
        let border = CALayer()

        switch edge {
        case UIRectEdge.top:
            border.frame = CGRect(x: 0, y: 0, width: frame.width, height: thickness)
        case UIRectEdge.bottom:
            border.frame = CGRect(x: 0, y: frame.height - thickness, width: frame.width, height: thickness)
        case UIRectEdge.left:
            border.frame = CGRect(x: 0, y: 0, width: thickness, height: frame.height)
        case UIRectEdge.right:
            border.frame = CGRect(x: frame.width - thickness, y: 0, width: thickness, height: frame.height)
        default:
            break
        }

        border.backgroundColor = color.cgColor

        addSublayer(border)
    }
}

extension CGRect {
    func liesWithin(_ rect: CGRect) -> Bool {
        let result = minY >= rect.minY && maxY <= rect.maxY
        return result
    }
}

extension UIView {
    func dropShadow(scale: Bool = true, withRadius radius: CGFloat = 2, offset: CGSize = CGSize(width: -1, height: 1)) {
        layer.masksToBounds = false
        if let bgColor = backgroundColor, bgColor != .white {
            layer.shadowColor = bgColor.cgColor
        } else {
            layer.shadowColor = UIColor.lightGray.cgColor
        }
        layer.shadowOpacity = 0.5
        layer.shadowOffset = offset
        layer.shadowRadius = radius
        layer.shouldRasterize = true
        layer.rasterizationScale = scale ? UIScreen.main.scale : 1
    }
}

extension UIColor {
    static var grey200: UIColor {
        UIColor(red: 0.965, green: 0.973, blue: 0.988, alpha: 1)
    }

    static var grey300: UIColor {
        UIColor(red: 0.752, green: 0.8, blue: 0.879, alpha: 1)
    }

    static var grey400: UIColor {
        UIColor(red: 0.518, green: 0.584, blue: 0.694, alpha: 1)
    }

    static var grey700: UIColor {
        UIColor(red: 0.078, green: 0.149, blue: 0.251, alpha: 1)
    }

    static var blue500: UIColor {
        UIColor(red: 0.384, green: 0.522, blue: 1, alpha: 1)
    }

    static var blue700: UIColor {
        UIColor(red: 0.113, green: 0.564, blue: 0.960, alpha: 1)
    }

    static var red200: UIColor {
        UIColor(red: 0.819, green: 0.301, blue: 0.007, alpha: 1)
    }
}
