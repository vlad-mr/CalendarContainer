//
//  AppExtensions.swift
//  AnywhereCalendarView
//
//  Created by Deepika on 19/06/20.
//  Copyright © 2020 FullCreative Pvt Ltd. All rights reserved.
//

import Foundation
import SwiftDate
import UIKit
#if canImport(CalendarUtils)
    import CalendarUtils
#endif

extension UIViewController {
    func embedViewController(_ viewController: UIViewController, toContainerView containerView: UIView) {
        addChild(viewController)
        viewController.view.frame = containerView.bounds
        containerView.addSubview(viewController.view)
        viewController.didMove(toParent: self)
    }
}

extension Array {
    var isNotEmpty: Bool {
        return !isEmpty
    }
}

extension UIView {
    func addSubViews(_ views: [UIView]) {
        views.forEach { view in
            self.addSubview(view)
        }
    }
}

extension UIView {
    func setupHeightAnchor(withConstant constant: CGFloat, priority: UILayoutPriority = .defaultHigh) {
        let heightConstraint = heightAnchor.constraint(equalToConstant: constant)
        heightConstraint.priority = priority
        heightConstraint.isActive = true
    }

    func setupWidthAnchor(withConstant constant: CGFloat, priority: UILayoutPriority = .defaultHigh) {
        let widthConstraint = widthAnchor.constraint(equalToConstant: constant)
        widthConstraint.priority = priority
        widthConstraint.isActive = true
    }
}

extension UIStackView {
    func addArrangedSubviews(_ views: [UIView]) {
        for view in views {
            addArrangedSubview(view)
        }
    }
}

extension UIStackView {
    func addVerticalSeparators(color: UIColor) {
        var numberOfSubviews = arrangedSubviews.count - 1
        while numberOfSubviews >= 0 {
            let separator = createSeparator(color: color)
            insertArrangedSubview(separator, at: numberOfSubviews)
            separator.heightAnchor.constraint(equalTo: heightAnchor, multiplier: 1).isActive = true
            numberOfSubviews -= 1
        }
    }

    private func createSeparator(color: UIColor) -> UIView {
        return configure(UIView()) {
            $0.widthAnchor.constraint(equalToConstant: 1).isActive = true
            $0.backgroundColor = color
        }
    }
}

public extension Date {
    func add(component: Calendar.Component, value: Int) -> Date {
        return Calendar.gregorian.date(byAdding: component, value: value, to: self) ?? self
    }
}

extension UIImage {
    static func getImage(withName name: String) -> UIImage? {
        let podBundle = Bundle(for: CalendarLayoutViewController.self)
        guard let bundleURL = podBundle.resourceURL?.appendingPathComponent("AnywhereCalendarSDK.bundle") else {
            return nil
        }
        let resourceBundle = Bundle(url: bundleURL)
        return UIImage(named: name, in: resourceBundle, compatibleWith: nil)
    }
}

extension Date {
    func isSameAs(date: Date) -> Bool {
        let differnceBetweenDates = Calendar.gregorian.dateComponents([.day], from: dateAt(.startOfDay), to: date.dateAt(.endOfDay)).day ?? 0
        return differnceBetweenDates == 0
    }
}

extension UIView {
    func layoutViewWithoutAnimation() {
        UIView.performWithoutAnimation {
            self.layoutIfNeeded()
        }
    }
}

extension UILabel {
    func setMargins(margin: CGFloat = 10) {
        if let textString = text {
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.firstLineHeadIndent = margin
            paragraphStyle.headIndent = margin
            paragraphStyle.tailIndent = -margin
            let attributedString = NSMutableAttributedString(string: textString)
            attributedString.addAttribute(
                .paragraphStyle,
                value: paragraphStyle,
                range: NSRange(location: 0, length: attributedString.length)
            )
            attributedText = attributedString
        }
    }
}
