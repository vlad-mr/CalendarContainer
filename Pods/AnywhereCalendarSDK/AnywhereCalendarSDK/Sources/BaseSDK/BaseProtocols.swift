//
//  BaseProtocols.swift
//  AnywhereCalendarSDK
//
//  Created by Vignesh on 07/09/20.
//

import Foundation
#if canImport(AnywhereCalendarViewSDK)
@_exported import AnywhereCalendarViewSDK
#endif

public protocol AnyCalDataSource {
    
    var calendarView: FullCalendarView? { get set }
    
    var activeDates: [String] { get }
    
    func getCalendarItems(forSection section: Int) -> [CalendarItem]
    
    func numberOfItems(inSection section: Int) -> Int
    
    func getAvailability(forSection section: Int) -> [WorkingHour]
    
    func shouldShowDayOff(forSection section: Int) -> Bool
}
