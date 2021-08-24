//
//  ScheduleViewModel.swift
//  Anytime
//
//  Created by Deepika on 05/06/20.
//  Copyright © 2020 FullCreative Pvt Ltd. All rights reserved.
//

import Foundation

protocol ScheduleVMProtocol: class {
    var numberOfSections: Int { get }
    var canShowPlaceHolder: Bool { get }
    var viewConfiguration: ScheduleViewConfiguration { get set }

    func numberOfRows(at section: Int) -> Int
    func getDate(at section: Int) -> Date?
    func getCalendarItem(at indexPath: IndexPath) -> CalendarItem?
    func getSectionName(at section: Int) -> String
    func getCalendarItems(at section: Int) -> [CalendarItem]
    func getIndexPath(forDate date: Date, shouldGetLastRow: Bool) -> IndexPath?
    func canShowPlaceholder(forSection section: Int) -> Bool
}

class ScheduleViewModel: ScheduleVMProtocol {
    var calendarDatasource: FullCalendarDataSource
    var viewConfiguration: ScheduleViewConfiguration
    var numberOfSections: Int {
        let numberOfSections = calendarDatasource.activeDates.count
        return viewConfiguration.shouldAllowFreeScrollToBottom ? numberOfSections + 1 : numberOfSections
    }

    var canShowPlaceHolder: Bool {
        return calendarDatasource.numberOfCalendarItems == 0
    }

    init(calendarDatasource: FullCalendarDataSource, withConfig config: ScheduleViewConfiguration = .init()) {
        self.calendarDatasource = calendarDatasource
        viewConfiguration = config
    }

    func numberOfRows(at section: Int) -> Int {
        let numberOfItems = calendarDatasource.numberOfItems(inSection: section)
        if viewConfiguration.placeholderConfig != .weekly, numberOfItems == 0 {
            return 1
        }
        return numberOfItems
    }

    func getDate(at section: Int) -> Date? {
        guard section < calendarDatasource.activeDates.count else {
            return nil
        }
        return calendarDatasource.activeDates[section]
    }

    func getCalendarItem(at indexPath: IndexPath) -> CalendarItem? {
        let calendarItems = getCalendarItems(at: indexPath.section)
        guard indexPath.row < calendarItems.count else {
            return nil
        }
        return calendarItems[indexPath.row]
    }

    func getSectionName(at section: Int) -> String {
        return getDate(at: section)?.toString() ?? "" // need to verify this
    }

    func getCalendarItems(at section: Int) -> [CalendarItem] {
        guard section < calendarDatasource.activeDates.count else {
            return []
        }
        return calendarDatasource.getCalendarItems(forSection: section)
    }

    private func getSection(ofDate date: Date) -> Int? {
        return calendarDatasource.activeDates.firstIndex(of: date)
    }

    func getIndexPath(forDate date: Date, shouldGetLastRow: Bool) -> IndexPath? {
        let date = date.dateAt(.startOfDay)
        guard calendarDatasource.activeDates.contains(date), let sectionIndex = getSection(ofDate: date) else {
            return nil
        }

        let rowIndex = shouldGetLastRow ? numberOfRows(at: sectionIndex) : 0
        return IndexPath(row: rowIndex, section: sectionIndex)
    }

    func canShowPlaceholder(forSection section: Int) -> Bool {
        guard section < numberOfSections, viewConfiguration.placeholderConfig != .weekly else {
            return false
        }
        return calendarDatasource.numberOfItems(inSection: section) == 0
    }
}
