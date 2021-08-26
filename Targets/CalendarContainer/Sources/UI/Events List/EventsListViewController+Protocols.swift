//
//  EventsListViewController+Protocols.swift
//  CalendarContainer
//
//  Created by Volodymyr Kravchenko on 26.08.2021.
//  Copyright © 2021 Anywhere. All rights reserved.
//

import CalendarSDK

// MARK: - Events list data source

extension EventsListViewController: CalendarDataProvider {
  public func getCustomizationProvider(for calendarView: FullCalendarView) -> FullCalendarCustomizationProvider? {
    let customizationProvider = FullCalendarCustomizationProvider.custom(forCalendarView: calendarView,
                                                                         withCustomCalendarCells: [],
                                                                         calendarNibs: [],
                                                                         delegate: self)
    customizationProvider.swipeActionDelegate = self
    return customizationProvider
  }

  public func getDataSource(forPage page: Int) -> FullCalendarDataSource? {
    let calendarDataSource = EventsListDataSource()
    self.currentDataSource = calendarDataSource
    return calendarDataSource
  }
}

extension EventsListViewController: CalendarCustomizationProviderDelegate {
  public func reuseIdentifier(forItemAt indexPath: IndexPath) -> String {
    return ""
  }

  public func height(forRowAt indexPath: IndexPath) -> CGFloat? {
    return nil
  }
}

// MARK: - Event cell swipe

extension EventsListViewController: CalendarSwipeActionDelegate {
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

extension EventsListViewController: CalendarActionDelegate {
  public func didSelectCell(for item: CalendarItem) {
    // TODO: show appointment view
  }

  public func didTapCalendar(on date: Date, atTime timeInMins: Int, duration: Int, notifyCompletion: @escaping () -> Void) {
    // TODO: change date
  }
}

// MARK: - Picker

extension EventsListViewController: DatePickerDataSource {
  public func isDayOff(on date: Date) -> Bool {
      return date.day == 21 || date.day == 11
  }

  public func numberOfEvents(for date: Date) -> Int {
      return 2
  }
}

extension EventsListViewController: DatePickerDelegate {
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
