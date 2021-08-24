//
//  MonthPickerViewController.swift
//  AnywhereCalendarSDK
//
//  Created by Vignesh on 30/09/20.
//

import Foundation
import SwiftDate
#if canImport(CalendarUtils)
    @testable import CalendarUtils
#endif

class DatePickerModel: NSObject {
    var dates: [Date] = []
    var mode: DatePickerMode = .monthly

    init(with date: Date, mode: DatePickerMode) {
        super.init()
        initializeMonthPicker(withDate: date, mode: mode)
    }

    func initializeMonthPicker(withDate date: Date = Date(), mode: DatePickerMode = .monthly) {
//        let userDate = date.in(region: userDefaultRegion).date
        let userDate = date
        let calendarStartDate: Date
        let calendarEndDate: Date

        switch mode {
        case .monthly:
            let startDate = DateUtilities.monthStartDate(for: userDate)
            let endDate = DateUtilities.monthEndDate(for: userDate)
            calendarStartDate = DateUtilities.pickerStartDate(from: startDate)
            calendarEndDate = DateUtilities.pickerEndDate(from: calendarStartDate, monthEndDate: endDate)
        case .weekly:
            calendarStartDate = DateUtilities.weekStartDate(for: date)
            calendarEndDate = DateUtilities.weekEndDate(for: date)
        }
        dates = DateUtilities.getListOfDatesBetween(calendarStartDate, and: calendarEndDate)
    }
}
