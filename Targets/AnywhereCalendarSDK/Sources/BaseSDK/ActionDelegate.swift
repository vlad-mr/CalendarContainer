//
//  ActionDelegate.swift
//  AnywhereCalendarSDK
//
//  Created by Vignesh on 18/09/20.
//

import Foundation
#if canImport(AnywhereCalendarViewSDK)
    @_exported import AnywhereCalendarViewSDK
#endif

public protocol AnyCalActionDelegate: class {
    func didSelectCell(for item: CalendarItem)
    func didTapCalendar(on date: String, atTime timeInMins: Int, duration: Int, notifyCompletion: @escaping () -> Void)
    func didTapOffHours(on date: String, atTime timeInMins: Int)
    func didScroll(toDate date: String)
    func didSwipeToCalendar(withDates dates: [String])
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

public extension AnyCalActionDelegate {
    func didTapOffHours(on _: String, atTime _: Int) {}
    func didSwipeToCalendar(withDates _: [String]) {}
    func showError(_: String) {}
    func refreshContent() {}
    func executeAction(withIdentifier _: String, at _: Int) {}
    func executeAction(withIdentifier _: String, at _: IndexPath) {}
    func didScroll(toDate _: String) {}
}

class AnyCalActionDelegateInterface: CalendarActionDelegate {
    var intendedActionDelegate: AnyCalActionDelegate

    init(withBaseActionDelegate actionDelegate: AnyCalActionDelegate) {
        intendedActionDelegate = actionDelegate
    }

    func didSelectCell(for item: CalendarItem) {
        intendedActionDelegate.didSelectCell(for: item)
    }

    func didTapCalendar(on date: Date, atTime timeInMins: Int, duration: Int, notifyCompletion: @escaping () -> Void) {
        intendedActionDelegate.didTapCalendar(on: date.standardDateString, atTime: timeInMins, duration: duration, notifyCompletion: notifyCompletion)
    }

    func didScroll(toDate date: Date) {
        intendedActionDelegate.didScroll(toDate: date.standardDateString)
    }

    func didSwipeToCalendar(withDates dates: [Date]) {
        intendedActionDelegate.didSwipeToCalendar(withDates: dates.compactMap { $0.standardDateString })
    }

    func didTapOffHours(on date: Date, atTime timeInMins: Int) {
        intendedActionDelegate.didTapOffHours(on: date.standardDateString, atTime: timeInMins)
    }

    func showError(_ alertText: String) {
        intendedActionDelegate.showError(alertText)
    }

    func refreshContent() {
        intendedActionDelegate.refreshContent()
    }

    func executeAction(withIdentifier identifier: String, at section: Int) {
        intendedActionDelegate.executeAction(withIdentifier: identifier, at: section)
    }

    func executeAction(withIdentifier identifier: String, at indexPath: IndexPath) {
        intendedActionDelegate.executeAction(withIdentifier: identifier, at: indexPath)
    }
}
