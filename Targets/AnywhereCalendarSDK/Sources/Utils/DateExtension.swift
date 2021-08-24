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
        return "\(day)"
    }

    func timeString(inTimezone timezone: TimeZone? = nil) -> String {
        let timeStringFormat = uses12HourFormat() ? DateUtilities.twelveHourTimeStringFormat : DateUtilities.twentyFourHourTimeStringFormat
        guard let timezone = timezone, timezone != TimeZone.autoupdatingCurrent else {
            return toString(.custom(timeStringFormat))
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
        return Int(timeIntervalSince1970 * 1000)
    }

    var timeInMinutes: Int {
        return (hour * 60) + minute
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
        guard year == date.year else {
            return false
        }
        return month == date.month
    }

    // TEMP CHANGE DUE TO AN ISSUE IN SWIFT DATE
    internal func isInSameWeekAs(_ date: Date) -> Bool {
        //        guard self.year == date.year else {
        //            return false
        //        }
        //        return self.weekOfYear == date.weekOfYear
        return weekStartDate == date.weekStartDate
    }

    var weekStartDate: Date {
        return calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: dateAt(.startOfDay))) ?? Date()
    }

    var weekEndDate: Date {
        weekStartDate.dateByAdding(6, .day).date
    }

    var weekOfMonth: Int {
        return calendar
            .dateComponents([.weekOfMonth, .day, .weekday, .calendar, .weekOfYear, .month, .year], from: self).weekOfMonth ?? 0
    }
}

public extension Calendar {
    static var gregorian: Self {
        Calendar(identifier: .gregorian)
    }
}
