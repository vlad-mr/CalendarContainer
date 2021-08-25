//
//  PickerUtils.swift
//  AnywhereCalendarSDK
//
//  Created by Vignesh on 03/02/21.
//

import UIKit
#if canImport(CalendarUtils)
import CalendarUtils
#endif
import SwiftDate

struct PickerUtils {
    
    static var shouldDisplayCurrentYearOnMonthTitle: Bool = false
    static var monthTitleStyle: SymbolFormatStyle = .default
    
    public static func getHeaderTitle(forDate activeDate: Date, mode: DatePickerMode) -> String {
        
        let title: String
        switch mode {
        case .monthly:
            let monthStr = activeDate.monthName(monthTitleStyle)
            let yearStr = activeDate.year
            title = (activeDate.year == Date().year) && !shouldDisplayCurrentYearOnMonthTitle ? monthStr : monthStr + " " + yearStr.description
        case .weekly:
            let weekStart = activeDate.weekStartDate
            let weekEnd = activeDate.weekEndDate
            let monthStr = weekStart.monthName(monthTitleStyle)
            let yearStr = activeDate.year
            if weekEnd.month == activeDate.month && weekStart.month == activeDate.month {
                title = (weekStart.year == Date().year) && !shouldDisplayCurrentYearOnMonthTitle ? monthStr : monthStr + " " + yearStr.description
            } else {
                let nextMonthStr = weekEnd.monthName(monthTitleStyle)
                
                /// THIS RETURNS `MNT - MNT YYYY` instead
//                if weekEnd.year == activeDate.year {
//                    let monthTitle = "\(monthStr) - \(nextMonthStr)"
//                    title = (activeDate.year == Date().year) && !shouldDisplayCurrentYearOnMonthTitle ? monthTitle : monthTitle + " " + yearStr.description
//                } else {
                    title = "\(monthStr) \(weekStart.year) - \(nextMonthStr) \(weekEnd.year)"
//                }
            }
        }
        return title
    }
}

public protocol DatePickerTheme {
    
    var titleColor: UIColor { get set }
    var primaryColor: UIColor { get set }
    var secondaryColor: UIColor { get set }
    var holidayColor: UIColor { get set }
    var todayColor: UIColor { get set }
    var weekdayPrimaryColor: UIColor { get set }
    
    var selectedDateTintColor: UIColor { get set }
}

public struct AnywherePickerTheme: DatePickerTheme {
    
    public var titleColor: UIColor = .darkGray
    public var primaryColor: UIColor = .black
    public var secondaryColor: UIColor = .lightGray
    public var holidayColor: UIColor = .lightGray
    public var todayColor: UIColor = UIColor(red: 232/255, green: 244/255, blue: 254/255, alpha: 1)
    public var weekdayPrimaryColor: UIColor = .lightGray

    public var selectedDateTintColor: UIColor = UIColor(red: 0.113, green: 0.564, blue: 0.960, alpha: 1)

    public init() {
        
    }
}
