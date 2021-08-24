//
//  DataSource.swift
//  AnywhereCalendarSDK
//
//  Created by Vignesh on 08/09/20.
//

import Foundation
#if canImport(AnywhereCalendarViewSDK)
    @_exported import AnywhereCalendarViewSDK
#endif

class AnywhereCalBaseDataSource: FullCalendarDataSource {
    var activeCalendarView: FullCalendarView?
    var anyCalDataSource: AnyCalDataSource
    var activeDates: [Date]

    init(withDataSource dataSource: AnyCalDataSource) {
        anyCalDataSource = dataSource
        activeDates = anyCalDataSource.activeDates.compactMap {
            Date(fromString: $0)
        }
    }

    func getCalendarItems(forSection section: Int) -> [CalendarItem] {
        anyCalDataSource.getCalendarItems(forSection: section).filter {
            !$0.isAllDay
        }
    }

    var numberOfCalendarItems: Int {
        var numberOfItems = 0
        for section in 0 ..< activeDates.count {
            numberOfItems += anyCalDataSource.numberOfItems(inSection: section)
        }
        return numberOfItems
    }

    func numberOfItems(inSection section: Int) -> Int {
        anyCalDataSource.numberOfItems(inSection: section)
    }

    func getAllDayEvents(forSection section: Int) -> [CalendarItem] {
        anyCalDataSource.getCalendarItems(forSection: section).filter {
            $0.isAllDay
        }
    }

    func shouldShowDayOff(forSection section: Int) -> Bool {
        anyCalDataSource.shouldShowDayOff(forSection: section)
    }

    func getAvailability(forSection section: Int) -> [WorkingHour] {
        anyCalDataSource.getAvailability(forSection: section)
    }
}
