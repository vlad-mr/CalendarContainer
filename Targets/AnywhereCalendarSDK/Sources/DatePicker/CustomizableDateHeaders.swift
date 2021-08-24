//
//  CustomizableDateHeaders.swift
//  AnywhereCalendarSDK
//
//  Created by Vignesh on 12/03/21.
//

import UIKit
#if canImport(CalendarUtils)
    import CalendarUtils
#endif

public protocol CustomizableDateHeader: UIView, Initializable, AnywhereCustomizableView {
    func configure(with configuration: DatePickerConfig, for weekday: Int, dayType: DateType)
}
