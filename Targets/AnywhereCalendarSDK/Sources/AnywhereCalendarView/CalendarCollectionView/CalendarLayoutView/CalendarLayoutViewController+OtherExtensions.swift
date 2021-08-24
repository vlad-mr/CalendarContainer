//
//  CalendarLayoutViewController+OtherExtensions.swift
//  AnywhereCalendarSDK
//
//  Created by Vignesh on 18/08/20.
//

import UIKit

extension CalendarLayoutViewController {
    func date(forSection section: Int) -> Date? {
        guard let calendarDataSource = dataSource else {
            preconditionFailure("Calendar Data Source cannot be nil")
        }
        let dates = calendarDataSource.activeDates
        guard section < dates.count else {
            return nil
        }
        return dates[section]
    }

    func calendarItem(forIndexPath indexPath: IndexPath) -> CalendarItem? {
        let calendarItems = getCalendarItems(forSection: indexPath.section)
        guard indexPath.row < calendarItems.count else {
            return nil
        }
        return calendarItems[indexPath.row]
    }

    public func getCalendarItems(forSection section: Int) -> [CalendarItem] {
        guard let calendarItems = dataSource?.getCalendarItems(forSection: section) else {
            return []
        }
        return calendarItems
    }

    public func getCalendarCell(forItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let calendarCell = customizationProvider.dequeueCalendarCell(forIndexPath: indexPath) as? ConfigurableCollectionCell else {
            return UICollectionViewCell()
        }

        guard let calendarItem = calendarItem(forIndexPath: indexPath) else {
            return calendarCell
        }
        calendarCell.configure(calendarItem, at: indexPath)
        return calendarCell
    }
}
