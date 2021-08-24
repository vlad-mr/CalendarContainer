//
//  AnyCalViews.swift
//  AnywhereCalendarSDK
//
//  Created by Vignesh on 16/03/21.
//

import UIKit

public protocol Initializable {
    init()
}

public protocol ReusableView: class {
    static var reuseIdentifier: String { get }
}

public extension ReusableView {
    static var reuseIdentifier: String {
        return String(describing: self)
    }
}

public protocol ReusableNib {
    /// Defaultly the nibName and reuseIdentifier would be same - description to self, if the user wants they can provide different nibName and reuseIdentifier
    static var nibName: String { get }
    static func getNib() -> UINib?
}

public extension ReusableNib where Self: UIView {
    static var nibName: String {
        String(describing: self)
    }
}
