//
//  FullCalendarView.swift
//  AnywhereCalendarView
//
//  Created by Vignesh on 23/06/20.
//  Copyright © 2020 FullCreative Pvt Ltd. All rights reserved.
//

import UIKit

public protocol FullCalendarView {
    func reloadCalendar()
    func insertItems(at indexPaths: [IndexPath])
    func deleteItems(at indexPaths: [IndexPath])
    func reloadItems(at indexPaths: [IndexPath])
    func moveItem(from indexPath: IndexPath, to newIndexPath: IndexPath)
    func performBatchUpdates(_ updates: (() -> Void)?, completion: ((Bool) -> Void)?)
    func beginUpdates()
    func endUpdates()
    func scrollToDate(date: Date)
    func insertSection(at section: Int)
    func deleteSection(at section: Int)
    func reloadSection(at section: Int)

    // Getting a cell
    func dequeueReusableCell(withReuseIdentifier identifier: String, for indexPath: IndexPath) -> ConfigurableCell?
    func register(_ nib: UINib?, forCellWithReuseIdentifier identifier: String)
    func register(_ cellClass: AnyClass?, forCellWithReuseIdentifier identifier: String)

    /// To register the header and footer views for the calendar
    func register(_ viewType: ConfigurableView.Type, forHeaderFooterViewReuseIdentifier identifier: String)
    func register(_ nibType: CalendarHeaderFooterNib.Type, forHeaderFooterViewReuseIdentifier identifier: String)
    func dequeueReusableHeaderFooterView(withReuseIdentifier identifier: String, for section: Int) -> ConfigurableView?
}

public extension FullCalendarView {
    func beginUpdates() {}

    func endUpdates() {}

    func insertItems(at _: [IndexPath]) {}

    func deleteItems(at _: [IndexPath]) {}

    func scrollToDate(date _: Date) {}

    func moveItem(from _: IndexPath, to _: IndexPath) {}

    func insertSection(at _: Int) {}

    func deleteSection(at _: Int) {}

    func reloadSection(at _: Int) {}

    func register(_: ConfigurableView.Type, forHeaderFooterViewReuseIdentifier _: String) {}
    func register(_: CalendarHeaderFooterNib.Type, forHeaderFooterViewReuseIdentifier _: String) {}

    func dequeueReusableHeaderFooterView(withReuseIdentifier _: String, for _: Int) -> ConfigurableView? {
        return nil
    }

    func performBatchUpdates(_: (() -> Void)?, completion _: ((Bool) -> Void)?) {}
}
