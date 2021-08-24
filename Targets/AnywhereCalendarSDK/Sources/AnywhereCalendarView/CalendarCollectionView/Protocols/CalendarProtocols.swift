//
//  CalendarProtocols.swift
//  AnywhereCalendarView
//
//  Created by Vignesh on 08/06/20.
//  Copyright © 2020 FullCreative Pvt Ltd. All rights reserved.
//

import Foundation
import UIKit
#if canImport(CalendarUtils)
    import CalendarUtils
#endif

public protocol CalendarActionDelegate: class {
    func didSelectCell(for item: CalendarItem)
    func didTapCalendar(on date: Date, atTime timeInMins: Int, duration: Int, notifyCompletion: @escaping () -> Void)
    func didTapOffHours(on date: Date, atTime timeInMins: Int)
    func didScroll(toDate date: Date)
    func didSwipeToCalendar(withDates dates: [Date])
    func showError(_ alertText: String)
    func refreshContent()

    /// This method helps to configure any kind of action for the actionableView
    /// - Parameters:
    ///   - identifier: identifier for the action that has to performed
    ///   - section: index of the section
    func executeAction(withIdentifier identifier: String, at section: Int)

    /// This method helps to configure any kind of action for the actionable view
    /// - Parameters:
    ///   - identifier: identifier for the action
    ///   - indexPath: indexPath of the cell
    /*
     For example if we want to duplicate a event on long press we can acheive with this method.
     */
    func executeAction(withIdentifier identifier: String, at indexPath: IndexPath)
}

public extension CalendarActionDelegate {
    func didTapOffHours(on _: Date, atTime _: Int) {}
    func didSwipeToCalendar(withDates _: [Date]) {}
    func showError(_: String) {}
    func refreshContent() {}
    func executeAction(withIdentifier _: String, at _: Int) {}
    func executeAction(withIdentifier _: String, at _: IndexPath) {}
    func didScroll(toDate _: Date) {}
}

protocol CalendarLayoutDelegate: class {
    var calendarScrollOffset: CGPoint? { get }
    func calendarViewDidScroll(_ scrollView: UIScrollView)
}

public enum CalendarLayoutType: Equatable {
    case daily, weekly, threeDay, custom(_: Int)

    var numberOfDays: Int {
        switch self {
        case .daily:
            return 1
        case .weekly:
            return 7
        case .threeDay:
            return 3
        case let .custom(days):
            return days
        }
    }
}

public protocol CalendarDataProvider {
    func getCustomizationProvider(for calendarView: FullCalendarView) -> FullCalendarCustomizationProvider?
    func getDataSource(forPage page: Int) -> FullCalendarDataSource?
}

public protocol FullCalendarDataSource: class {
    /*
     The Data Source can be initialized with the activeDates or the Page number
     If we get the dates, we can get the items for each date. Instead of completely depending on the application
     */
    var activeCalendarView: FullCalendarView? { get set }

    var activeDates: [Date] { get }

    var numberOfCalendarItems: Int { get }

    func getCalendarItems(forSection section: Int) -> [CalendarItem]

    func numberOfItems(inSection section: Int) -> Int

    func getAvailability(forSection section: Int) -> [WorkingHour]

    func shouldShowDayOff(forSection section: Int) -> Bool

    func getAllDayEvents(forSection section: Int) -> [CalendarItem]
}

public extension FullCalendarDataSource {
    var numberOfCalendarItems: Int {
        return 0
    }

    func getAvailability(forSection _: Int) -> [WorkingHour] {
        return [WorkingHour(start: 540, end: 1439)]
    }

    func shouldShowDayOff(forSection _: Int) -> Bool {
        false
    }

    func getAllDayEvents(forSection _: Int) -> [CalendarItem] {
        return []
    }
}

public protocol CalendarCellNib: ReusableNib, ConfigurableCell {}

public protocol CalendarHeaderFooterNib: ReusableNib, ConfigurableView {}

public protocol ActionableView: ReusableView {
    var actionDelegate: CalendarActionDelegate? { get set }
}

public protocol ConfigurableView: ActionableView {
    var section: Int { get set }
    func configure(_ date: Date, at section: Int)
}

public extension ConfigurableView {
    var actionDelegate: CalendarActionDelegate? {
        get {
            return nil
        }
        set {
            print("Default Implementation")
        }
    }
}

public protocol ConfigurableAllDayEventView: ActionableView, Initializable {
    var item: CalendarItem? { get set }
    func configure(withEvent item: CalendarItem)
    func configure(withTitle title: String)
}

public protocol ConfigurableAllDayEventNib: ReusableNib, ConfigurableAllDayEventView {}

public protocol ConfigurableCell: ReusableView {
    func configure(_ item: CalendarItem, at indexPath: IndexPath)
}

typealias ConfigurableCollectionCell = ConfigurableCell & UICollectionViewCell
typealias ConfigurableTableViewCell = ConfigurableCell & UITableViewCell
typealias ConfigurableHeaderFooterView = ConfigurableView & UITableViewHeaderFooterView
public typealias TappableAllDayEventView = ConfigurableAllDayEventView & TappableView
public typealias TappableAllDayEventNib = ConfigurableAllDayEventNib & TappableView

public protocol Tappable {
    var action: (() -> Void)? { get set }
}

protocol CalendarCollectionViewLayoutDelegate: class {
    var indexForCurrentTimeLine: Int? { get }
    func userAvailability(forSection section: Int) -> [WorkingHour]
}

extension Tappable where Self: TappableAllDayEventView {
    func tapAction() {
        guard let calendarItem = item else {
            return
        }
        actionDelegate?.didSelectCell(for: calendarItem)
    }
}

protocol CalendarPageDelegate {
    var calendarScrollOffSet: CGPoint { get }
    var numberOfDaysPerLayout: Int { get }

    func reloadTimeHeader()

    func didSelectItem(_ calendarItem: CalendarItem)
    func didTapView(on date: Date, atTime timeInMins: Int, for duration: Int)
    func setTimeHeaderScrollViewOffset(to calendarCollectionViewOffset: CGPoint)
}
