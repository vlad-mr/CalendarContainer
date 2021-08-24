//
//  AnywhereCalendar.swift
//  AnywhereCalendarView
//
//  Created by Vignesh on 07/07/20.
//  Copyright © 2020 FullCreative Pvt Ltd. All rights reserved.
//

import Foundation
import UIKit
import SwiftDate
#if canImport(CalendarUtils)
import CalendarUtils
#endif

public class AnywhereCalendarView {
    
    static var mainSDK: FullCalendars! = {
        
        return FullCalendars(withConfiguration: CalendarConfiguration(), theme: .Light, font: .systemFont(ofSize: 11))
    }()
    
    public static func configure(withConfiguration config: CalendarConfiguration, theme: CalendarTheme = .Light, font: UIFont = .systemFont(ofSize: 11)) {
        let fullCalendar = FullCalendars(withConfiguration: config, theme: theme, font: font)
        updateUserRegion(config.userRegion)
        mainSDK = fullCalendar
    }
    
    public static func updateUserRegion(_ region: Region) {
        SwiftDate.defaultRegion = region
    }
    
    static var weeklyCalendar: CalendarView?
    static var dailyCalendar: CalendarView?
    static var threeDayCalendar: CalendarView?
    static var customCalendar: CalendarView?
    static var scheduleView: CalendarView?
    
    public static func getWeeklyCalendar(withConfiguration config: CalendarViewConfiguration, dataProvider: CalendarDataProvider, actionDelegate: CalendarActionDelegate?) -> CalendarView {
        guard let weeklyCal = weeklyCalendar else {
            weeklyCalendar = mainSDK.getCalendarView(forLayoutType: .weekly, withConfiguration: config, dataProvider: dataProvider, actionDelegate: actionDelegate)
            return weeklyCalendar!
        }
        return weeklyCal
    }
    
    public static func getThreeDayCalendar(withConfiguration config: CalendarViewConfiguration, dataProvider: CalendarDataProvider, actionDelegate: CalendarActionDelegate?) -> CalendarView {
        
        guard let threeDayCal = threeDayCalendar else {
            threeDayCalendar = mainSDK.getCalendarView(forLayoutType: .threeDay, withConfiguration: config, dataProvider: dataProvider, actionDelegate: actionDelegate)
            return threeDayCalendar!
        }
        return threeDayCal
    }
    
    public static func getDailyCalendar(withConfiguration config: CalendarViewConfiguration, dataProvider: CalendarDataProvider, actionDelegate: CalendarActionDelegate?) -> CalendarView {
        
        guard let dailyCal = dailyCalendar else {
            
            dailyCalendar = mainSDK.getCalendarView(forLayoutType: .daily, withConfiguration: config, dataProvider: dataProvider, actionDelegate: actionDelegate)
            return dailyCalendar!
        }
        return dailyCal
    }
    
    public static func getScheduleView(withConfig scheduleConfig: ScheduleViewConfiguration = ScheduleViewConfiguration(), placeholderView: ActionableView? = nil, dimension: ScheduleViewDimensions = ScheduleViewDimensions()) -> CalendarView {
        
        guard let scheduleView = self.scheduleView else {
            self.scheduleView = mainSDK.getScheduleView(withConfiguration: scheduleConfig, placeholderView: placeholderView, dimension: dimension)
            return self.scheduleView!
        }
        return scheduleView
    }
    
    public static func getCustomCalendarView(forNumberOfDays numberOfDays: Int, withConfiguration config: CalendarViewConfiguration, dataProvider: CalendarDataProvider, actionDelegate: CalendarActionDelegate?) -> CalendarView {
        
        guard numberOfDays > 0 else {
            preconditionFailure("Unable to generate a calendar with 0 number of days")
        }
        guard let customCal = customCalendar else {
            
            customCalendar = mainSDK.getCalendarView(forLayoutType: .custom(numberOfDays), withConfiguration: config, dataProvider: dataProvider, actionDelegate: actionDelegate)
            return customCalendar!
        }
        return customCal
    }
    
    public static func getIntraEventsByDate(originalEvents: [CalendarItem]) -> [Date: [CalendarItem]] {
        
        var resultEvents = [Date: [CalendarItem]]()
        originalEvents.forEach {
            let spanningDays = DateUtilities.numberOfDaysBetween($0.startDate, and: $0.endDate)
            guard spanningDays == 0 else {
                computeCrossDayEvents(withOriginalEvent: $0, spanningDays: spanningDays, result: &resultEvents)
                return
            }
            if resultEvents[$0.startDate.dateAt(.startOfDay)] == nil {
                resultEvents[$0.startDate.dateAt(.startOfDay)] = []
            }
            let event = verifyCalendarItemForAllDayEvent($0)
            resultEvents[$0.startDate.dateAt(.startOfDay)]?.append(event)
        }
        return resultEvents
    }
    
    private static func verifyCalendarItemForAllDayEvent(_ originalEvent: CalendarItem) -> CalendarItem {
        guard originalEvent.startDate == originalEvent.startDate.dateAt(.startOfDay), originalEvent.endDate == originalEvent.endDate.dateAt(.endOfDay) else {
            return originalEvent
        }
        var event = originalEvent
        event.isAllDay = true
        return event
    }
    
    private static func computeCrossDayEvents(withOriginalEvent originalEvent: CalendarItem, spanningDays: Int, result: inout [Date: [CalendarItem]]) {
        
        for day in 0...spanningDays {
            let currentStartDate = originalEvent.startDate.add(component: .day, value: day)
            if result[currentStartDate.dateAt(.startOfDay)] == nil {
                result[currentStartDate.dateAt(.startOfDay)] = []
            }
            var newEvent = originalEvent
            
            switch day {
            case 0:
                newEvent.endDate = originalEvent.startDate.dateAt(.endOfDay)
                newEvent.isAllDay = newEvent.startDate == originalEvent.startDate.dateAt(.startOfDay)
            case spanningDays:
                newEvent.startDate = currentStartDate.dateAt(.startOfDay)
                newEvent.isAllDay = newEvent.endDate == originalEvent.endDate.dateAt(.endOfDay)
            default:
                newEvent.startDate = currentStartDate.dateAt(.startOfDay)
                newEvent.endDate = currentStartDate.dateAt(.endOfDay)
                newEvent.isAllDay = true
            }
            result[currentStartDate.dateAt(.startOfDay)]?.append(newEvent)
        }
    }
}
