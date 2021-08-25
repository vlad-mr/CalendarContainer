//
//  DateUtilities.swift
//  AnywhereCalendarSDK
//
//  Created by Vignesh on 03/02/21.
//

import Foundation
import SwiftDate

public struct DateUtilities {
    
    public static var timeFormat: TimeFormat = .deviceSetting
    
    public static func monthStartDate(for date: Date) -> Date {
        
        date.dateAt(.startOfMonth).dateAt(.startOfDay)
    }
    
    public static func monthEndDate(for date: Date) -> Date {
        
        return date.dateAt(.endOfMonth).dateAt(.endOfDay)
    }
    
    public static func weekStartDate(for date: Date) -> Date {
        
        date.weekStartDate
    }
    
    public static func weekEndDate(for date: Date) -> Date {
        date.weekEndDate
    }
    
    public static func pickerStartDate(from monthStartDate: Date) -> Date {
        
        return monthStartDate.weekStartDate
    }
    
    public static func pickerEndDate(from pickerStartDate: Date, monthEndDate: Date) -> Date {
        
        let totalAvailableDates = numberOfDaysBetween(pickerStartDate, and: monthEndDate) + 1  // returns 1 day less so adding one day into it.
        var remainingDatesToAdd: Int = 0
        
        if totalAvailableDates < 35 {
            remainingDatesToAdd = 35 - totalAvailableDates
        } else if totalAvailableDates < 42 {
            remainingDatesToAdd = 42 - totalAvailableDates
        }
        let endDateToReturn = monthEndDate.dateByAdding(remainingDatesToAdd, .day).date
        
        return endDateToReturn
    }
    
    public static func numberOfDaysBetween(_ fromDate: Date, and toDate: Date) -> Int {
        toDate.difference(in: .day, from: fromDate) ?? 0
    }

    public static func getListOfDatesBetween(_ startDate: Date, and endDate: Date) -> [Date] {
        
        //startDate.isAfter(date: endDate, granularity: .minute)
        guard !startDate.isAfterDate(endDate, granularity: .minute) else {
            return []
        }
        var tempDate = startDate
        var datesList: [Date] = []
        
        //!endDate.isInSameDayOf(date: tempDate)
        while !endDate.compare(.isSameDay(tempDate)) {
            datesList.append(tempDate)
            tempDate = tempDate.dateByAdding(1, .day).date
        }
        datesList.append(tempDate)
        return datesList
    }
}

public extension DateUtilities {
    
    static let twelveHourTimeStringFormat = "h:mm aa"
    static let twentyFourHourTimeStringFormat = "HH:mm"
    
    static func getTimeString(_ hours: Int) -> String {
        
        guard timeFormat.is12HourFormat else {
            return "\(hours):00"
        }
        if hours > 12 {
            return String(hours-12)+" PM"
        } else if hours < 12 {
            return String(hours)+" AM"
        } else {
            return String(hours)+" PM"
        }
    }
}
