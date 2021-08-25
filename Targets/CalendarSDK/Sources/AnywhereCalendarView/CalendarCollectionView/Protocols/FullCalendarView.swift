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
    
    func insertItems(at indexPaths: [IndexPath]) {}
    
    func deleteItems(at indexPaths: [IndexPath]) {}
    
    func scrollToDate(date: Date) {}
    
    func moveItem(from indexPath: IndexPath, to newIndexPath: IndexPath) {}
    
    func insertSection(at section: Int) {}
    
    func deleteSection(at section: Int) {}
    
    func reloadSection(at section: Int) {}
    
    func register(_ viewType: ConfigurableView.Type, forHeaderFooterViewReuseIdentifier identifier: String) {}
    func register(_ nibType: CalendarHeaderFooterNib.Type, forHeaderFooterViewReuseIdentifier identifier: String) {}
    
    func dequeueReusableHeaderFooterView(withReuseIdentifier identifier: String, for section: Int) -> ConfigurableView? {
        return nil
    }
    
    func performBatchUpdates(_ updates: (() -> Void)?, completion: ((Bool) -> Void)?) {
        
    }
    
}
