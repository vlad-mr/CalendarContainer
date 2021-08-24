//
//  UIView+Extension.swift
//  EventViewSDK
//
//  Created by Artem Grebinik on 10.08.2021.
//

import UIKit

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

extension UIView {
    func disableAutoresizing(recursive: Bool = true) {
        translatesAutoresizingMaskIntoConstraints = false
        if recursive { subviews.forEach { $0.disableAutoresizing(recursive: recursive) } }
    }

    func rotate(_ angle: CGFloat) {
        let radians = angle / 180.0 * CGFloat(Double.pi)
        transform = CGAffineTransform(rotationAngle: radians)
    }

    func setRoundedCorners(withCornerRadius cornerRadius: CGFloat? = nil) {
        var radius = frame.height / 2
        if let cornerRadiusForView = cornerRadius {
            radius = cornerRadiusForView
        }
        layer.cornerRadius = radius
        clipsToBounds = true
    }

    func setRoundedBottomCorners(withCornerRadius cornerRadius: CGFloat? = nil) {
        var radius = frame.height / 2
        if let cornerRadiusForView = cornerRadius {
            radius = cornerRadiusForView
        }
        layer.cornerRadius = radius
        clipsToBounds = true
        layer.maskedCorners = [.layerMaxXMinYCorner, .layerMaxXMaxYCorner]
    }

    func setRoundedTopCorners(withCornerRadius cornerRadius: CGFloat? = nil) {
        var radius = frame.height / 2
        if let cornerRadiusForView = cornerRadius {
            radius = cornerRadiusForView
        }
        layer.cornerRadius = radius
        clipsToBounds = true
        layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
    }
}

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
