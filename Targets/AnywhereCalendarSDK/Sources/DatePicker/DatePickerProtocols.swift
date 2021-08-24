//
//  DatePickerProtocols.swift
//  AnywhereCalendarSDK
//
//  Created by Vignesh on 16/03/21.
//

import UIKit
#if canImport(CalendarUtils)
    import CalendarUtils
#endif

public protocol DatePickerDataSource {
    func isDayOff(on date: Date) -> Bool
    func numberOfEvents(for date: Date) -> Int
}

public protocol AnywhereCustomizableView {
    func setConfig(_ config: DatePickerConfig)
    func setTheme(_ theme: DatePickerTheme)
}

public protocol DatePickerButton: UIButton, Initializable, AnywhereCustomizableView {
    func configure()
}

public extension DatePickerButton {
    func setConfig(_: DatePickerConfig) {}
    func setTheme(_: DatePickerTheme) {}
}

public protocol MonthHeaderButton: DatePickerButton {
    func setMonthTitle(_ title: String)
}

public protocol MonthNavigatorButton: DatePickerButton {}

public protocol TodayButton: DatePickerButton {}
