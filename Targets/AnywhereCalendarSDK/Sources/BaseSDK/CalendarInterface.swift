//
//  CalendarInterface.swift
//  AnywhereCalendarSDK
//
//  Created by Vignesh on 11/09/20.
//

import Foundation
@_exported import SwiftDate
#if canImport(AnywhereCalendarViewSDK)
@_exported import AnywhereCalendarViewSDK
#endif
import UIKit.UIFont

/* protoocl AnyCal {
 
 AnywhereCalendarView wrapper
 
 */

public class AnywhereCalendar {
    public static var calendarSDK: CalendarSDK.Type {
        return CalendarSDK.self
    }
}

public class CalendarSDK {
    
    static var viewSDK: AnywhereCalendarView.Type {
        return AnywhereCalendarView.self
    }
    
    public static func configure(withConfiguration config: CalendarConfiguration, theme: CalendarTheme = .Light, font: UIFont = .systemFont(ofSize: 11)) {
        viewSDK.configure(withConfiguration: config, theme: theme, font: font)
    }
    
    public static func updateUserRegion(_ region: Region) {
        viewSDK.updateUserRegion(region)
    }
}

extension CalendarSDK {
    
    public static func getWeeklyCalendar(withConfiguration config: CalendarViewConfiguration, dataProvider: AnywhereCalendarDataProvider, actionDelegate: AnyCalActionDelegate?) -> CalendarView {
        
        let baseDataProvider = CalendarBaseDataProvider(withAnyCalDataProvider: dataProvider)
        guard let baseActionDelegate = actionDelegate else {
            return viewSDK.getWeeklyCalendar(withConfiguration: config, dataProvider: baseDataProvider, actionDelegate: nil)
        }
        let actionDelegateInterface = AnyCalActionDelegateInterface(withBaseActionDelegate: baseActionDelegate)
        return viewSDK.getWeeklyCalendar(withConfiguration: config, dataProvider: baseDataProvider, actionDelegate: actionDelegateInterface)
    }
    
    public static func getThreeDayCalendar(withConfiguration config: CalendarViewConfiguration, dataProvider: AnywhereCalendarDataProvider, actionDelegate: AnyCalActionDelegate?) -> CalendarView {
        
        let baseDataProvider = CalendarBaseDataProvider(withAnyCalDataProvider: dataProvider)
        guard let baseActionDelegate = actionDelegate else {
            return viewSDK.getThreeDayCalendar(withConfiguration: config, dataProvider: baseDataProvider, actionDelegate: nil)
        }
        let actionDelegateInterface = AnyCalActionDelegateInterface(withBaseActionDelegate: baseActionDelegate)
        return viewSDK.getThreeDayCalendar(withConfiguration: config, dataProvider: baseDataProvider, actionDelegate: actionDelegateInterface)
    }
    
    public static func getDailyCalendar(withConfiguration config: CalendarViewConfiguration, dataProvider: AnywhereCalendarDataProvider, actionDelegate: AnyCalActionDelegate?) -> CalendarView {
        
        let baseDataProvider = CalendarBaseDataProvider(withAnyCalDataProvider: dataProvider)
        guard let baseActionDelegate = actionDelegate else {
            return viewSDK.getDailyCalendar(withConfiguration: config, dataProvider: baseDataProvider, actionDelegate: nil)
        }
        let actionDelegateInterface = AnyCalActionDelegateInterface(withBaseActionDelegate: baseActionDelegate)
        return viewSDK.getDailyCalendar(withConfiguration: config, dataProvider: baseDataProvider, actionDelegate: actionDelegateInterface)
    }
    
    
    public static func getCustomCalendarView(forNumberOfDays numberOfDays: Int, withConfiguration config: CalendarViewConfiguration, dataProvider: AnywhereCalendarDataProvider, actionDelegate: AnyCalActionDelegate?) -> CalendarView {
        
        let baseDataProvider = CalendarBaseDataProvider(withAnyCalDataProvider: dataProvider)
        guard let baseActionDelegate = actionDelegate else {
            return viewSDK.getCustomCalendarView(forNumberOfDays: numberOfDays, withConfiguration: config, dataProvider: baseDataProvider, actionDelegate: nil)
        }
        let actionDelegateInterface = AnyCalActionDelegateInterface(withBaseActionDelegate: baseActionDelegate)
        return viewSDK.getCustomCalendarView(forNumberOfDays: numberOfDays, withConfiguration: config, dataProvider: baseDataProvider, actionDelegate: actionDelegateInterface)
    }
    
    public static func getScheduleView(withConfig scheduleConfig: ScheduleViewConfiguration = ScheduleViewConfiguration(), placeholderView: ActionableView? = nil, dimension: ScheduleViewDimensions = ScheduleViewDimensions(), dataProvider: AnywhereCalendarDataProvider, actionDelegate: AnyCalActionDelegate?) -> CalendarView {
        
        let scheduleView = viewSDK.getScheduleView(withConfig: scheduleConfig, placeholderView: placeholderView, dimension: dimension)
        scheduleView.dataProvider = CalendarBaseDataProvider(withAnyCalDataProvider: dataProvider)
        if let baseActionDelegate = actionDelegate {
            scheduleView.actionDelegate = AnyCalActionDelegateInterface(withBaseActionDelegate: baseActionDelegate)
        }
        return scheduleView
    }
}

