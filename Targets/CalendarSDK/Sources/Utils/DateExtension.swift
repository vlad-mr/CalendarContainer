//
//  DateExtension.swift
//  AnywhereCalendarSDK
//
//  Created by Vignesh on 11/03/21.
//

import Foundation
import SwiftDate

public extension String {
    
    var isNotEmpty: Bool {
        return !isEmpty
    }
}

public extension Date {
    
    var dayString: String {
        return "\(self.day)"
    }
    
    func timeString(inTimezone timezone: TimeZone? = nil) -> String {
        let timeStringFormat = uses12HourFormat() ? DateUtilities.twelveHourTimeStringFormat : DateUtilities.twentyFourHourTimeStringFormat
        guard let timezone = timezone, timezone != TimeZone.autoupdatingCurrent else {
            return self.toString(.custom(timeStringFormat))
        }
        let region = Region(calendar: Calendar.current, zone: timezone, locale: Locale.current)
        return self.in(region: region).toString(.custom(timeStringFormat))
    }
}

public extension Date {
    var millisec: Double {
        return Double(milliseconds)
    }
    
    var milliseconds: Int {
        return Int(self.timeIntervalSince1970 * 1000)
    }
    
    var timeInMinutes: Int {
        return (self.hour * 60) + self.minute
    }
    
    func uses12HourFormat() -> Bool {
        let locale = Locale.current
        let dateFormat = DateFormatter.dateFormat(fromTemplate: "j", options: 0, locale: locale)!
        if dateFormat.range(of: "a") != nil {
            return true
        } else {
            return false
        }
    }
    
    func isInSameMonthAs(_ date: Date) -> Bool {
        guard self.year == date.year else {
            return false
        }
        return self.month == date.month
    }
    
    
    // TEMP CHANGE DUE TO AN ISSUE IN SWIFT DATE
    internal func isInSameWeekAs(_ date: Date) -> Bool {
        //        guard self.year == date.year else {
        //            return false
        //        }
        //        return self.weekOfYear == date.weekOfYear
        return self.weekStartDate == date.weekStartDate
    }
    
    var weekStartDate: Date {
        return self.calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: self.dateAt(.startOfDay))) ?? Date()
    }
    
    var weekEndDate: Date {
        self.weekStartDate.dateByAdding(6, .day).date
    }
    
    var weekOfMonth: Int {
        return self.calendar
            .dateComponents([.weekOfMonth, .day, .weekday, .calendar, .weekOfYear, .month, .year], from: self).weekOfMonth ?? 0
    }
}

public extension Calendar {
    static var gregorian: Self {
        Calendar(identifier: .gregorian)
    }
}
