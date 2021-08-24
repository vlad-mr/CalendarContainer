//
//  ScheduleCRUDManager.swift
//  AnywhereCalendarView
//
//  Created by Deepika on 19/06/20.
//  Copyright © 2020 FullCreative Pvt Ltd. All rights reserved.
//

import Foundation
import UIKit

extension ScheduleBaseViewController {
    public func beginUpdates() {
        DispatchQueue.main.async {
            print("-----UPDATES FOR SCHEDULE VIEW HAS BEGUN-----")
            self.calendarItemView.beginUpdates()
            self.dateView.beginUpdates()
        }
    }

    public func endUpdates() {
        DispatchQueue.main.async {
            self.calendarItemView.endUpdates()
            self.dateView.endUpdates()
            self.togglePlaceholderIfNeeded()
            print("-----UPDATES FOR SCHEDULE VIEW HAS ENDED-----")
        }
    }

    public func insertSection(at section: Int) {
        print("--SCHEDULE VIEW: inserting section at index - \(section)")
        DispatchQueue.main.async {
            self.calendarItemView.insertSection(at: section)
            self.dateView.insertSection(at: section)
            print("--SCHEDULE VIEW: inserted section at index - \(section)")
        }
    }

    public func deleteSection(at section: Int) {
        print("--SCHEDULE VIEW: deleting section at index - \(section)")
        DispatchQueue.main.async {
            self.calendarItemView.deleteSection(at: section)
            self.dateView.deleteSection(at: section)
            print("--SCHEDULE VIEW: deleted section at index - \(section)")
        }
    }

    func insertCalendarItem(at indexPath: IndexPath) {
        print("--SCHEDULE VIEW: inserting row at index - \(indexPath)")
        DispatchQueue.main.async {
            self.calendarItemView.insertItems(at: [indexPath])
            if indexPath.row == 0, self.calendarItemView.numberOfSections > indexPath.section {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                    self.calendarItemView.reloadSection(at: indexPath.section)
                }
            }

            self.dateView.reloadItems(at: [IndexPath(row: 0, section: indexPath.section)])
            self.dateView.contentOffset = self.calendarItemView.contentOffset

            print("--SCHEDULE VIEW: inserted row at index - \(indexPath)")
        }
    }

    func updateCalendarItem(at indexPath: IndexPath) {
        print("--SCHEDULE VIEW: updating row at index - \(indexPath)")
        DispatchQueue.main.async {
            self.calendarItemView.reloadItems(at: [indexPath])
            print("--SCHEDULE VIEW: updated row at index - \(indexPath)")
        }
    }

    func deleteCalendarItem(at indexPath: IndexPath) {
        print("--SCHEDULE VIEW: deleting row at index - \(indexPath)")
        DispatchQueue.main.async {
            guard self.calendarItemView.numberOfSections > indexPath.section else {
                assertionFailure("Received invalid section index - \(indexPath.section), whereas actual number of section in the tableView is \(self.calendarItemView.numberOfSections) ")
                return
            }
            self.calendarItemView.deleteItems(at: [indexPath])
            self.dateView.reloadItems(at: [IndexPath(row: 0, section: indexPath.section)])
            self.dateView.contentOffset = self.calendarItemView.contentOffset
            print("--SCHEDULE VIEW: deleted row at index - \(indexPath)")
        }
    }

    func moveCalendarItem(from originalIndexPath: IndexPath, to updatedIndexPath: IndexPath) {
        print("----SCHEDULE VIEW: moving row from indexPath - \(originalIndexPath) to \(updatedIndexPath)")
        deleteCalendarItem(at: originalIndexPath)
        insertCalendarItem(at: updatedIndexPath)
        print("----SCHEDULE VIEW: moved row from indexPath - \(originalIndexPath) to \(updatedIndexPath)")
    }
}
