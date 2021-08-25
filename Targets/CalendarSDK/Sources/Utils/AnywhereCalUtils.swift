//
//  Utils+Extensions.swift
//  AnywhereCalendarSDK
//
//  Created by Vignesh on 30/09/20.
//

import Foundation
import SwiftDate

@discardableResult public func configure<T>(
    _ value: T,
    using closure: (inout T) throws -> Void
) rethrows -> T {
    var value = value
    try closure(&value)
    return value
}
