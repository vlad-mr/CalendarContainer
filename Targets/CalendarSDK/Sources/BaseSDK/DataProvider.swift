//
//  Data Provider.swift
//  AnywhereCalendarSDK
//
//  Created by Vignesh on 15/09/20.
//

import Foundation
#if canImport(AnywhereCalendarViewSDK)
@_exported import AnywhereCalendarViewSDK
#endif

public protocol AnywhereCalendarDataProvider {
    func getCustomizationProvider(for calendarView: FullCalendarView) -> FullCalendarCustomizationProvider?
    func getDataSource(forPage page: Int) -> AnyCalDataSource?
}

class CalendarBaseDataProvider: CalendarDataProvider {
    
    var dataProvider: AnywhereCalendarDataProvider
    
    init(withAnyCalDataProvider dataProvider: AnywhereCalendarDataProvider) {
        self.dataProvider = dataProvider
    }
    
    func getCustomizationProvider(for calendarView: FullCalendarView) -> FullCalendarCustomizationProvider? {
        dataProvider.getCustomizationProvider(for: calendarView)
    }
    
    func getDataSource(forPage page: Int) -> FullCalendarDataSource? {
        guard let dataSourceFromApp = dataProvider.getDataSource(forPage: page) else {
            return nil
        }
        return AnywhereCalBaseDataSource(withDataSource: dataSourceFromApp)
    }
}
