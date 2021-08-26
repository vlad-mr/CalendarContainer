//
//  FullCalendarViewController+Protocols.swift
//  CalendarContainer
//
//  Created by Volodymyr Kravchenko on 26.08.2021.
//  Copyright © 2021 Anywhere. All rights reserved.
//

import Foundation
import CalendarSDK

extension FullCalendarViewController: CalendarDataProvider {
  public func getCustomizationProvider(for calendarView: FullCalendarView) -> FullCalendarCustomizationProvider? {
    return FullCalendarCustomizationProvider.custom(forCalendarView: calendarView, withCustomCalendarCells: [isDailyCalendar ? AnytimeDailyEventCell.self : AnytimeWeaklyEventCell.self], calendarNibs: [], delegate: self)
  }

  public func getDataSource(forPage page: Int) -> FullCalendarDataSource? {
    let dataSource = DataSource()
    let calendarDataSource = CalendarDataSource(withSource: dataSource)
    let currentDate = self.currentDate.dateByAdding(page * numberOfDays, .day).date
    dataSource.activeDates = getCalendarDates(forDate: currentDate)
    return calendarDataSource
  }

  private func getCalendarDates(forDate date: Date) -> [Date] {

    var newDates = [Date]()
    for day in 0..<numberOfDays {
      newDates.append(date.dateByAdding(day, .day).date)
    }
    return newDates
  }
}

extension FullCalendarViewController: CalendarCustomizationProviderDelegate {
  public func reuseIdentifier(forItemAt indexPath: IndexPath) -> String {
    return isDailyCalendar ? AnytimeDailyEventCell.reuseIdentifier : AnytimeWeaklyEventCell.reuseIdentifier
  }

  public func dayOffTitle(forSection section: Int) -> String? {
    return "Vacation"
  }
}

// MARK: - Event cell swipe

extension FullCalendarViewController: CalendarSwipeActionDelegate {
  public func leadingSwipeActionsConfiguration(forRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
    return nil
  }

  public func trailingSwipeActionsConfiguration(forRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {

    let deleteAction = UIContextualAction(style: .destructive, title: nil) { (_, _, completionHandler) in
      completionHandler(true)
      self.currentDataSource?.deleteItem(at: indexPath)
    }

    deleteAction.title = "Delete"
    return UISwipeActionsConfiguration(actions: [deleteAction])
  }
}

extension FullCalendarViewController: CalendarActionDelegate {
  public func didTapCalendar(on date: Date, atTime timeInMins: Int, duration: Int, notifyCompletion: @escaping () -> Void) {
    print("""
          Date: \(date)
          timeInMinutes: \(timeInMins)
          duration: \(duration)
          """)
    presentAlertForTapAction(onCompletion: notifyCompletion)
  }

  public func didSelectCell(for item: CalendarItem) {
    presentAlert(forItem: item)
  }

  public func didTapCalendar(on date: Date, atTime timeInMins: Int) {

  }

  public func executeAction(withIdentifier identifier: String, at section: Int) {
    print(identifier)
    print(section)
  }

  public func presentAlert(forItem item: CalendarItem) {
    let alert = UIAlertController(title: "Tap action", message: "This would invoke the details page presented by the application", preferredStyle: .alert)
    let dismissAlert = UIAlertAction(title: "Got it!", style: .cancel, handler: nil)
    alert.addAction(dismissAlert)
    self.presentedViewController?.present(alert, animated: true, completion: nil)
  }

  public func presentAlertForTapAction(onCompletion completionCallback: @escaping ()-> Void) {
    let alert = UIAlertController(title: "Create an event", message: "This action selects a particular time for booking your events", preferredStyle: .alert)
    let dismissAlert = UIAlertAction(title: "Got it!", style: .default, handler: { _ in
      completionCallback()
    })
    alert.addAction(dismissAlert)
    self.presentedViewController?.present(alert, animated: true, completion: nil)
  }
}

extension FullCalendarViewController: DatePickerDataSource {
  public func isDayOff(on date: Date) -> Bool {
    return date.day == 21 || date.day == 11
  }

  public func numberOfEvents(for date: Date) -> Int {
    return 2
  }
}

extension FullCalendarViewController: DatePickerDelegate {
  public func didUpdatePickerTitle(to title: String) {
    print("TItle: \(title)")
  }

  public func didSelect(date: Date) {
    print("Selected Date: \(date)")
  }

  public func didUpdatePickerHeight(to height: CGFloat) {
    print("New Height: \(height)")
  }
}
