//
//  DatePickerConstants.swift
//  AnywhereCalendarSDK
//
//  Created by Vignesh on 25/05/21.
//

import UIKit

public struct DatePickerDimensions {
    var weekHeaderHeight: CGFloat
    var monthTitleHeight: CGFloat
    var pickerDateHeight: CGFloat
}

public extension DatePickerDimensions {
    static var standard: Self {
        self.init(weekHeaderHeight: 40, monthTitleHeight: 25, pickerDateHeight: 40)
    }
}
