//
//  DatePickerInterface.swift
//  AnywhereCalendarSDK
//
//  Created by Vignesh on 30/09/20.
//

import UIKit
import SwiftDate

internal var calendarWeekStartDay: Int {
    SwiftDate.defaultRegion.calendar.firstWeekday
}

// delegate - week start day
var userRegion: Region {
    var cal = Calendar.gregorian
    cal.firstWeekday = calendarWeekStartDay
    return Region(calendar: cal, zone: SwiftDate.defaultRegion.timeZone, locale: SwiftDate.defaultRegion.locale)
}


public struct DatePickerConfig {
    
    public let font: UIFont
    public let mode: DatePickerMode
    public let userRegion: Region
    
    public let minDate: Date?
    public let maxDate: Date?
    // MARK: These properties are needed for further customization.
    let viewConfiguration: DatePickerViewConfiguration
    
    public init(font: UIFont = UIFont.systemFont(ofSize: 10),
                mode: DatePickerMode = .monthly,
                userRegion: Region = Region.current,
                minDate: Date?,
                maxDate: Date?,
                viewConfiguration: DatePickerViewConfiguration = .init()) {
        self.font = font
        self.mode = mode
        self.userRegion = userRegion
        self.viewConfiguration = viewConfiguration
        self.minDate = minDate
        self.maxDate = maxDate
    }
}

extension DatePickerConfig {
    public init(font: UIFont = .systemFont(ofSize: 10),
                mode: DatePickerMode = .monthly,
                userRegion: Region = Region.current,
                viewConfiguration: DatePickerViewConfiguration = .init()) {
        self.font = font
        self.mode = mode
        self.userRegion = userRegion
        self.viewConfiguration = viewConfiguration
        self.minDate = nil
        self.maxDate = nil
    }
    
    static let standard: Self = .init()
    
    mutating func switchTo(_ mode: DatePickerMode) {
        
        self = DatePickerConfig(font: self.font,
                                mode: mode,
                                userRegion: self.userRegion,
                                minDate: self.minDate,
                                maxDate: self.maxDate,
                                viewConfiguration: self.viewConfiguration)
    }
    
    func isDateInBounds(_ date: Date) -> Bool {
        
        if let minDate = self.minDate, date.isBeforeDate(minDate, granularity: .day) {
            return false
        } else if let maxDate = self.maxDate, date.isAfterDate(maxDate, granularity: .day) {
            return false
        } else {
            return true
        }
    }
}

public enum PickerHighlightMode {
    case highlighted
    case circled
}

public struct DatePickerViewConfiguration {
    
    let weekDayTitleMode: WeekDayTitleMode
    let monthTitleStyle: SymbolFormatStyle
    let pickerTitleMode: PickerTitleMode
    let shouldDisplayCurrentYearOnMonthTitle: Bool
    let shouldSelectNextDateOnSwipe: Bool
    let todayHighlightMode: PickerHighlightMode
    let selectedDateHighlightMode: PickerHighlightMode
    let shouldDimWeekends: Bool
    let nonActiveMonthDateMode: ComponentVisibilityMode
    let shouldHighlightCurrentWeekday: Bool
    
    public init(weekDayTitleMode: WeekDayTitleMode = .short,
                monthTitleStyle: SymbolFormatStyle = .default,
                pickerTitleMode: PickerTitleMode = .monthNameWithTodayButton,
                shouldDisplayCurrentYearOnMonthTitle: Bool = false,
                shouldSelectNextDateOnSwipe: Bool = true,
                todayHighlightMode: PickerHighlightMode = .circled,
                selectedDateHighlightMode: PickerHighlightMode = .circled,
                shouldDimWeekends: Bool = false,
                nonActiveMonthDateMode: ComponentVisibilityMode = .hidden,
                shouldHighlightCurrentWeekday: Bool = false)
    {
        
        self.weekDayTitleMode = weekDayTitleMode
        self.monthTitleStyle = monthTitleStyle
        self.pickerTitleMode = pickerTitleMode
        self.shouldDisplayCurrentYearOnMonthTitle = shouldDisplayCurrentYearOnMonthTitle
        self.shouldSelectNextDateOnSwipe = shouldSelectNextDateOnSwipe
        self.todayHighlightMode = todayHighlightMode
        self.selectedDateHighlightMode = selectedDateHighlightMode
        self.shouldDimWeekends = shouldDimWeekends
        self.nonActiveMonthDateMode = nonActiveMonthDateMode
        self.shouldHighlightCurrentWeekday = shouldHighlightCurrentWeekday
    }
    
    static var standard: Self = .init()
}

public enum DatePickerMode {
    case weekly, monthly
}

public enum ComponentVisibilityMode {
    case hidden
    case dimmed
    case normal
}

public enum WeekDayTitleMode {
    case singleLetter
    case twoLetter
    case short
    case full
    
    func weekDayString(forDay day: Int) -> String {
        switch day {
        case 1:
            return self == .short ? "SUN" : self == .full ? "SUNDAY": self == .twoLetter ? "SU" :  "S"
        case 2:
            return self == .short ? "MON" : self == .full ? "MONDAY": self == .twoLetter ? "MO" :  "M"
        case 3:
            return self == .short ? "TUE" : self == .full ? "TUESDAY": self == .twoLetter ? "TU" :  "T"
        case 4:
            return self == .short ? "WED" : self == .full ? "WEDNESDAY": self == .twoLetter ? "WE" :  "W"
        case 5:
            return self == .short ? "THU" : self == .full ? "THURSDAY": self == .twoLetter ? "TH" :  "T"
        case 6:
            return self == .short ? "FRI" : self == .full ? "FRIDAY": self == .twoLetter ? "FR" :  "F"
        case 7:
            return self == .short ? "SAT" : self == .full ? "SATURDAY": self == .twoLetter ? "SA" :  "S"
        default:
            return ""
        }
    }
}

public enum PickerTitleMode {
    case none
    case monthName
    case monthNameWithTodayButton
    case monthNameWithNavButtons
}
