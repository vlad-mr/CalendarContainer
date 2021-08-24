//
//  CalendarLayoutViewController+FullCalendarView.swift
//  AnywhereCalendarSDK
//
//  Created by Vignesh on 18/08/20.
//

import UIKit

extension CalendarLayoutViewController: FullCalendarView {
    public func dequeueReusableCell(withReuseIdentifier identifier: String, for indexPath: IndexPath) -> ConfigurableCell? {
        calendarCollectionView.dequeueReusableCell(withReuseIdentifier: identifier, for: indexPath) as? ConfigurableCell
    }

    public func register(_ nib: UINib?, forCellWithReuseIdentifier identifier: String) {
        calendarCollectionView.register(nib, forCellWithReuseIdentifier: identifier)
    }

    public func register(_ cellClass: AnyClass?, forCellWithReuseIdentifier identifier: String) {
        guard let cell = cellClass as? ConfigurableCollectionCell.Type else {
            return
        }
        calendarCollectionView.register(cell, forCellWithReuseIdentifier: identifier)
    }

    public func register(_ viewType: ConfigurableView.Type, forHeaderFooterViewReuseIdentifier identifier: String) {
        calendarCollectionView.register(viewType.self, forSupplementaryViewOfKind: identifier, withReuseIdentifier: identifier)
    }

    public func register(_ nibType: CalendarHeaderFooterNib.Type, forHeaderFooterViewReuseIdentifier identifier: String) {
        calendarCollectionView.register(nibType.getNib(), forSupplementaryViewOfKind: identifier, withReuseIdentifier: identifier)
    }

    public func dequeueReusableHeaderFooterView(withReuseIdentifier _: String, for _: Int) -> ConfigurableView? {
        guard let headerNib = customizationProvider.headerFooterNibs.first?.getNib() else {
            return nil
        }
        return headerNib.instantiate(withOwner: nil, options: nil).first as? ConfigurableView
    }

    public func reloadCalendar() {
        reloadView()
    }

    public func insertItems(at indexPaths: [IndexPath]) {
        calendarCollectionView.insertItems(at: indexPaths)
    }

    public func deleteItems(at indexPaths: [IndexPath]) {
        calendarCollectionView.deleteItems(at: indexPaths)
    }

    public func reloadItems(at indexPaths: [IndexPath]) {
        calendarCollectionView.reloadItems(at: indexPaths)
    }

    public func moveItem(from indexPath: IndexPath, to newIndexPath: IndexPath) {
        deleteItems(at: [indexPath])
        insertItems(at: [newIndexPath])
    }

    public func performBatchUpdates(_ updates: (() -> Void)?, completion: ((Bool) -> Void)? = nil) {
        calendarCollectionView.performBatchUpdates(updates, completion: completion)
        adjustHeaderView()
    }
}
